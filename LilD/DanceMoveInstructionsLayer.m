//
//  DanceMoveInstructionsLayer.m
//  LilD
//
//  Created by Michael Gao on 4/19/13.
//
//

#import "DanceMoveInstructionsLayer.h"
#import "GameManager.h"
#import "MusicConstants.h"

@interface DanceMoveInstructionsLayer()

@property (nonatomic) CGSize screenSize;

@end

@implementation DanceMoveInstructionsLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
        
        [self displayInstructions];
        [self displayMenu];
    }
    
    return self;
}

-(void)displayInstructions {
    CCLabelTTF *instructions = [CCLabelTTF labelWithString:@"Instructions for The Bernie" fontName:@"Helvetica" fontSize:24];
    instructions.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.9);
    
    [self addChild:instructions];
    
    // play song
    [[GameManager sharedGameManager] playBackgroundTrack:kBernieSong];
}

-(void)displayMenu {
    CCMenuItemLabel *danceNowLabel = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Try it out!" fontName:@"Helvetica" fontSize:28] block:^(id sender) {
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeDanceMoveDance];
    }];
    danceNowLabel.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.1);
    
    CCMenu *menu = [CCMenu menuWithItems:danceNowLabel, nil];
    menu.position = ccp(0, 0);
    
    [self addChild:menu];
}

@end
