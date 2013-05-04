//
//  SearchingForIpadScene.m
//  DoTheDancing
//
//  Created by Michael Gao on 5/4/13.
//
//

#import "SearchingForIpadScene.h"
#import "SearchingForIpadLayer.h"

@implementation SearchingForIpadScene

-(id)init {
    self = [super init];
    if (self != nil) {
        SearchingForIpadLayer *layer = [SearchingForIpadLayer node];
        [self addChild:layer];
    }
    
    return self;
}

@end
