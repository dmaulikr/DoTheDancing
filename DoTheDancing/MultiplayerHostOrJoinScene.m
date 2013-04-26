//
//  MultiplayerHostOrJoinScene.m
//  DoTheDancing
//
//  Created by Michael Gao on 4/25/13.
//
//

#import "MultiplayerHostOrJoinScene.h"
#import "MultiplayerHostOrJoinLayer.h"

@implementation MultiplayerHostOrJoinScene

-(id)init {
    self = [super init];
    if (self != nil) {
        MultiplayerHostOrJoinLayer *layer = [MultiplayerHostOrJoinLayer node];
        [self addChild:layer];
    }
    
    return self;
}


@end
