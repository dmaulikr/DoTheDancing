//
//  DanceMoveBernie.m
//  LilD
//
//  Created by Michael Gao on 4/20/13.
//
//

#import "DanceMoveBernie.h"

@implementation DanceMoveBernie

-(id)init {
    self = [super init];
    if (self != nil) {
        self.danceMoveType = kDanceMoveBernie;
        self.name = kDanceMoveBernieName;
        self.trackName = @"the_bernie.caf";
        
        [self setUpMotionRequirements];
        
        self.numIndividualIterations = 4;
        self.timePerIteration = 3.0;
    }
    
    return self;
}

-(void)setUpMotionRequirements {
    self.numSteps = 2;
    
    /* step 1 breakdown - 1 part */
    // part 1
    MotionRequirements *step1_1 = [[MotionRequirements alloc] init];
    step1_1.pitchMin = -80;
    step1_1.pitchMax = -20;
    
    /* step 2 breakdown - 4 parts */
    // part 1
    MotionRequirements *step2_1 = [[MotionRequirements alloc] init];
    step2_1.pitchMin = -80;
    step2_1.pitchMax = -20;
    step2_1.accelerationZMin = 0.3;
    
    // part 2
    MotionRequirements *step2_2 = [[MotionRequirements alloc] init];
    step2_2.pitchMin = -80;
    step2_2.pitchMax = -20;
    step2_2.accelerationZMax = -0.3;
    
    // part 3
    MotionRequirements *step2_3 = [[MotionRequirements alloc] init];
    step2_3.pitchMin = -80;
    step2_3.pitchMax = -20;
    step2_3.accelerationZMin = 0.3;
    
    // part 4
    MotionRequirements *step2_4 = [[MotionRequirements alloc] init];
    step2_4.pitchMin = -80;
    step2_4.pitchMax = -20;
    step2_4.accelerationZMax = -0.3;
    
    NSArray *step1Array = [NSArray arrayWithObject:step1_1];
    NSArray *step2Array = [NSArray arrayWithObjects:step2_1, step2_2, step2_3, step2_4, nil];
    
    self.stepsArray = [NSArray arrayWithObjects:step1Array, step2Array, nil];
}

@end
