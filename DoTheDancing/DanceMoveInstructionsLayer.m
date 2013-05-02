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
#import "CCTouchDownMenu.h"

@interface DanceMoveInstructionsLayer()

@property (nonatomic) CGSize screenSize;
@property (nonatomic, strong) CCSpriteBatchNode *batchNode;
@property (nonatomic, strong) DanceMove *danceMove;
@property (nonatomic) NSInteger currentShownStep;

// sprite management
@property (nonatomic, strong) CCSprite *illustration;
@property (nonatomic, strong) CCLabelBMFont *stepCountLabel;
@property (nonatomic, strong) CCLabelBMFont *instructionsLabel;
@property (nonatomic, strong) CCMenuItemSprite *leftArrowButton;
@property (nonatomic, strong) CCMenuItemSprite *rightArrowButton;

// swipe gesture recognizer
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRightRecognizer;

@end

@implementation DanceMoveInstructionsLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
        self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet.pvr.ccz"];
        [self addChild:self.batchNode];
        self.danceMove = [GameManager sharedGameManager].individualDanceMove;
        self.currentShownStep = 1;
        
        // play background track
        [[GameManager sharedGameManager] playBackgroundTrack:self.danceMove.trackName];
        
        [self displayTopBar];
        [self displayInitIllustration];
        [self displayInitInstructions];
        [self displayTouchDownMenu];
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
    
    // instructions label
    CCLabelBMFont *instructionsLabel = [CCLabelBMFont labelWithString:@"INSTRUCTIONS" fntFile:@"economica-italic_33.fnt"];
    instructionsLabel.color = ccc3(249, 185, 56);
    instructionsLabel.anchorPoint = ccp(1, 0.5);
    instructionsLabel.position = ccp(self.screenSize.width * 0.97, topBannerBg.contentSize.height * 0.45);
    [topBannerBg addChild:instructionsLabel];
}

-(void)displayInitIllustration {
    // initial image: step 1, part 1
    NSArray *step1Illustrations = self.danceMove.illustrationsForSteps[0];
    self.illustration = [CCSprite spriteWithSpriteFrameName:step1Illustrations[0]];
    self.illustration.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.63);
    
    if (IS_IPHONE_4) {
        self.illustration.scale = 0.75;
    }
    
    [self.batchNode addChild:self.illustration];
    
    // check for animation
    NSArray *currentIllustrations = self.danceMove.illustrationsForSteps[0];
    if (currentIllustrations.count > 1) {
        // animations!
        CCAnimation *animation = [CCAnimation animation];
        animation.restoreOriginalFrame = YES;
        animation.delayPerUnit = [self.danceMove.delayForIllustrationAnimations[0] floatValue];
        for (NSString *frameName in currentIllustrations) {
            [animation addSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
        }
        
        id action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]];
        [self.illustration runAction:action];
    }
}

-(void)displayInitInstructions {
    // instructions bg
    CCSprite *instructionsBg = [CCSprite spriteWithSpriteFrameName:@"instructions_bg.png"];
    instructionsBg.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.21);
    [self addChild:instructionsBg];
    
    // add two step count label lines
    CCSprite *line1 = [CCSprite spriteWithSpriteFrameName:@"instructions_line.png"];
    line1.anchorPoint = ccp(0, 0.5);
    line1.position = ccp(instructionsBg.contentSize.width * 0.05, instructionsBg.contentSize.height * 0.85);
    [instructionsBg addChild:line1];
    
    CCSprite *line2 = [CCSprite spriteWithSpriteFrameName:@"instructions_line.png"];
    line2.anchorPoint = ccp(1, 0.5);
    line2.position = ccp(instructionsBg.contentSize.width * 0.95, line1.position.y);
    [instructionsBg addChild:line2];
    
    // current step count label
    self.stepCountLabel = [CCLabelBMFont labelWithString:@"Step 1" fntFile:@"economica-bold_52.fnt"];
    self.stepCountLabel.color = ccc3(56, 56, 56);
    self.stepCountLabel.anchorPoint = ccp(1, 0.5);
    self.stepCountLabel.position = ccp(instructionsBg.contentSize.width * 0.52, line1.position.y);
    [instructionsBg addChild:self.stepCountLabel];
    
    // out of label
    CCLabelBMFont *outOfLabel = [CCLabelBMFont labelWithString:@"out of" fntFile:@"adobeCaslonPro-bolditalic_21.fnt"];
    outOfLabel.color = self.stepCountLabel.color;
    outOfLabel.position = ccp(instructionsBg.contentSize.width * 0.58, line1.position.y);
    [instructionsBg addChild:outOfLabel];
    
    // total step count label
    CCLabelBMFont *totalCountLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", self.danceMove.numSteps] fntFile:@"economica-bold_52.fnt"];
    totalCountLabel.color = self.stepCountLabel.color;
    totalCountLabel.position = ccp(instructionsBg.contentSize.width * 0.67, line1.position.y);
    [instructionsBg addChild:totalCountLabel];
    
    self.instructionsLabel = [CCLabelBMFont labelWithString:self.danceMove.instructionsForSteps[0] fntFile:@"economica_41.fnt" width:instructionsBg.contentSize.width * 0.90 alignment:kCCTextAlignmentCenter];
    self.instructionsLabel.color = self.stepCountLabel.color;
    self.instructionsLabel.anchorPoint = ccp(0.5, 1);
    self.instructionsLabel.position = ccp(instructionsBg.contentSize.width * 0.5, instructionsBg.contentSize.height * 0.65);
    [instructionsBg addChild:self.instructionsLabel];
    
    if (IS_IPHONE_4) {
        instructionsBg.scaleY = 0.95;
        instructionsBg.position = ccp(instructionsBg.position.x, self.screenSize.height * 0.23);
    }
}

