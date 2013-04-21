//
//  DanceMoveInstructionsLayer.m
//  LilD
//
//  Created by Michael Gao on 4/19/13.
//
//

#import "DanceMoveInstructionsLayer.h"
#import "GameManager.h"
#import "DanceMove.h"

@interface DanceMoveInstructionsLayer()

@property (nonatomic) CGSize screenSize;
@property (nonatomic, strong) DanceMove *danceMove;

@end

@implementation DanceMoveInstructionsLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
        self.danceMove = [GameManager sharedGameManager].individualDanceMove;
        
        [self displayInstructions];
        [self displayMenu];
    }
    
    return self;
}

-(void)displayInstructions {
    CCLabelTTF *instructions = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Instructions for %@", self.danceMove.name] fontName:@"Helvetica" fontSize:24];
    instructions.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.9);
    
    [self addChild:instructions];
    
    // play song
    [[GameManager sharedGameManager] playBackgroundTrack:self.danceMove.trackName];
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
