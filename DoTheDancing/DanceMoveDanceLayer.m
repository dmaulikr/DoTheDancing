//
//  DanceMoveDanceLayer.m
//  LilD
//
//  Created by Michael Gao on 4/19/13.
//
//

#import "DanceMoveDanceLayer.h"
#import "GameManager.h"
#include <CoreMotion/CoreMotion.h>
#import <CoreFoundation/CoreFoundation.h>
#import "DanceMove.h"
#import "Constants.h"

@interface DanceMoveDanceLayer()

@property (nonatomic) CGSize screenSize;
@property (nonatomic, strong) CCSpriteBatchNode *batchNode;
@property (nonatomic, strong) DanceMove *danceMove;

// sprite management
@property (nonatomic, strong) CCLabelBMFont *movesCompletedCountLabel;
@property (nonatomic, strong) CCSprite *illustration;
@property (nonatomic, strong) CCLabelBMFont *countdownLabel;
@property (nonatomic, strong) CCLabelBMFont *stepCountLabel;
@property (nonatomic, strong) CCProgressTimer *stepTimer;

// motion detection
@property (nonatomic, strong) CMMotionManager *motionManager;

// countdown
@property (nonatomic) CGFloat countdownElapsedTime;
@property (nonatomic) BOOL isCountdownActivated;
@property (nonatomic) NSInteger currentCountdownNum;

// illustration management
@property (nonatomic) BOOL isDanceActivated;
@property (nonatomic) NSInteger currentIteration;
@property (nonatomic) NSInteger currentStep;
@property (nonatomic) NSInteger currentPart;
@property (nonatomic) CGFloat currentStepElapsedTime;
@property (nonatomic) CGFloat currentIterationElapsedTime;
@property (nonatomic) CGFloat timeToMoveToNextStep;

// results
@property (nonatomic) BOOL shouldDetectDanceMove;
@property (nonatomic, strong) NSArray *currentDanceStepParts;
@property (nonatomic, strong) NSMutableArray *currentIterationStepsDetected;
@property (nonatomic, strong) NSMutableArray *danceIterationStepsDetected;

@end

@implementation DanceMoveDanceLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
        self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet.pvr.ccz"];
        [self addChild:self.batchNode];
        self.danceMove = [GameManager sharedGameManager].individualDanceMove;
        
        [self initCountdown];
        [self initDanceMoveDetection];
        [self displayTopBar];
        [self displayMovesCompletedBar];
        [self displayIllustration];
        [self addStepLabelAndTimer];
        [self initMotionManager];

        // play background track
        [[GameManager sharedGameManager] playBackgroundTrack:self.danceMove.trackName];
        [self scheduleUpdate];
    }
    
    return self;
}

-(void)onExit {
    [self.motionManager stopDeviceMotionUpdates];
    [super onExit];
}

-(void)initCountdown {
    self.isDanceActivated = NO;
    self.isCountdownActivated = NO;
    self.countdownElapsedTime = 0;
    self.currentCountdownNum = 3;
}

