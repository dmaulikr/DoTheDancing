//
//  DanceMoveResultsScene.m
//  LilD
//
//  Created by Michael Gao on 4/19/13.
//
//

#import "DanceMoveResultsScene.h"
#import "DanceMoveResultsLayer.h"

@implementation DanceMoveResultsScene

-(id)init {
    self = [super init];
    if (self != nil) {
        DanceMoveResultsLayer *resultsLayer = [DanceMoveResultsLayer node];
        [self addChild:resultsLayer];
    }
    
    return self;
}

@end
