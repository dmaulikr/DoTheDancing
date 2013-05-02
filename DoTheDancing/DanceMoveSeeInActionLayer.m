//
//  DanceMoveSeeInActionLayer.m
//  LilD
//
//  Created by Michael Gao on 4/23/13.
//
//

#import "DanceMoveSeeInActionLayer.h"
#import "GameManager.h"
#import "DanceMove.h"

@interface DanceMoveSeeInActionLayer()

@property (nonatomic) CGSize screenSize;
@property (nonatomic, strong) CCSpriteBatchNode *batchNode;
@property (nonatomic, strong) DanceMove *danceMove;

// sprite management
@property (nonatomic, strong) CCLabelBMFont *movesCompletedCountLabel;
//@property (nonatomic, strong) NSMutableArray *moveTimers;
@property (nonatomic, strong) CCSprite *illustration;
@property (nonatomic, strong) CCLabelBMFont *countdownLabel;
//@property (nonatomic, strong) CCProgressTimer *currentIterationTimer;
@property (nonatomic, strong) CCLabelBMFont *stepCountLabel;
@property (nonatomic, strong) CCProgressTimer *stepTimer;
@property (nonatomic, strong) CCMenu *endMenu;

// illustration management
@property (nonatomic) CGFloat countdownElapsedTime;
@property (nonatomic) BOOL isCountdownActivated;
@property (nonatomic) NSInteger currentCountdownNum;
@property (nonatomic) BOOL isDanceActivated;
@property (nonatomic) CGFloat currentStepElapsedTime;
@property (nonatomic) CGFloat currentIterationElapsedTime;
@property (nonatomic) NSInteger currentStep;
@property (nonatomic) NSInteger currentIteration;
@property (nonatomic) CGFloat timeToMoveToNextStep;

@end

@implementation DanceMoveSeeInActionLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
        self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet.pvr.ccz"];
        [self addChild:self.batchNode];
        self.danceMove = [GameManager sharedGameManager].individualDanceMove;
        self.countdownElapsedTime = 0;
        
        self.isCountdownActivated = NO;
        self.currentCountdownNum = 3;
        self.isDanceActivated = NO;
        self.currentStepElapsedTime = 0;
        self.currentIterationElapsedTime = 0;
        self.currentStep = 1;
        self.currentIteration = 1;
        self.timeToMoveToNextStep = [self.danceMove.timePerSteps[0] floatValue];
        
        [self displayTopBar];
        [self displayMovesCompletedBar];
//        [self displayMovesTimer];
        [self displayIllustration];
        [self addStepLabelAndTimer];
        [self addMenu];
        
        // play background track
        [[GameManager sharedGameManager] playBackgroundTrack:self.danceMove.trackName];
        [self scheduleUpdate];
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
    
    // in action label
    CCLabelBMFont *inActionLabel = [CCLabelBMFont labelWithString:@"IN ACTION" fntFile:@"economica-italic_33.fnt"];
    inActionLabel.color = ccc3(249, 185, 56);
    inActionLabel.anchorPoint = ccp(1, 0.5);
    inActionLabel.position = ccp(self.screenSize.width * 0.97, topBannerBg.contentSize.height * 0.45);
    [topBannerBg addChild:inActionLabel];
}

