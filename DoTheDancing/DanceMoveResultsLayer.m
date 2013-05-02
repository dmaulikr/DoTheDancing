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
@property (nonatomic, strong) NSMutableArray *moveResultsArray;
@property (nonatomic, strong) NSMutableArray *stepResultsArray;
@property (nonatomic, strong) CCMenu *expandMenu;
@property (nonatomic) NSInteger lastClickedIndex;
@property (nonatomic) BOOL isResultExpanded;

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
    CCSprite *topBannerBg = [CCSprite spriteWithSpriteFrameName:@"instructions_top_banner.png"];
    topBannerBg.anchorPoint = ccp(0, 1);
    topBannerBg.position = ccp(0, self.screenSize.height);
    [self addChild:topBannerBg];
    
    // dance move name
    CCLabelBMFont *danceNameLabel = [CCLabelBMFont labelWithString:self.danceMove.name fntFile:@"economica-bold_64.fnt"];
    danceNameLabel.color = ccc3(249, 185, 56);
    danceNameLabel.position = ccp(self.screenSize.width * 0.5, topBannerBg.contentSize.height * 0.5);
    [topBannerBg addChild:danceNameLabel];
    
    // results label
    CCLabelBMFont *resultsLabel = [CCLabelBMFont labelWithString:@"RESULTS" fntFile:@"economica-italic_33.fnt"];
    resultsLabel.color = ccc3(249, 185, 56);
    resultsLabel.anchorPoint = ccp(1, 0.5);
    resultsLabel.position = ccp(self.screenSize.width * 0.97, topBannerBg.contentSize.height * 0.45);
    [topBannerBg addChild:resultsLabel];
}

