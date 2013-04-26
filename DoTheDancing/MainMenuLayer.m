//
//  MainMenuLayer.m
//  chinAndCheeksTemplate
//
//  Created by Michael Gao on 11/17/12.
//
//

#import "MainMenuLayer.h"
#import "Constants.h"
#import "GameManager.h"

@interface MainMenuLayer()

@property (nonatomic) CGSize screenSize;

@end

@implementation MainMenuLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
        
        [self displayMenu];
    }
    
    return self;
}

-(void)displayMenu {
    CCMenuItemLabel *singlePlayerLabel = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Single Player" fontName:@"Helvetica" fontSize:32] block:^(id sender) {
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeDanceMoveSelection];
    }];
    singlePlayerLabel.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.6);
    
    CCMenuItemLabel *multiplayerLabel = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Multiplayer" fontName:@"Helvetica" fontSize:32] block:^(id sender) {
        
    }];
    multiplayerLabel.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.4);
    
    CCMenu *menu = [CCMenu menuWithItems:singlePlayerLabel, multiplayerLabel, nil];
    menu.position = ccp(0, 0);
    
    [self addChild:menu];
}

@end
