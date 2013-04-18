//
//  GameScene.m
//  chinAndCheeksTemplate
//
//  Created by Michael Gao on 2/20/13.
//
//

#import "GameScene.h"
#import "GameLayer.h"

@implementation GameScene

-(id)init {
    self = [super init];
    if (self != nil) {
        GameLayer *gameLayer = [GameLayer node];
        [self addChild:gameLayer];
    }
    
    return self;
}

@end
