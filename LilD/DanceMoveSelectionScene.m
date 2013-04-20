//
//  DanceMoveSelectionScene.m
//  LilD
//
//  Created by Michael Gao on 4/19/13.
//
//

#import "DanceMoveSelectionScene.h"
#import "DanceMoveSelectionLayer.h"

@implementation DanceMoveSelectionScene

-(id)init {
    self = [super init];
    if (self != nil) {
        DanceMoveSelectionLayer *danceMoveSelectionLayer = [DanceMoveSelectionLayer node];
        [self addChild:danceMoveSelectionLayer];
    }
    
    return self;
}

@end
