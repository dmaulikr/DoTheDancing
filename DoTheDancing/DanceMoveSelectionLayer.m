//
//  DanceMoveSelectionLayer.m
//  LilD
//
//  Created by Michael Gao on 4/19/13.
//
//

#import "DanceMoveSelectionLayer.h"
#import "GameManager.h"
#import "DanceMoveBernie.h"
#import "CCTouchDownMenu.h"
#import "PacketSegueToDanceMoveInstructions.h"

@interface DanceMoveSelectionLayer()

@property (nonatomic) CGSize screenSize;
@property (nonatomic, strong) CCSpriteBatchNode *batchNode;

@end

@implementation DanceMoveSelectionLayer

-(id)init {
    CCLOG(@"DanceMoveSelectionLayer->init");
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
        self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet.pvr.ccz"];
        [self addChild:self.batchNode];
        
        // set individual dance move to nil
        [GameManager sharedGameManager].individualDanceMove = nil;
        
        [self displayTopBar];
        
        // if single player or host, display menu
        GameManager *gm = [GameManager sharedGameManager];
        if ((!gm.isMultiplayer) || (gm.isMultiplayer && gm.isHost)) {
            [self displayDanceMoves];
            [self displayPageLabels];
            [self displayMenu];
        } else {
            // set new delegate for client
            gm.client.delegate = self;
            // display waiting prompt
        }
    }
    
    return self;
}

-(void)displayTopBar {
    // top banner bg
    CCSprite *topBannerBg = [CCSprite spriteWithSpriteFrameName:@"instructions_top_banner.png"];
    topBannerBg.anchorPoint = ccp(0, 1);
    topBannerBg.position = ccp(0, self.screenSize.height);
    [self addChild:topBannerBg];
    
    // dance move name
    CCLabelBMFont *selectDanceLabel = [CCLabelBMFont labelWithString:@"Select Dance" fntFile:@"economica-bold_64.fnt"];
    selectDanceLabel.color = ccc3(249, 185, 56);
    selectDanceLabel.position = ccp(self.screenSize.width * 0.5, topBannerBg.contentSize.height * 0.5);
    [topBannerBg addChild:selectDanceLabel];
}

-(void)displayDanceMoves {
    /* bernie */
    CCMenuItemSprite *bernieButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"instructions_bg.png"] selectedSprite:nil block:^(id sender) {
        [self showInstructionsForDanceMove:kDanceMoveBernie];
    }];
    bernieButton.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.76);
    
    CCLabelBMFont *bernieLabel = [CCLabelBMFont labelWithString:@"Bernie" fntFile:@"economica-bold_62.fnt"];
    bernieLabel.color = ccc3(56, 56, 56);
    bernieLabel.position = ccp(bernieButton.contentSize.width * 0.5, bernieButton.contentSize.height * 0.82);
    [bernieButton addChild:bernieLabel];
    
    CCSprite *bernieImage = [CCSprite spriteWithSpriteFrameName:@"select_dance_bernie.png"];
    bernieImage.position = ccp(bernieButton.contentSize.width * 0.5, bernieButton.contentSize.height * 0.35);
    [bernieButton addChild:bernieImage];
    
    if (IS_IPHONE_4) {
        bernieButton.scaleY = 0.87;
    }
    
    /* peter griffin */
    CCMenuItemSprite *peterGriffinButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"instructions_bg.png"] selectedSprite:nil block:^(id sender) {
//        [self showInstructionsForDanceMove:kDanceMovePeterGriffin];
    }];
    peterGriffinButton.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.51);
    
    CCLabelBMFont *peterGriffinLabel = [CCLabelBMFont labelWithString:@"Peter Griffin" fntFile:@"economica-bold_62.fnt"];
    peterGriffinLabel.color = ccc3(56, 56, 56);
    peterGriffinLabel.position = ccp(bernieButton.contentSize.width * 0.5, bernieButton.contentSize.height * 0.82);
    [peterGriffinButton addChild:peterGriffinLabel];
    
    CCSprite *peterGriffinImage = [CCSprite spriteWithSpriteFrameName:@"select_dance_soon.png"];
    peterGriffinImage.position = ccp(bernieButton.contentSize.width * 0.5, bernieButton.contentSize.height * 0.35);
    [peterGriffinButton addChild:peterGriffinImage];
    
    if (IS_IPHONE_4) {
        peterGriffinButton.scaleY = 0.87;
    }
    
    /* cat daddy */
    CCMenuItemSprite *catDaddyButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"instructions_bg.png"] selectedSprite:nil block:^(id sender) {
//        [self showInstructionsForDanceMove:kDanceMoveCatDaddy];
    }];
    catDaddyButton.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.26);
    
    CCLabelBMFont *catDaddyLabel = [CCLabelBMFont labelWithString:@"Cat Daddy" fntFile:@"economica-bold_62.fnt"];
    catDaddyLabel.color = ccc3(56, 56, 56);
    catDaddyLabel.position = ccp(bernieButton.contentSize.width * 0.5, bernieButton.contentSize.height * 0.82);
    [catDaddyButton addChild:catDaddyLabel];
    
    CCSprite *catDaddyImage = [CCSprite spriteWithSpriteFrameName:@"select_dance_soon.png"];
    catDaddyImage.position = ccp(bernieButton.contentSize.width * 0.5, bernieButton.contentSize.height * 0.35);
    [catDaddyButton addChild:catDaddyImage];
    
    if (IS_IPHONE_4) {
        catDaddyButton.scaleY = 0.87;
    }
    
    // temporarily disable Peter Griffin & Cat Daddy
    peterGriffinButton.opacity = 100;
    peterGriffinImage.opacity = 100;
    peterGriffinLabel.opacity = 100;
    catDaddyButton.opacity = 100;
    catDaddyImage.opacity = 100;
    catDaddyLabel.opacity = 100;
    
    CCMenu *danceMovesMenu = [CCTouchDownMenu menuWithItems:bernieButton, peterGriffinButton, catDaddyButton, nil];
    danceMovesMenu.position = ccp(0, 0);
    
    [self addChild:danceMovesMenu];
}