-(void)displayMovesCompletedBar {
    // moves completed bg
    CCSprite *movesCompletedBg = [CCSprite spriteWithSpriteFrameName:@"inaction_creambg.png"];
    if (IS_IPHONE_4) {
        movesCompletedBg.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.85);
    } else {
        movesCompletedBg.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.87);
    }
    [self addChild:movesCompletedBg];
    
    // moves completed label
    CCLabelBMFont *movesCompletedLabel = [CCLabelBMFont labelWithString:@"Moves Completed:" fntFile:@"economica-bold_40.fnt"];
    movesCompletedLabel.color = ccc3(56, 56, 56);
    movesCompletedLabel.anchorPoint = ccp(0, 0.5);
    movesCompletedLabel.position = ccp(movesCompletedBg.contentSize.width * 0.07, movesCompletedBg.contentSize.height * 0.5);
    [movesCompletedBg addChild:movesCompletedLabel];
    
    // moves completed count
    self.movesCompletedCountLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"economica-bold_62.fnt"];
    self.movesCompletedCountLabel.color = ccc3(204, 133, 18);
    self.movesCompletedCountLabel.position = ccp(movesCompletedBg.contentSize.width * 0.63, movesCompletedLabel.position.y);
    [movesCompletedBg addChild:self.movesCompletedCountLabel];
    
    // out of label
    CCLabelBMFont *outOfLabel = [CCLabelBMFont labelWithString:@"out of" fntFile:@"adobeCaslonPro-bolditalic_38.fnt"];
    outOfLabel.color = self.movesCompletedCountLabel.color;
    outOfLabel.position = ccp(movesCompletedBg.contentSize.width * 0.76, movesCompletedLabel.position.y);
    [movesCompletedBg addChild:outOfLabel];
    
    // total moves label
    CCLabelBMFont *totalMovesLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", self.danceMove.numIndividualIterations] fntFile:@"economica-bold_62.fnt"];
    totalMovesLabel.color = self.movesCompletedCountLabel.color;
    totalMovesLabel.position = ccp(movesCompletedBg.contentSize.width * 0.90, movesCompletedLabel.position.y);
    [movesCompletedBg addChild:totalMovesLabel];
}

-(void)displayMovesTimer {
//    self.moveTimers = [[NSMutableArray alloc] initWithCapacity:self.danceMove.numIndividualIterations];
    
    CCSprite *tempTimer = [CCSprite spriteWithSpriteFrameName:@"inaction_bar_empty.png"];
    CGFloat timerPadding = 0;   // spacing between each timer
    CGFloat timerScaleX = 1;
    if (self.danceMove.numIndividualIterations > 1) {
        timerScaleX = 1/(float)self.danceMove.numIndividualIterations - 0.02;
        timerPadding = tempTimer.contentSize.width * (0.02 * self.danceMove.numIndividualIterations)/(self.danceMove.numIndividualIterations-1); //spacing between each timer
    }
    CGFloat positionX = self.screenSize.width * 0.09;
    CGFloat positionY = self.screenSize.height * 0.82;
    
    NSString *moveTimerEmptyFile;
    if (self.danceMove.numIndividualIterations == 1) {
        moveTimerEmptyFile = @"inaction_bar_empty.png";
    } else if (self.danceMove.numIndividualIterations == 2) {
        moveTimerEmptyFile = @"inaction_bar_empty2.png";
    } else if (self.danceMove.numIndividualIterations == 3) {
        moveTimerEmptyFile = @"inaction_bar_empty3.png";
    } else if (self.danceMove.numIndividualIterations == 4) {
        moveTimerEmptyFile = @"inaction_bar_empty4.png";
    } else {
        moveTimerEmptyFile = @"inaction_bar_empty5.png";
    }
    
    for (int i=0; i<self.danceMove.numIndividualIterations; i++) {
        // create new empty timer
        CCSprite *moveTimerEmpty = [CCSprite spriteWithSpriteFrameName:moveTimerEmptyFile];
        moveTimerEmpty.anchorPoint = ccp(0, 0.5);
        moveTimerEmpty.position = ccp(positionX, positionY);
        [self.batchNode addChild:moveTimerEmpty];
        
        // create new progress timer
        CCProgressTimer *moveTimer = [CCProgressTimer progressWithSprite:[CCSprite spriteWithSpriteFrameName:@"inaction_bar_filled.png"]];
        moveTimer.anchorPoint = ccp(0, 0.5);
        moveTimer.scaleX = timerScaleX;
        moveTimer.position = ccp(positionX, positionY);
        moveTimer.type = kCCProgressTimerTypeBar;
        moveTimer.midpoint = ccp(0, 0.5);
        moveTimer.barChangeRate = ccp(1, 0);
        moveTimer.percentage = 0;
        [self addChild:moveTimer z:10];
        
//        self.moveTimers[i] = moveTimer;
        
        positionX = positionX + moveTimerEmpty.boundingBox.size.width + timerPadding;
    }
    
//    self.currentIterationTimer = self.moveTimers[0];
}

