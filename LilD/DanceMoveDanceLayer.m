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

// dance parameters
@property (nonatomic, strong) NSMutableArray *dancePartsDetected;
@property (nonatomic) NSInteger currentDanceIteration;
@property (nonatomic) NSInteger currentDanceStep;
@property (nonatomic) NSInteger currentDancePart;
@property (nonatomic) BOOL shouldDetectDanceMove;
@property (nonatomic) CGFloat timeToMoveToNextIteration;

@end

@implementation DanceMoveDanceLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
        self.danceMove = [GameManager sharedGameManager].individualDanceMove;
        
        // init dance parts detected
        self.dancePartsDetected = [NSMutableArray arrayWithCapacity:self.danceMove.numSteps];
        for (int i=0; i<self.danceMove.numSteps; i++) {
            NSArray *partsArray = self.danceMove.stepsArray[i];
            NSMutableArray *boolArray = [NSMutableArray arrayWithCapacity:partsArray.count];
            for (int j=0; j<partsArray.count; j++) {
                boolArray[j] = [NSNumber numberWithBool:NO];
            }
            
            self.dancePartsDetected[i] = boolArray;
        }
        self.currentDanceIteration = 1;
        self.currentDanceStep = 1;
        self.currentDancePart = 1;
        self.shouldDetectDanceMove = YES;
        self.timeToMoveToNextIteration = 1 + self.danceMove.timePerIteration;
        
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
    
    if (self.elapsedTime >= self.timeToMoveToNextIteration) {
        if (self.currentDanceIteration >= self.danceMove.numIndividualIterations) {
            // move to results
            [self segueToResults];
        } else {
            // move on to next iteration
            [self moveToNextIteration];
        }
    }
        
    [self detectDancePart];
}

-(void)detectDancePart {
    float yaw = (float)(CC_RADIANS_TO_DEGREES(self.motionManager.deviceMotion.attitude.yaw));
    float pitch = (float)(CC_RADIANS_TO_DEGREES(self.motionManager.deviceMotion.attitude.pitch));
    float roll = (float)(CC_RADIANS_TO_DEGREES(self.motionManager.deviceMotion.attitude.roll));
    CMAcceleration totalAcceleration = self.motionManager.deviceMotion.userAcceleration;
    
    if (self.shouldDetectDanceMove) {
        MotionRequirements *currentPartMotionRequirements = self.danceMove.stepsArray[self.currentDanceStep-1][self.currentDancePart-1];
        if ((yaw > currentPartMotionRequirements.yawMin) &&
            (yaw < currentPartMotionRequirements.yawMax) &&
            (pitch > currentPartMotionRequirements.pitchMin) &&
            (pitch < currentPartMotionRequirements.pitchMax) &&
            (roll > currentPartMotionRequirements.rollMin) &&
            (roll < currentPartMotionRequirements.rollMax) &&
            (totalAcceleration.x > currentPartMotionRequirements.accelerationXMin) &&
            (totalAcceleration.x < currentPartMotionRequirements.accelerationXMax) &&
            (totalAcceleration.y > currentPartMotionRequirements.accelerationYMin) &&
            (totalAcceleration.y < currentPartMotionRequirements.accelerationYMax) &&
            (totalAcceleration.z > currentPartMotionRequirements.accelerationZMin) &&
            (totalAcceleration.z < currentPartMotionRequirements.accelerationZMax)) {
            CCLOG(@"dancemove step: %i, part: %i detected", self.currentDanceStep, self.currentDancePart);
            self.dancePartsDetected[self.currentDanceStep-1][self.currentDancePart-1] = [NSNumber numberWithBool:YES];
            
            NSArray *partsArray = self.danceMove.stepsArray[self.danceMove.stepsArray.count-1];
            if (self.currentDanceStep == self.danceMove.stepsArray.count && self.currentDancePart == partsArray.count) {
                // detected complete dance move
                [self setDanceMoveCorrectForIteration:self.currentDanceIteration];
            } else {
                // move on to next dance part
                [self moveToNextDancePart];
            }
        }
    }
}

-(void)moveToNextDancePart {
    NSArray *partsArray = self.danceMove.stepsArray[self.currentDanceStep-1];
    if (self.currentDancePart == partsArray.count) {
        // move on to next dance step
        self.currentDanceStep++;
        self.currentDancePart = 1;
    } else {
        // move on to next dance part of current step
        self.currentDancePart++;
    }
    CCLOG(@"moveToNextDancePart: Step: %i, Part: %i", self.currentDanceStep, self.currentDancePart);
}

-(void)setDanceMoveCorrectForIteration:(int)iteration {
    CCLOG(@"DANCE MOVE DETECTED!!!!!!!");
    self.shouldDetectDanceMove = NO;
    [GameManager sharedGameManager].danceMoveIterationResults[iteration-1] = [NSNumber numberWithBool:YES];
}

-(void)moveToNextIteration {
    self.timeToMoveToNextIteration = self.timeToMoveToNextIteration + self.danceMove.timePerIteration;
    self.currentDanceIteration++;
    self.currentDanceStep = 1;
    self.currentDancePart = 1;
    [self resetDancePartsDetected];
    self.shouldDetectDanceMove = YES;
    
    CCLOG(@"moveToNextIteration: %i", self.currentDanceIteration);
}

-(void)resetDancePartsDetected {    
    for (NSMutableArray *partsDetected in self.dancePartsDetected) {
        for (int i=0; i<partsDetected.count; i++) {
            partsDetected[i] = [NSNumber numberWithBool:NO];
        }
    }
}

-(void)segueToResults {
    [[GameManager sharedGameManager] stopBackgroundTrack];
    [[GameManager sharedGameManager] runSceneWithID:kSceneTypeDanceMoveResults];
}

@end
