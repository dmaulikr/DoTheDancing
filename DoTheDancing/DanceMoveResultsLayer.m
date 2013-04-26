//
//  DanceMoveResultsLayer.m
//  LilD
//
//  Created by Michael Gao on 4/19/13.
//
//

#import "DanceMoveResultsLayer.h"
#import "GameManager.h"

@interface DanceMoveResultsLayer()

@property (nonatomic) CGSize screenSize;
//@property (nonatomic, strong) CCSpriteBatchNode *batchNode;
@property (nonatomic, strong) DanceMove *danceMove;

// sprite management
@property (nonatomic, strong) CCSprite *topBannerBg;

@end

@implementation DanceMoveResultsLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
//        self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet.pvr.ccz"];
//        [self addChild:self.batchNode];
        self.danceMove = [GameManager sharedGameManager].individualDanceMove;
        
        [self displayTopBar];
        [self displayResults];
        [self displayMenu];
    }
    
    return self;
}

-(void)displayTopBar {
    // top banner bg
    self.topBannerBg = [CCSprite spriteWithSpriteFrameName:@"instructions_top_banner.png"];
    self.topBannerBg.anchorPoint = ccp(0, 1);
    self.topBannerBg.position = ccp(0, self.screenSize.height);
    [self addChild:self.topBannerBg];
    
    // dance move name
    CCLabelBMFont *danceNameLabel = [CCLabelBMFont labelWithString:self.danceMove.name fntFile:@"economica-bold_64.fnt"];
    danceNameLabel.color = ccc3(249, 185, 56);
    danceNameLabel.position = ccp(self.screenSize.width * 0.5, self.topBannerBg.contentSize.height * 0.5);
    [self.topBannerBg addChild:danceNameLabel];
    
    // results label
    CCLabelBMFont *resultsLabel = [CCLabelBMFont labelWithString:@"RESULTS" fntFile:@"economica-italic_33.fnt"];
    resultsLabel.color = ccc3(249, 185, 56);
    resultsLabel.anchorPoint = ccp(1, 0.5);
    resultsLabel.position = ccp(self.screenSize.width * 0.97, self.topBannerBg.contentSize.height * 0.45);
    [self.topBannerBg addChild:resultsLabel];
}

-(void)displayResults {
    CGFloat positionY = self.screenSize.height * 0.81;
    NSArray *results = [GameManager sharedGameManager].danceMoveIterationResults;
    NSArray *currentIterationResults;
    BOOL isIterationCorrect;
    for (int i=0; i<results.count; i++) {
        /* add move label */
        CCSprite *moveLabelBg = [CCSprite spriteWithSpriteFrameName:@"results_cream_box.png"];
        moveLabelBg.anchorPoint = ccp(1, 0.5);
        moveLabelBg.position = ccp(self.screenSize.width * 0.54, positionY);
        [self addChild:moveLabelBg];
        
        CCLabelBMFont *moveLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Move %i", i+1] fntFile:@"economica-bold_64.fnt"];
        moveLabel.color = ccc3(56, 56, 56);
        moveLabel.position = ccp(moveLabelBg.contentSize.width * 0.5, moveLabelBg.contentSize.height * 0.5);
        [moveLabelBg addChild:moveLabel];
        
        /* add result */
        CCSprite *resultBg = [CCSprite spriteWithSpriteFrameName:@"results_orange_box.png"];
        resultBg.anchorPoint = ccp(0, 0.5);
        resultBg.position = moveLabelBg.position;
        [self addChild:resultBg];
        
        CCSprite *result;
        currentIterationResults = results[i];
        isIterationCorrect = YES;
        for (NSNumber *stepResult in currentIterationResults) {
            if ([stepResult boolValue] == NO) {
                isIterationCorrect = NO;
                break;
            }
        }
        if (isIterationCorrect == YES) {
            result = [CCSprite spriteWithSpriteFrameName:@"results_correct.png"];
        } else {
            result = [CCSprite spriteWithSpriteFrameName:@"results_incorrect.png"];
        }
        
        result.position = ccp(resultBg.contentSize.width * 0.5, resultBg.contentSize.height * 0.5);
        [resultBg addChild:result];
        
        // update position y
        positionY = positionY - resultBg.contentSize.height * 1.2;
    }
}

-(void)displayMenu {
    CCMenuItemSprite *mainMenuButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"results_button_mainmenu_left1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"results_button_mainmenu_left2.png"] block:^(id sender) {
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeDanceMoveSelection];
    }];
    mainMenuButton.anchorPoint = ccp(1, 0);
    mainMenuButton.position = ccp(self.screenSize.width * 0.545, self.screenSize.height * 0.02);
    
    CCMenuItemSprite *tryAgainButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"results_button_tryagain1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"results_button_tryagain2.png"] block:^(id sender) {
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeDanceMoveInstructions];
    }];
    tryAgainButton.anchorPoint= ccp(0, 0);
    tryAgainButton.position = ccp(self.screenSize.width * 0.52, mainMenuButton.position.y);
    
    CCMenu *menu = [CCMenu menuWithItems:mainMenuButton, tryAgainButton ,nil];
    menu.position = ccp(0, 0);
    [self addChild:menu];}

@end