-(void)displayIllustration {
    // init illustration with sign
    self.illustration = [CCSprite spriteWithSpriteFrameName:@"countdown_illustration.png"];
    if (IS_IPHONE_4) {
        self.illustration.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.45);
    } else {
        self.illustration.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.5);
    }
    [self.batchNode addChild:self.illustration];
    
    // display Ready? label
    self.countdownLabel = [CCLabelBMFont labelWithString:@"Watch &\nLearn" fntFile:@"economica-bold_102.fnt" width:self.illustration.contentSize.width * 0.7 alignment:kCCTextAlignmentCenter];
    self.countdownLabel.color = ccc3(56, 56, 56);
    self.countdownLabel.position = self.illustration.position;
    [self addChild:self.countdownLabel];
}

-(void)addStepLabelAndTimer {
    // add invisible step count label
    self.stepCountLabel = [CCLabelBMFont labelWithString:@"Step 1" fntFile:@"economica-bold_62.fnt"];
    self.stepCountLabel.color = ccc3(56, 56, 56);
    if (IS_IPHONE_4) {
        self.stepCountLabel.position = ccp(self.screenSize.width * 0.4, self.screenSize.height * 0.06);
    } else {
        self.stepCountLabel.position = ccp(self.screenSize.width * 0.4, self.screenSize.height * 0.14);
    }
    self.stepCountLabel.visible = NO;
    [self addChild:self.stepCountLabel];
    
    // add invisible step timer
    self.stepTimer = [CCProgressTimer progressWithSprite:[CCSprite spriteWithSpriteFrameName:@"inaction_timer.png"]];
    self.stepTimer.position = ccp(self.screenSize.width * 0.65, self.stepCountLabel.position.y);
    self.stepTimer.reverseDirection = YES;
    self.stepTimer.type = kCCProgressTimerTypeRadial;
    self.stepTimer.percentage = 100;
    self.stepTimer.visible = NO;
    if (IS_IPHONE_4) {
        self.stepTimer.scale = 0.7;
    }
    [self addChild:self.stepTimer];
}

-(void)addMenu {
    CCMenuItemSprite *tryItOutButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"inaction_button_try1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"inaction_button_try2.png"] block:^(id sender) {
        [[GameManager sharedGameManager] stopBackgroundTrack];
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeDanceMoveDance];
    }];
    tryItOutButton.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.72);
    
    CCMenuItemSprite *watchAgainButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"inaction_button_watchagain1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"inaction_button_watchagain2.png"] block:^(id sender) {
        [[GameManager sharedGameManager] stopBackgroundTrack];
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeDanceMoveSeeInAction];
    }];
    watchAgainButton.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.60);
    
    CCMenuItemSprite *instructionsButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"inaction_button_instructions1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"inaction_button_instructions2.png"] block:^(id sender) {
        [[GameManager sharedGameManager] stopBackgroundTrack];
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeDanceMoveInstructions];
    }];
    instructionsButton.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.48);
    
    self.endMenu = [CCMenu menuWithItems:tryItOutButton, watchAgainButton, instructionsButton, nil];
    self.endMenu.position = ccp(0, 0);
    self.endMenu.visible = NO;
    [self addChild:self.endMenu];
}

-(void)checkToStartCountdown {
    if (self.countdownElapsedTime >= self.danceMove.timeToStartCountdown) {
        self.isCountdownActivated = YES;
        // start countdown
        [self schedule:@selector(countdown) interval:self.danceMove.delayForCountdown];
    }
}

-(void)countdown {
    if (self.currentCountdownNum > 0) {
        self.countdownLabel.string = [NSString stringWithFormat:@"%i", self.currentCountdownNum];
        self.currentCountdownNum--;
    } else {
        [self unschedule:@selector(countdown)];
        /* start dance animation and timers */
        // remove countdown label
        [self.countdownLabel removeFromParentAndCleanup:YES];
        self.isDanceActivated = YES;
        self.stepCountLabel.visible = YES;
        self.stepTimer.visible = YES;
        [self updateIllustrations];
    }
}

