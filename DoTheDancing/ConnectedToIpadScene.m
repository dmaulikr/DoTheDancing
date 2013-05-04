//
//  ConnectedToIpadScene.m
//  DoTheDancing
//
//  Created by Michael Gao on 5/4/13.
//
//

#import "ConnectedToIpadScene.h"
#import "ConnectedToIpadLayer.h"

@implementation ConnectedToIpadScene

-(id)init {
    self = [super init];
    if (self != nil) {
        ConnectedToIpadLayer *layer = [ConnectedToIpadLayer node];
        [self addChild:layer];
    }
    
    return self;
}

@end
