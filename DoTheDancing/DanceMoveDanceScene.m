//
//  DanceMoveDanceScene.m
//  LilD
//
//  Created by Michael Gao on 4/19/13.
//
//

#import "DanceMoveDanceScene.h"
#import "DanceMoveDanceLayer.h"

@implementation DanceMoveDanceScene

-(id)init {
    self = [super init];
    if (self != nil) {
        DanceMoveDanceLayer *danceLayer = [DanceMoveDanceLayer node];
        [self addChild:danceLayer];
    }
    
    return self;
}

@end
