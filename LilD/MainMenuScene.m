//
//  MainMenuScene.m
//  chinAndCheeksTemplate
//
//  Created by Michael Gao on 11/17/12.
//
//

#import "MainMenuScene.h"
#import "MainMenuLayer.h"

@implementation MainMenuScene

-(id)init {
    self = [super init];
    if (self != nil) {
        MainMenuLayer *mainMenuLayer = [MainMenuLayer node];
        [self addChild:mainMenuLayer];
    }
    
    return self;
}

@end
