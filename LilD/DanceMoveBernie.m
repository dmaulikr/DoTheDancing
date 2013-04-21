//
//  DanceMoveBernie.m
//  LilD
//
//  Created by Michael Gao on 4/20/13.
//
//

#import "DanceMoveBernie.h"

@implementation DanceMoveBernie

-(id)init {
    self = [super init];
    if (self != nil) {
        self.danceMoveType = kDanceMoveBernie;
        self.name = kDanceMoveBernieName;
        self.trackName = @"Moving_Like_Bernie.mp3";
    }
    
    return self;
}

@end