-(void)displayResults {
    self.lastClickedIndex = self.danceMove.numIndividualIterations;
    self.isResultExpanded = NO;
    self.moveResultsArray = [NSMutableArray arrayWithCapacity:self.danceMove.numIndividualIterations];
    self.stepResultsArray = [NSMutableArray arrayWithCapacity:self.danceMove.numIndividualIterations];
    
    CGFloat positionY = self.screenSize.height * 0.68;
    NSArray *results = [GameManager sharedGameManager].danceMoveIterationResults;
    NSArray *currentIterationResults;
    BOOL isIterationCorrect;
    NSInteger numIterationsCorrect = 0;
    self.expandMenu = [CCMenu menuWithItems:nil];
    for (int i=0; i<results.count; i++) {
        // add results bg
        CCSprite *resultBg = [CCSprite spriteWithSpriteFrameName:@"results_cream_box.png"];
        resultBg.position = ccp(self.screenSize.width * 0.45, positionY);
        [self addChild:resultBg];
        
        // add move label
        CCLabelBMFont *moveLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Move %i", i+1] fntFile:@"economica-bold_64.fnt"];
        moveLabel.color = ccc3(56, 56, 56);
        moveLabel.anchorPoint = ccp(0, 0.5);
        moveLabel.position = ccp(resultBg.contentSize.width * 0.1, resultBg.contentSize.height * 0.5);
        [resultBg addChild:moveLabel];
        
        // add result
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
            numIterationsCorrect++;
            result = [CCSprite spriteWithSpriteFrameName:@"results_correct.png"];
            result.color = ccc3(154, 140, 41);
        } else {
            result = [CCSprite spriteWithSpriteFrameName:@"results_incorrect.png"];
            result.color = ccc3(153, 64, 32);
        }
        
        result.position = ccp(resultBg.contentSize.width * 0.8, resultBg.contentSize.height * 0.5);
        [resultBg addChild:result];
        
        /* add + button */
        CCMenuItemSprite *expandMovesButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"results_plus1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"results_plus2.png"] block:^(id sender) {
            CCSprite *tempSteps;
            CCSprite *tempMove;
            
            // nothing is currently expanded
            if (self.isResultExpanded == NO) {
                // switch button to minus
                CCMenuItemSprite *tempSender = (CCMenuItemSprite*)sender;
                tempSender.normalImage = [CCSprite spriteWithSpriteFrameName:@"results_minus1.png"];
                tempSender.selectedImage = [CCSprite spriteWithSpriteFrameName:@"results_minus2.png"];
                
                // move appropriate results down
                for (int j=i+1; j<self.danceMove.numIndividualIterations; j++) {
                    CCSprite *tempMove = self.moveResultsArray[j];
                    tempMove.position = ccp(tempMove.position.x, tempMove.position.y - tempMove.contentSize.height);
                    CCMenuItemSprite *tempButton = [self.expandMenu.children objectAtIndex:j];
                    tempButton.position = ccp(tempButton.position.x, tempMove.position.y);
                }
                
                // show step results
                tempSteps = self.stepResultsArray[i];
                tempSteps.visible = YES;
                
                self.isResultExpanded = YES;
                self.lastClickedIndex = i;
            } else {
                // switch previous clicked button to +
                CCMenuItemSprite *tempButton = [self.expandMenu.children objectAtIndex:self.lastClickedIndex];
                tempButton.normalImage = [CCSprite spriteWithSpriteFrameName:@"results_plus1.png"];
                tempButton.selectedImage = [CCSprite spriteWithSpriteFrameName:@"results_plus2.png"];
                
                // hide expanded results
                tempSteps = self.stepResultsArray[self.lastClickedIndex];
                tempSteps.visible = NO;
                
                // move results up
                for (int j=self.lastClickedIndex+1; j<self.danceMove.numIndividualIterations; j++) {
                    tempMove = self.moveResultsArray[j];
                    tempMove.position = ccp(tempMove.position.x, tempMove.position.y + tempMove.contentSize.height);
                    CCMenuItemSprite *tempButton = [self.expandMenu.children objectAtIndex:j];
                    tempButton.position = ccp(tempButton.position.x, tempMove.position.y);
                }
                
                // if clicking previously expanded result, only move appropriate results up and don't show any steps
                if (self.lastClickedIndex == i) {
                    self.isResultExpanded = NO;
                    self.lastClickedIndex = i;
                } else {
                    // else hide old steps, reset results to default position, move appropriate results down, show new steps
                    // switch new button to -
                    CCMenuItemSprite *tempSender = (CCMenuItemSprite*)sender;
                    tempSender.normalImage = [CCSprite spriteWithSpriteFrameName:@"results_minus1.png"];
                    tempSender.selectedImage = [CCSprite spriteWithSpriteFrameName:@"results_minus2.png"];
                    
                    // move appropriate results down
                    for (int j=i+1; j<self.danceMove.numIndividualIterations; j++) {
                        CCSprite *tempMove = self.moveResultsArray[j];
                        tempMove.position = ccp(tempMove.position.x, tempMove.position.y - tempMove.contentSize.height);
                        CCMenuItemSprite *tempButton = [self.expandMenu.children objectAtIndex:j];
                        tempButton.position = ccp(tempButton.position.x, tempMove.position.y);
                    }
                    
                    // show new steps
                    tempSteps = self.stepResultsArray[i];
                    tempSteps.visible = YES;
                    
                    self.isResultExpanded = YES;
                    self.lastClickedIndex = i;

                }
            }
        }];
        expandMovesButton.position = ccp(self.screenSize.width * 0.87, resultBg.position.y);
        [self.expandMenu addChild:expandMovesButton];
        
        /* add detailed step results */
        CCSprite *stepResultsBg = [CCSprite spriteWithSpriteFrameName:@"results_cream_box.png"];
        stepResultsBg.opacity = 100;
        stepResultsBg.position = ccp(resultBg.position.x, resultBg.position.y - resultBg.contentSize.height);
        
        // add steps label
        CCLabelBMFont *stepsLabel = [CCLabelBMFont labelWithString:@"Steps" fntFile:@"economica-bold_36.fnt"];
        stepsLabel.color = ccc3(56, 56, 56);
        stepsLabel.anchorPoint = ccp(0, 0.5);
        stepsLabel.position = ccp(stepResultsBg.contentSize.width * 0.1, stepResultsBg.contentSize.height * 0.75);
        [stepResultsBg addChild:stepsLabel];
        
        // add steps result circles
        for (int i=0; i<currentIterationResults.count; i++) {
            CCSprite *currentStepResultSprite = [CCSprite spriteWithSpriteFrameName:@"results_dot.png"];
            if ([currentIterationResults[i] boolValue] == YES) {
                // green dot
                currentStepResultSprite.color = ccc3(154, 140, 41);
            } else {
                currentStepResultSprite.color = ccc3(153, 64, 32);
            }
            currentStepResultSprite.anchorPoint = ccp(0, 0.5);
            currentStepResultSprite.position = ccp(stepsLabel.position.x + i*stepResultsBg.contentSize.width*0.15, stepResultsBg.contentSize.height * 0.30);
            [stepResultsBg addChild:currentStepResultSprite];
        }
        
        stepResultsBg.visible = NO;
        [self addChild:stepResultsBg];
        
        // add results to array
        self.moveResultsArray[i] = resultBg;
        self.stepResultsArray[i] = stepResultsBg;
        
        
        // update position y
        positionY = positionY - resultBg.contentSize.height * 1.2;
    }
    
    // add menu
    self.expandMenu.position = ccp(0, 0);
    [self addChild:self.expandMenu];
    
    // add message
    NSString *messageFile;
    if (numIterationsCorrect == self.danceMove.numIndividualIterations) {
        messageFile = @"results_nice_moves.png";
    } else if (numIterationsCorrect == (self.danceMove.numIndividualIterations - 1)) {
        messageFile = @"results_so_close.png";
    } else {
        messageFile = @"results_do_better.png";
    }
    
    
    CCSprite *messageSprite = [CCSprite spriteWithSpriteFrameName:messageFile];
    messageSprite.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.83);
    if (IS_IPHONE_4) {
        messageSprite.scale = 0.8;
    }
    [self addChild:messageSprite];
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