-(void)displayTouchDownMenu {
    // only add arrows if there are more than 1 step
    if (self.danceMove.numSteps > 1) {
        
        self.leftArrowButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"instructions_arrow.png"] selectedSprite:nil block:^(id sender) {
            [self showPreviousStep];
        }];
        self.leftArrowButton.rotation = 180;
        self.leftArrowButton.opacity = 100;      // initialized in disabled mode
        self.leftArrowButton.position = ccp(self.screenSize.width * 0.1, self.illustration.position.y);
        
        self.rightArrowButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"instructions_arrow.png"] selectedSprite:nil block:^(id sender) {
            [self showNextStep];
        }];
        self.rightArrowButton.position = ccp(self.screenSize.width * 0.9, self.leftArrowButton.position.y);
        
        CCTouchDownMenu *menu = [CCTouchDownMenu menuWithItems:self.leftArrowButton, self.rightArrowButton, nil];
        menu.position = ccp(0, 0);
        [self addChild:menu];
    }
}

-(void)displayMenu {
    CCMenuItemSprite *backButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"instructions_button_back1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"instructions_button_back2.png"] block:^(id sender) {
        [[GameManager sharedGameManager] stopBackgroundTrack];
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeDanceMoveSelection];
    }];
    backButton.anchorPoint = ccp(0, 1);
    backButton.position = ccp(0, self.screenSize.height * 0.992);
    
    CCMenuItemSprite *seeInActionButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"instructions_button_action1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"instructions_button_action2.png"] block:^(id sender) {
        [[GameManager sharedGameManager] stopBackgroundTrack];
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeDanceMoveSeeInAction];
    }];
    seeInActionButton.anchorPoint = ccp(1, 0);
    seeInActionButton.position = ccp(self.screenSize.width * 0.57, self.screenSize.height * 0.03);
    
    CCMenuItemSprite *tryItOutButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"instructions_button_try1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"instructions_button_try2.png"] block:^(id sender) {
        [[GameManager sharedGameManager] stopBackgroundTrack];
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeDanceMoveDance];
    }];
    tryItOutButton.anchorPoint= ccp(0, 0);
    tryItOutButton.position = ccp(self.screenSize.width * 0.53, seeInActionButton.position.y);
    
    CCMenu *menu = [CCMenu menuWithItems:backButton, seeInActionButton, tryItOutButton, nil];
    menu.position = ccp(0, 0);
    [self addChild:menu];
}

-(void)updateInstructionsForNewStep {
    // stop any animations
    [self.illustration stopAllActions];
    
    /* update illustration */
    // check for animation
    NSArray *currentIllustrations = self.danceMove.illustrationsForSteps[self.currentShownStep-1];
    if (currentIllustrations.count > 1) {
        // animations!
        CCAnimation *animation = [CCAnimation animation];
        animation.restoreOriginalFrame = YES;
        animation.delayPerUnit = [self.danceMove.delayForIllustrationAnimations[self.currentShownStep-1] floatValue];
        for (NSString *frameName in currentIllustrations) {
            [animation addSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
        }
        
        id action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]];
        [self.illustration runAction:action];
    } else {
        // static illustraton
        self.illustration.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:currentIllustrations[0]];
    }
    
    // update step count
    self.stepCountLabel.string = [NSString stringWithFormat:@"Step %i", self.currentShownStep];
    
    // update instructions
    self.instructionsLabel.string = self.danceMove.instructionsForSteps[self.currentShownStep-1];
}

-(void)onEnter {
    [super onEnter];
    self.swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showNextStep)];
    self.swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [[CCDirector sharedDirector].view addGestureRecognizer:self.swipeLeftRecognizer];
    
    self.swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showPreviousStep)];
    self.swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [[CCDirector sharedDirector].view addGestureRecognizer:self.swipeRightRecognizer];
}

-(void)onExit {
    [[CCDirector sharedDirector].view removeGestureRecognizer:self.swipeLeftRecognizer];
    [[CCDirector sharedDirector].view removeGestureRecognizer:self.swipeRightRecognizer];
    self.swipeLeftRecognizer = nil;
    self.swipeRightRecognizer = nil;
    [super onExit];
}

-(void)showPreviousStep {
    // enabled only if current step > 1
    if (self.currentShownStep > 1) {
        self.currentShownStep--;
        self.rightArrowButton.opacity = 255;
        
        if (self.currentShownStep == 1) {
            self.leftArrowButton.opacity = 100;
        }
        
        [self updateInstructionsForNewStep];
    }
}

-(void)showNextStep {
    if (self.currentShownStep < self.danceMove.numSteps) {
        self.currentShownStep++;
        self.leftArrowButton.opacity = 255;
        
        if (self.currentShownStep == self.danceMove.numSteps) {
            self.rightArrowButton.opacity = 100;
        }
        
        [self updateInstructionsForNewStep];
    }
}

@end
