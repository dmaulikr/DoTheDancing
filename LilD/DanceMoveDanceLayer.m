//
//  DanceMoveDanceLayer.m
//  LilD
//
//  Created by Michael Gao on 4/19/13.
//
//

#import "DanceMoveDanceLayer.h"
#import "GameManager.h"
#include <CoreMotion/CoreMotion.h>
#import <CoreFoundation/CoreFoundation.h>
#import "DanceMove.h"

@interface DanceMoveDanceLayer()

@property (nonatomic) CGSize screenSize;
@property (nonatomic) CGFloat elapsedTime;
@property (nonatomic, strong) DanceMove *danceMove;

// motion detection
@property (nonatomic, strong) CMMotionManager *motionManager;

// temp bernie detection
@property (nonatomic) BOOL bernie1Detected;
@property (nonatomic) BOOL bernie2Detected;
@property (nonatomic) BOOL bernie3Detected;
@property (nonatomic) BOOL bernie4Detected;
@property (nonatomic) NSInteger numBernie;
@property (nonatomic) BOOL shouldDetectBernie;

@end

@implementation DanceMoveDanceLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
        self.danceMove = [GameManager sharedGameManager].individualDanceMove;
        
        // temp bernie init
        self.bernie1Detected = NO;
        self.bernie2Detected = NO;
        self.bernie3Detected = NO;
        self.bernie4Detected = NO;
        self.numBernie = 1;
        self.shouldDetectBernie = YES;
        
        [[GameManager sharedGameManager] resetForDanceMovePractice];
        [self displayPlaceholderText];
        [self initMotionManager];
        [self scheduleUpdate];
    }
    
    return self;
}

-(void)onExit {
    [self.motionManager stopDeviceMotionUpdates];
    [super onExit];
}

-(void)displayPlaceholderText {
    CCLabelTTF *placeholder = [CCLabelTTF labelWithString:@"Dance now!" fontName:@"Helvetica" fontSize:32];
    placeholder.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.6);
    
    [self addChild:placeholder];
    
    // play track
    [[GameManager sharedGameManager] playBackgroundTrack:self.danceMove.trackName];
}

-(void)initMotionManager {
    // add and position the temp labels
//    self.yawLabel = [CCLabelTTF labelWithString:@"Yaw: " fontName:@"Marker Felt" fontSize:24];
//    self.pitchLabel = [CCLabelTTF labelWithString:@"Pitch: " fontName:@"Marker Felt" fontSize:24];
//    self.rollLabel = [CCLabelTTF labelWithString:@"Roll: " fontName:@"Marker Felt" fontSize:24];
//    self.userAccelerationLabel = [CCLabelTTF labelWithString:@"User acceleration: " fontName:@"Marker Felt" fontSize:24];
//    self.yawLabel.position = ccp(100, 240);
//    self.pitchLabel.position = ccp(100, 300);
//    self.rollLabel.position = ccp(100, 360);
//    self.userAccelerationLabel.position = ccp(100, 420);
//    [self addChild:self.yawLabel];
//    [self addChild:self.pitchLabel];
//    [self addChild:self.rollLabel];
//    [self addChild:self.userAccelerationLabel];
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 1.0/60.0f;
    //    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:(CMAttitudeReferenceFrameXArbitraryZVertical)];
    [self.motionManager startDeviceMotionUpdates];
}

-(void)update:(ccTime)delta {
    /*
        3 seconds per bernie
        16 seconds before segue to results
        start first bernie after 1 second into the song
    */
    self.elapsedTime = self.elapsedTime + delta;
    
    switch (self.numBernie) {
        case 1:
            if (self.elapsedTime > 4) {
                [self moveOnToNextBernie];
            }
            
            break;
            
        case 2:
            if (self.elapsedTime > 7) {
                [self moveOnToNextBernie];
            }
            
            break;
            
        case 3:
            if (self.elapsedTime > 10) {
                [self moveOnToNextBernie];
            }
            
            break;
            
        case 4:
            if (self.elapsedTime > 13) {
                [self moveOnToNextBernie];
            }
            
            break;
            
        case 5:
            if (self.elapsedTime > 16) {
                [self segueToResults];
            }
            
            break;
            
        default:
            break;
    }
    
    [self detectBernie];
}

-(void)detectBernie {
    //    CMAttitude *currentAttitude = self.motionManager.deviceMotion.attitude;
    float yaw = (float)(CC_RADIANS_TO_DEGREES(self.motionManager.deviceMotion.attitude.yaw));
    float pitch = (float)(CC_RADIANS_TO_DEGREES(self.motionManager.deviceMotion.attitude.pitch));
    float roll = (float)(CC_RADIANS_TO_DEGREES(self.motionManager.deviceMotion.attitude.roll)); // roll is +90 (right-handed) and -90 (left-handed) when perpendicular to ground in landscape mode
    CMAcceleration totalAcceleration = self.motionManager.deviceMotion.userAcceleration;
    
    if (self.shouldDetectBernie && pitch < -20 && pitch > -80) {
        if (!self.bernie1Detected && (totalAcceleration.z > 0.3)) {
            self.bernie1Detected = YES;
            CCLOG(@"bernie_1 detected");
        }
        else if (self.bernie1Detected && !self.bernie2Detected && (totalAcceleration.z < -0.3)) {
            self.bernie2Detected = YES;
            CCLOG(@"bernie_2 detected");
        }
        
        else if (self.bernie1Detected && self.bernie2Detected && !self.bernie3Detected && (totalAcceleration.z > 0.3)) {
            self.bernie3Detected = YES;
            CCLOG(@"bernie_3 detected");
        }
        
        else if (self.bernie1Detected && self.bernie2Detected && self.bernie3Detected && !self.bernie4Detected && (totalAcceleration.z < -0.3)) {
            [self setDanceMoveCorrect];
        }
    }
}

-(void)setDanceMoveCorrect {
    CCLOG(@"COMPLETE BERNIE DETECTED!!!!!!!!!");
    self.shouldDetectBernie = NO;
    
    if (self.numBernie == 1) {
        [GameManager sharedGameManager].danceMove1Correct = YES;
    } else if (self.numBernie == 2) {
        [GameManager sharedGameManager].danceMove2Correct = YES;
    } else if (self.numBernie == 3) {
        [GameManager sharedGameManager].danceMove3Correct = YES;
    } else if (self.numBernie == 4) {
        [GameManager sharedGameManager].danceMove4Correct = YES;
    } else if (self.numBernie == 5) {
        [GameManager sharedGameManager].danceMove5Correct = YES;
    }
}

-(void)moveOnToNextBernie {
    self.numBernie++;
    self.bernie1Detected = NO;
    self.bernie2Detected = NO;
    self.bernie3Detected = NO;
    self.bernie4Detected = NO;
    self.shouldDetectBernie = YES;
    
    CCLOG(@"moveOnToNextBernie: %i", self.numBernie);
}

-(void)segueToResults {
    [[GameManager sharedGameManager] stopBackgroundTrack];
    [[GameManager sharedGameManager] runSceneWithID:kSceneTypeDanceMoveResults];
}

@end
