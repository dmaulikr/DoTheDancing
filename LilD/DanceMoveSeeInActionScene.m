//
//  DanceMoveSeeInActionScene.m
//  LilD
//
//  Created by Michael Gao on 4/23/13.
//
//

#import "DanceMoveSeeInActionScene.h"
#import "DanceMoveSeeInActionLayer.h"

@implementation DanceMoveSeeInActionScene

-(id)init {
    self = [super init];
    if (self != nil) {
        DanceMoveSeeInActionLayer *seeInActionLayer = [DanceMoveSeeInActionLayer node];
        [self addChild:seeInActionLayer];
    }
    
    return self;
}

@end
