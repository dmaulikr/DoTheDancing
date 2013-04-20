//
//  DanceMovePracticeScene.m
//  LilD
//
//  Created by Michael Gao on 4/19/13.
//
//

#import "DanceMovePracticeScene.h"
#import "DanceMovePracticeInstructionsLayer.h"
#import "DanceMovePracticeDanceLayer.h"

@implementation DanceMovePracticeScene

-(id)init {
    self = [super init];
    if (self != nil) {
        DanceMovePracticeInstructionsLayer *instructionsLayer = [DanceMovePracticeInstructionsLayer node];
        instructionsLayer.delegate = self;
        [self addChild:instructionsLayer];
    }
    
    return self;
}

-(void)segueToDanceLayer {
    // transition from instructions to dance mode
    [self removeAllChildrenWithCleanup:YES];
    
    DanceMovePracticeDanceLayer *danceLayer = [DanceMovePracticeDanceLayer node];
    [self addChild:danceLayer];
}

@end
