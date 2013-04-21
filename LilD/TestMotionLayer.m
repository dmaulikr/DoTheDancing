//
//  GameLayer.m
//  chinAndCheeksTemplate
//
//  Created by Michael Gao on 2/20/13.
//
//

#import "TestMotionLayer.h"
#include <CoreMotion/CoreMotion.h>
#import <CoreFoundation/CoreFoundation.h>

@interface TestMotionLayer ()

@property (nonatomic) CGSize screenSize;

// temp variables for gyroscope tutorial
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) CCLabelTTF *yawLabel;
@property (nonatomic, strong) CCLabelTTF *pitchLabel;
@property (nonatomic, strong) CCLabelTTF *rollLabel;
@property (nonatomic, strong) CCLabelTTF *userAccelerationLabel;

// temp bernie
@property (nonatomic) BOOL bernie1Detected;
@property (nonatomic) BOOL bernie2Detected;
@property (nonatomic) BOOL bernie3Detected;
@property (nonatomic) BOOL bernie4Detected;

@end

@implementation TestMotionLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        CCLOG(@"GameLayer->init");
        self.screenSize = [CCDirector sharedDirector].winSize;
        
        self.bernie1Detected = NO;
        self.bernie2Detected = NO;
        self.bernie3Detected = NO;
        self.bernie4Detected = NO;
        
        [self initGyroscope];
        [self scheduleUpdate];
    }
    
    return self;
}

-(void)initGyroscope {
    // add and position the temp labels
    self.yawLabel = [CCLabelTTF labelWithString:@"Yaw: " fontName:@"Marker Felt" fontSize:24];
    self.pitchLabel = [CCLabelTTF labelWithString:@"Pitch: " fontName:@"Marker Felt" fontSize:24];
    self.rollLabel = [CCLabelTTF labelWithString:@"Roll: " fontName:@"Marker Felt" fontSize:24];
    self.userAccelerationLabel = [CCLabelTTF labelWithString:@"User acceleration: " fontName:@"Marker Felt" fontSize:24];
    self.yawLabel.position = ccp(100, 240);
    self.pitchLabel.position = ccp(100, 300);
    self.rollLabel.position = ccp(100, 360);
    self.userAccelerationLabel.position = ccp(100, 420);
    [self addChild:self.yawLabel];
    [self addChild:self.pitchLabel];
    [self addChild:self.rollLabel];
    [self addChild:self.userAccelerationLabel];
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 1.0/60.0f;
//    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:(CMAttitudeReferenceFrameXArbitraryZVertical)];
    [self.motionManager startDeviceMotionUpdates];
}

-(void) onExit {
    CCLOG(@"GameLayer->onExit");
    [self.motionManager stopDeviceMotionUpdates];
    [super onExit];
}

-(void) update:(ccTime)delta {
    //    CMAttitude *currentAttitude = self.motionManager.deviceMotion.attitude;
    float yaw = (float)(CC_RADIANS_TO_DEGREES(self.motionManager.deviceMotion.attitude.yaw));
    float pitch = (float)(CC_RADIANS_TO_DEGREES(self.motionManager.deviceMotion.attitude.pitch));
    float roll = (float)(CC_RADIANS_TO_DEGREES(self.motionManager.deviceMotion.attitude.roll)); // roll is +90 (right-handed) and -90 (left-handed) when perpendicular to ground in landscape mode
    CMAcceleration totalAcceleration = self.motionManager.deviceMotion.userAcceleration;
    CMAcceleration gravity = self.motionManager.deviceMotion.gravity;
    CMAcceleration onlyUserAcceleration;
    onlyUserAcceleration.x = totalAcceleration.x - gravity.x;
    onlyUserAcceleration.y = totalAcceleration.y - gravity.y;
    onlyUserAcceleration.z = totalAcceleration.z - gravity.z;
    
    // convert the degrees value to float and use Math function to round the value
    self.yawLabel.string = [NSString stringWithFormat:@"Yaw: %.0f", yaw];
    self.pitchLabel.string = [NSString stringWithFormat:@"Pitch: %.0f", pitch];
    self.rollLabel.string = [NSString stringWithFormat:@"Roll: %.0f", roll];
//    self.userAccelerationLabel.string = [NSString stringWithFormat:@"User acceleration: (%.2f, %.2f, %.2f)", userAcceleration.x, userAcceleration.y, userAcceleration.z];
//    if (fabs(totalAcceleration.x) > 0.1 && fabs(totalAcceleration.y) > 0.1 && fabs(totalAcceleration.z) > 0.1) {
//        CCLOG(@"User acceleration: (%.2f, %.2f, %.2f)", totalAcceleration.x, totalAcceleration.y, totalAcceleration.z);
//    }
    
    // detect bernie
    if (pitch < -20 && pitch > -60) {
        if (!self.bernie1Detected && (totalAcceleration.z > 0.3)) {
            self.bernie1Detected = YES;
        }
        else if (self.bernie1Detected && !self.bernie2Detected && (totalAcceleration.z < -0.3)) {
            self.bernie2Detected = YES;
        }
        
        else if (self.bernie1Detected && self.bernie2Detected && !self.bernie3Detected && (totalAcceleration.z > 0.3)) {
            self.bernie3Detected = YES;
        }
        
        else if (self.bernie1Detected && self.bernie2Detected && self.bernie3Detected && !self.bernie4Detected && (totalAcceleration.z < -0.3)) {
            self.bernie1Detected = NO;
            self.bernie2Detected = NO;
            self.bernie3Detected = NO;
            CCLOG(@"BERNIE DETECTED!!!!!!!!!");
        }
    }
}

@end
