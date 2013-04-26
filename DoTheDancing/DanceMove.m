//
//  DanceMove.m
//  LilD
//
//  Created by Michael Gao on 4/20/13.
//
//

#import "DanceMove.h"

@implementation DanceMove

-(id)init {
    self = [super init];
    if (self != nil) {
        self.danceMoveType = kDanceMoveNone;
        self.name = nil;
        self.trackName = nil;
        self.numSteps = 0;
        self.stepsArray = nil;
        self.numIndividualIterations = 0;
        self.timePerIteration = 0;
        self.timePerSteps = nil;
        self.illustrationsForSteps = nil;
        self.delayForIllustrationAnimations = nil;
        self.instructionsForSteps = nil;
        self.timeToStartCountdown = 0;
    }
    
    return self;
}

@end
