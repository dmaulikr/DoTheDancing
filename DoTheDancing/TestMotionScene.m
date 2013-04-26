//
//  GameScene.m
//  chinAndCheeksTemplate
//
//  Created by Michael Gao on 2/20/13.
//
//

#import "TestMotionScene.h"
#import "TestMotionLayer.h"

@implementation TestMotionScene

-(id)init {
    self = [super init];
    if (self != nil) {
        TestMotionLayer *gameLayer = [TestMotionLayer node];
        [self addChild:gameLayer];
    }
    
    return self;
}

@end
