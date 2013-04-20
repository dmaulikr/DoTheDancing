//
//  DanceMoveInstructionsScene.m
//  LilD
//
//  Created by Michael Gao on 4/19/13.
//
//

#import "DanceMoveInstructionsScene.h"
#import "DanceMoveInstructionsLayer.h"

@implementation DanceMoveInstructionsScene

-(id)init {
    self = [super init];
    if (self != nil) {
        DanceMoveInstructionsLayer *instructionsLayer = [DanceMoveInstructionsLayer node];
        [self addChild:instructionsLayer];
    }
    
    return self;
}

@end
