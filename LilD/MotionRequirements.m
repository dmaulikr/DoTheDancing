//
//  MotionRequirements.m
//  LilD
//
//  Created by Michael Gao on 4/22/13.
//
//

#import "MotionRequirements.h"
#import "Constants.h"

@implementation MotionRequirements

-(id)init {
    self = [super init];
    if (self != nil) {
        self.yawMin = kYawMin;
        self.yawMax = kYawMax;
        self.pitchMin = kPitchMin;
        self.pitchMax = kPitchMax;
        self.rollMin = kRollMin;
        self.rollMax = kRollMax;
        self.accelerationXMin = kAccelerationXMin;
        self.accelerationXMax = kAccelerationXMax;
        self.accelerationYMin = kAccelerationYMin;
        self.accelerationYMax = kAccelerationYMax;
        self.accelerationZMin = kAccelerationZMin;
        self.accelerationZMax = kAccelerationZMax;
    }
    
    return self;
}

@end
