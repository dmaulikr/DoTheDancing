//
//  MultiplayerWaitingRoomScene.m
//  DoTheDancing
//
//  Created by Michael Gao on 4/25/13.
//
//

#import "MultiplayerWaitingRoomScene.h"
#import "MultiplayerWaitingRoomLayer.h"

@implementation MultiplayerWaitingRoomScene

-(id)init {
    self = [super init];
    if (self != nil) {
        MultiplayerWaitingRoomLayer *layer = [MultiplayerWaitingRoomLayer node];
        [self addChild:layer];
    }
    
    return self;
}

@end