-(void)initDanceMoveDetection {
    self.shouldDetectDanceMove = NO;
    self.currentIteration = 1;
    self.currentStep = 1;
    self.currentPart = 1;
    self.currentDanceStepParts = self.danceMove.stepsArray[0];
    self.danceIterationStepsDetected = [NSMutableArray arrayWithCapacity:self.danceMove.numIndividualIterations];
    [self resetCurrentIterationStepsDetected];
    self.timeToMoveToNextStep = [self.danceMove.timePerSteps[0] floatValue];
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
    
    // dance mode label
    CCLabelBMFont *danceModeLabel = [CCLabelBMFont labelWithString:@"DANCE MODE" fntFile:@"economica-italic_33.fnt"];
    danceModeLabel.color = ccc3(249, 185, 56);
    danceModeLabel.anchorPoint = ccp(1, 0.5);
    danceModeLabel.position = ccp(self.screenSize.width * 0.97, topBannerBg.contentSize.height * 0.45);
    [topBannerBg addChild:danceModeLabel];
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
    self.countdownLabel = [CCLabelBMFont labelWithString:@"Ready?" fntFile:@"economica-bold_126.fnt" width:self.illustration.contentSize.width * 0.7 alignment:kCCTextAlignmentCenter];
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

-(void)initMotionManager {    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 1.0/60.0f;
    //    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:(CMAttitudeReferenceFrameXArbitraryZVertical)];
    [self.motionManager startDeviceMotionUpdates];
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
        self.shouldDetectDanceMove = YES;
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
            CCLOG(@"updateTimers: segue to results");
            [self segueToResults];
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

-(void)moveOnToNextIteration {
    self.currentIteration++;
    self.currentStep = 1;
    self.currentPart = 1;
    self.shouldDetectDanceMove = YES;
    [self updateIterationCountWithNum:self.currentIteration-1];
    self.stepCountLabel.string = @"Step 1";
    self.timeToMoveToNextStep = [self.danceMove.timePerSteps[0] floatValue];
    self.currentDanceStepParts = self.danceMove.stepsArray[0];
    self.currentIterationElapsedTime = 0;
    self.currentStepElapsedTime = 0;
    
    [self.danceIterationStepsDetected addObject:self.currentIterationStepsDetected];
    [self resetCurrentIterationStepsDetected];
    
    [self updateIllustrations];
}

-(void)resetCurrentIterationStepsDetected {
    self.currentIterationStepsDetected = [NSMutableArray arrayWithCapacity:self.danceMove.numSteps];
    for (int i=0; i < self.danceMove.numSteps; i++) {
        self.currentIterationStepsDetected[i] = [NSNumber numberWithBool:NO];
    }
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
        self.currentDanceStepParts = self.danceMove.stepsArray[self.currentStep-1];
        self.currentPart = 1;
        self.shouldDetectDanceMove = YES;
        self.currentStepElapsedTime = 0;
        
        [self updateIllustrations];
    }
}

-(void)updateIllustrations {
    // stop any animations
    [self.illustration stopAllActions];
    
    // play step SFX
    if (self.currentStep == 1) {
        [[GameManager sharedGameManager] playSoundEffect:kStep1_SFX];
    } else if (self.currentStep == 2) {
        [[GameManager sharedGameManager] playSoundEffect:kStep2_SFX];
    }
    
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
        [self detectDancePart];
    } else if (self.isCountdownActivated == NO) {
        self.countdownElapsedTime = self.countdownElapsedTime + delta;
        [self checkToStartCountdown];
    }
}

-(void)detectDancePart {
    float yaw = (float)(CC_RADIANS_TO_DEGREES(self.motionManager.deviceMotion.attitude.yaw));
    float pitch = (float)(CC_RADIANS_TO_DEGREES(self.motionManager.deviceMotion.attitude.pitch));
    float roll = (float)(CC_RADIANS_TO_DEGREES(self.motionManager.deviceMotion.attitude.roll));
    CMAcceleration totalAcceleration = self.motionManager.deviceMotion.userAcceleration;
    
    if (self.shouldDetectDanceMove) {
        MotionRequirements *currentPartMotionRequirements = self.currentDanceStepParts[self.currentPart-1];
        if ((yaw > currentPartMotionRequirements.yawMin) &&
            (yaw < currentPartMotionRequirements.yawMax) &&
            (pitch > currentPartMotionRequirements.pitchMin) &&
            (pitch < currentPartMotionRequirements.pitchMax) &&
            (roll > currentPartMotionRequirements.rollMin) &&
            (roll < currentPartMotionRequirements.rollMax) &&
            (totalAcceleration.x > currentPartMotionRequirements.accelerationXMin) &&
            (totalAcceleration.x < currentPartMotionRequirements.accelerationXMax) &&
            (totalAcceleration.y > currentPartMotionRequirements.accelerationYMin) &&
            (totalAcceleration.y < currentPartMotionRequirements.accelerationYMax) &&
            (totalAcceleration.z > currentPartMotionRequirements.accelerationZMin) &&
            (totalAcceleration.z < currentPartMotionRequirements.accelerationZMax)) {
            CCLOG(@"iteration: %i, step: %i, part: %i detected", self.currentIteration, self.currentStep, self.currentPart);
            
            [self moveOnToNextPart];
        }
    }
}

-(void)moveOnToNextPart {
    if (self.currentPart == self.currentDanceStepParts.count) {
        // step detected!
        self.shouldDetectDanceMove = NO;
        CCLOG(@"Iteration: %i, Step: %i Successfully Detected!", self.currentIteration, self.currentStep);
        self.currentIterationStepsDetected[self.currentStep-1] = [NSNumber numberWithBool:YES];
    } else {
        // move on to next part
        self.currentPart++;
    }
}

-(void)segueToResults {
    // add last step results
    [self.danceIterationStepsDetected addObject:self.currentIterationStepsDetected];
    [self updateIterationCountWithNum:self.currentIteration];
    [self unscheduleUpdate];
    
    // pass results to game manager
    [GameManager sharedGameManager].danceMoveIterationResults = self.danceIterationStepsDetected;
    
    // segue to results scene
    [[GameManager sharedGameManager] stopBackgroundTrack];
    [[GameManager sharedGameManager] runSceneWithID:kSceneTypeDanceMoveResults];
}

@end
