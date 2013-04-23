//
//  DanceMoveSeeInActionLayer.m
//  LilD
//
//  Created by Michael Gao on 4/23/13.
//
//

#import "DanceMoveSeeInActionLayer.h"

@interface DanceMoveSeeInActionLayer()

@property (nonatomic) CGSize screenSize;

@end

@implementation DanceMoveSeeInActionLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
    }
    
    return self;
}

@end