-(void)showInstructionsForDanceMove:(DanceMoves)danceMoveType {
    if (danceMoveType != kDanceMoveNone) {
        DanceMove *danceMove;
        switch (danceMoveType) {
            case kDanceMoveBernie:
                danceMove = [[DanceMoveBernie alloc] init];
                break;
                
            default:
                CCLOG(@"showInstructionsForDanceMove: INVALID DANCE MOVE!");
                break;
        }
        
        // if multiplayer and host, send packet to clients
        GameManager *gm = [GameManager sharedGameManager];
        if (gm.isMultiplayer && gm.isHost) {
            Packet *packet = [PacketSegueToDanceMoveInstructions packetWithDanceMoveType:danceMoveType];
            [gm.server sendPacketToAllClients:packet];
        }
        
        // set selected dance move and display instructions
        gm.individualDanceMove = danceMove;
        [gm runSceneWithID:kSceneTypeDanceMoveInstructions];
    }
}

-(void)displayPageLabels {
    CCLabelBMFont *currentPageLabel = [CCLabelBMFont labelWithString:@"1" fntFile:@"economica-bold_62.fnt"];
    currentPageLabel.color = ccc3(56, 56, 56);
    currentPageLabel.position = ccp(self.screenSize.width * 0.39, self.screenSize.height * 0.08);
    [self addChild:currentPageLabel];
    
    CCLabelBMFont *outOfLabel = [CCLabelBMFont labelWithString:@"out of" fntFile:@"adobeCaslonPro-bolditalic_38.fnt"];
    outOfLabel.color = currentPageLabel.color;
    outOfLabel.position = ccp(self.screenSize.width * 0.5, currentPageLabel.position.y);
    [self addChild:outOfLabel];
    
    CCLabelBMFont *totalPageLabel = [CCLabelBMFont labelWithString:@"1" fntFile:@"economica-bold_62.fnt"];
    totalPageLabel.color = currentPageLabel.color;
    totalPageLabel.position = ccp(self.screenSize.width * 0.615, currentPageLabel.position.y);
    [self addChild:totalPageLabel];
}

-(void)displayMenu {
    CCMenuItemSprite *backButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"instructions_button_back1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"instructions_button_back2.png"] block:^(id sender) {
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeMainMenu];
    }];
    backButton.anchorPoint = ccp(0, 1);
    backButton.position = ccp(0, self.screenSize.height * 0.992);
    
    CCMenuItemSprite *prevButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"select_dance_button_prev1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"select_dance_button_prev2.png"] block:^(id sender) {
        
    }];
    prevButton.position = ccp(self.screenSize.width * 0.185, self.screenSize.height * 0.08);
    prevButton.isEnabled = NO;
    
    CCMenuItemSprite *nextButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"select_dance_button_next1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"select_dance_button_next2.png"] block:^(id sender) {
        
    }];
    nextButton.position = ccp(self.screenSize.width * 0.815, prevButton.position.y);
    nextButton.isEnabled = NO;
    
    
    // temporarily disable both buttons
    prevButton.opacity = 100;
    nextButton.opacity = 100;
    
    CCMenu *menu = [CCMenu menuWithItems:backButton, prevButton, nextButton, nil];
    menu.position = ccp(0, 0);
    
    [self addChild:menu];
}

# pragma mark - MatchmakingClient delegate methods
- (void)matchmakingClientSegueToInstructionsWithDanceMoveType:(DanceMoves)danceMoveType {
    [self showInstructionsForDanceMove:danceMoveType];
}

@end