-(void)updateTimers {
    // update bar timer for current iteration
//    self.currentIterationTimer.percentage = (self.currentIterationElapsedTime/self.danceMove.timePerIteration) * 100;
    self.stepTimer.percentage = 100.0 - ((self.currentStepElapsedTime/self.timeToMoveToNextStep) * 100);
    
    if (self.currentIterationElapsedTime >= self.danceMove.timePerIteration) {
        self.currentIterationElapsedTime = 0;
        self.currentStepElapsedTime = 0;
        if (self.currentIteration == self.danceMove.numIndividualIterations) {
            // end in action
            CCLOG(@"updateTimers: end in action");
            [self endInAction];
        } else {
            // move on to next iteration
            CCLOG(@"updateTimers: move on to next iteration");
            [self moveOnToNextIteration];
        }
    } else if (self.currentStepElapsedTime >= self.timeToMoveToNextStep) {
        CCLOG(@"updateTimers: move on to next step");   
        // move to next dance step
        self.currentStepElapsedTime = 0;
        [self moveOnToNextStep];
    }
}

-(void)endInAction {
    [self updateIterationCountWithNum:self.currentIteration];
    [self unscheduleUpdate];
    
    // remove illustration, step label, and step timer
    [self.illustration removeFromParentAndCleanup:YES];
    [self.stepCountLabel removeFromParentAndCleanup:YES];
    [self.stepTimer removeFromParentAndCleanup:YES];
    
    // display menu
    self.endMenu.visible = YES;
}

-(void)moveOnToNextIteration {
    self.currentIteration++;
    self.currentStep = 1;
    [self updateIterationCountWithNum:self.currentIteration-1];
    self.stepCountLabel.string = @"Step 1";
    self.currentIterationElapsedTime = 0;
    self.currentStepElapsedTime = 0;
    self.timeToMoveToNextStep = [self.danceMove.timePerSteps[0] floatValue];
    
    // move on to next iteration timer
//    self.currentIterationTimer = self.moveTimers[self.currentIteration-1];
    
    [self updateIllustrations];
}

-(void)updateIterationCountWithNum:(NSInteger)num {
    self.movesCompletedCountLabel.string = [NSString stringWithFormat:@"%i", num];
    // enlarge and shrink animation
    self.movesCompletedCountLabel.scale = 2.5;
    
    [self.movesCompletedCountLabel runAction:[CCScaleTo actionWithDuration:0.2 scale:1.0]];
}

-(void)moveOnToNextStep {
    if (self.currentStep < self.danceMove.numSteps) {
        self.currentStep++;
        self.timeToMoveToNextStep = [self.danceMove.timePerSteps[self.currentStep-1] floatValue];
        self.stepCountLabel.string = [NSString stringWithFormat:@"Step %i", self.currentStep];
        self.currentStepElapsedTime = 0;
        
        [self updateIllustrations];
    }
}

-(void)updateIllustrations {
    // stop any animations
    [self.illustration stopAllActions];
    
    /* update illustration */
    // check for animation
    NSArray *currentIllustrations = self.danceMove.illustrationsForSteps[self.currentStep-1];
    if (currentIllustrations.count > 1) {
        // animations!
        CCAnimation *animation = [CCAnimation animation];
        animation.restoreOriginalFrame = YES;
        animation.delayPerUnit = [self.danceMove.delayForIllustrationAnimations[self.currentStep-1] floatValue];
        for (NSString *frameName in currentIllustrations) {
            [animation addSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
        }
        
        id action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]];
        [self.illustration runAction:action];
    } else {
        // static illustraton
        self.illustration.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:currentIllustrations[0]];
    }
}

-(void)update:(ccTime)delta {
    // update dance timer, illustrations
    if (self.isDanceActivated == YES) {
        self.currentStepElapsedTime = self.currentStepElapsedTime + delta;
        self.currentIterationElapsedTime = self.currentIterationElapsedTime + delta;
        [self updateTimers];
    } else if (self.isCountdownActivated == NO) {
        self.countdownElapsedTime = self.countdownElapsedTime + delta;
        [self checkToStartCountdown];
    }
}

@end
