//
//  DanceMove.m
//  LilD
//
//  Created by Michael Gao on 4/20/13.
//
//

#import "DanceMove.h"

@implementation DanceMove

-(id)init {
    self = [super init];
    if (self != nil) {
        self.danceMoveType = kDanceMoveNone;
        self.name = nil;
        self.trackName = nil;
    }
    
    return self;
}

@end
