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
@property (nonatomic, strong) CCSpriteBatchNode *batchNode;

@end

@implementation MainMenuLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        // load texture atlas
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"spritesheet.plist"];
        self.screenSize = [CCDirector sharedDirector].winSize;
        self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet.pvr.ccz"];
        [self addChild:self.batchNode];
        
        [self displayBackground];
        [self displayLogo];
        [self displayMenu];
    }
    
    return self;
}

-(void)displayBackground {
    CCSprite *bg = [CCSprite spriteWithFile:@"mainmenu_bg.png"];
    bg.anchorPoint = ccp(0.5, 1);
    bg.position = ccp(self.screenSize.width * 0.5, self.screenSize.height);
    [self addChild:bg z:-1];
}

-(void)displayLogo {
    CCSprite *logo = [CCSprite spriteWithSpriteFrameName:@"mainmenu_logo1.png"];
    logo.anchorPoint = ccp(0.5, 1);
    logo.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.96);
    [self.batchNode addChild:logo];
    
    // animate logo
    CCAnimation *animation = [CCAnimation animation];
    animation.restoreOriginalFrame = YES;
    animation.delayPerUnit = 0.25;
    [animation addSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mainmenu_logo2.png"]];
    [animation addSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mainmenu_logo1.png"]];
    id action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]];
    [logo runAction:action];
}

-(void)displayMenu {
    CCSprite *menuBg = [CCSprite spriteWithSpriteFrameName:@"mainmenu_cream_box.png"];
    if (IS_IPHONE_4) {
        menuBg.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.52);
    } else {
        menuBg.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.58);
    }
    
    CCMenuItemSprite *singlePlayerButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_button_single1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_button_single2.png"] block:^(id sender) {
        [GameManager sharedGameManager].isMultiplayer = NO;
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeDanceMoveSelection];
    }];
    singlePlayerButton.anchorPoint = ccp(0.5, 1);
    singlePlayerButton.position = ccp(menuBg.contentSize.width * 0.5, menuBg.contentSize.height * 0.9);
    
    CCMenuItemSprite *multiplayerButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_button_multi1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_button_multi2.png"] block:^(id sender) {
        [GameManager sharedGameManager].isMultiplayer = YES;
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeMultiplayerHostOrJoin];
    }];
    multiplayerButton.anchorPoint = ccp(0.5, 0);
    multiplayerButton.position = ccp(menuBg.contentSize.width * 0.5, menuBg.contentSize.height * 0.1);
    
    CCMenu *menu = [CCMenu menuWithItems:singlePlayerButton, multiplayerButton, nil];
    menu.position = ccp(0, 0);
    
    [menuBg addChild:menu];
    
    [self addChild:menuBg];
}

@end
