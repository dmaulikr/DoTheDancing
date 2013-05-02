//
//  MultiplayerHostOrJoinLayer.m
//  DoTheDancing
//
//  Created by Michael Gao on 4/25/13.
//
//

#import "MultiplayerHostOrJoinLayer.h"
#import "GameManager.h"

@interface MultiplayerHostOrJoinLayer()

@property (nonatomic) CGSize screenSize;
//@property (nonatomic, strong) CCSpriteBatchNode *batchNode;

@end

@implementation MultiplayerHostOrJoinLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
        //        self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet.pvr.ccz"];
        //        [self addChild:self.batchNode];
        
        [self displayBackground];
        [self displayTopBar];
        [self displayMenu];
        [self displayBackButton];
        [self checkIfPlayerGotDisconnectedFromMultiplayer];
    }
    
    return self;
}

-(void)displayBackground {
    CCSprite *bg = [CCSprite spriteWithFile:@"mainmenu_bg.png"];
    bg.anchorPoint = ccp(0.5, 1);
    bg.position = ccp(self.screenSize.width * 0.5, self.screenSize.height);
    [self addChild:bg z:-1];
}

-(void)displayTopBar {
    // top banner bg
    CCSprite *topBannerBg = [CCSprite spriteWithSpriteFrameName:@"instructions_top_banner.png"];
    topBannerBg.anchorPoint = ccp(0, 1);
    topBannerBg.position = ccp(0, self.screenSize.height);
    [self addChild:topBannerBg];
    
    // multiplayer label
    CCLabelBMFont *multiplayerLabel = [CCLabelBMFont labelWithString:@"Multiplayer" fntFile:@"economica-bold_64.fnt"];
    multiplayerLabel.color = ccc3(249, 185, 56);
    multiplayerLabel.position = ccp(self.screenSize.width * 0.5, topBannerBg.contentSize.height * 0.5);
    [topBannerBg addChild:multiplayerLabel];
}

-(void)displayMenu {
    CCSprite *menuBg = [CCSprite spriteWithSpriteFrameName:@"mainmenu_cream_box.png"];
    if (IS_IPHONE_4) {
        menuBg.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.66);
    } else {
        menuBg.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.7);
    }
    
    CCMenuItemSprite *hostButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"multiplayer_hostorjoin_button_host1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"multiplayer_hostorjoin_button_host2.png"] block:^(id sender) {
        [GameManager sharedGameManager].isHost = YES;
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeMultiplayerWaitingRoom];
    }];
    hostButton.anchorPoint = ccp(0.5, 1);
    hostButton.position = ccp(menuBg.contentSize.width * 0.5, menuBg.contentSize.height * 0.9);
    
    CCMenuItemSprite *joinButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"multiplayer_hostorjoin_button_join1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"multiplayer_hostorjoin_button_join2.png"] block:^(id sender) {
        [GameManager sharedGameManager].isHost = NO;
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeMultiplayerWaitingRoom];
    }];
    joinButton.anchorPoint = ccp(0.5, 0);
    joinButton.position = ccp(menuBg.contentSize.width * 0.5, menuBg.contentSize.height * 0.1);
    
    CCMenu *menu = [CCMenu menuWithItems:hostButton, joinButton, nil];
    menu.position = ccp(0, 0);
    
    [menuBg addChild:menu];
    
    [self addChild:menuBg];
}

-(void)displayBackButton {
    CCMenuItemSprite *backButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"instructions_button_back1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"instructions_button_back2.png"] block:^(id sender) {
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeMainMenu];
    }];
    backButton.anchorPoint = ccp(0, 1);
    backButton.position = ccp(0, self.screenSize.height * 0.992);
    
    CCMenu *menu = [CCMenu menuWithItems:backButton, nil];
    menu.position = ccp(0, 0);
    [self addChild:menu];
}

-(void)checkIfPlayerGotDisconnectedFromMultiplayer {
    GameManager *gm = [GameManager sharedGameManager];
    BOOL checkForDisconnect = NO;
    
    if ((gm.isHost && gm.server) || (!gm.isHost && gm.client)) {
        checkForDisconnect = YES;
    }
    
    if (checkForDisconnect) {
        QuitReason quitReason;
        if (gm.isHost) {
            quitReason = gm.server.quitReason;
        } else {
            quitReason = gm.client.quitReason;
        }
        
        switch (quitReason) {
            case QuitReasonConnectionDropped: {
                CCLOG(@"Client was disconnected. Display UIAlertView");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disconnected" message:@"You were disconnected from the dance party." delegate:nil cancelButtonTitle:@"Oh, okay." otherButtonTitles:nil];
                
                [alert show];
                
                break;
            }
                
            case QuitReasonNoNetwork: {
                CCLOG(@"Client has no network. Display UIAlertView");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network" message:@"To use multiplayer, please enable Bluetooth or Wi-Fi." delegate:nil cancelButtonTitle:@"Oh, okay." otherButtonTitles:nil];
                
                [alert show];
                
                break;
            }
                
            default:
                break;
        }
        
        // set multiplayer properties to nil
        gm.server = nil;
        gm.client = nil;
    }
}

@end
