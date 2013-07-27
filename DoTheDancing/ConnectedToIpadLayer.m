//
//  ConnectedToIpadLayer.m
//  DoTheDancing
//
//  Created by Michael Gao on 5/4/13.
//
//

#import "ConnectedToIpadLayer.h"
#import "GameManager.h"
#include <CoreMotion/CoreMotion.h>
#import <CoreFoundation/CoreFoundation.h>
#import "DanceMoveBernie.h"
#import "Constants.h"
#import "PacketSendResults.h"

@interface ConnectedToIpadLayer()

@property (nonatomic) CGSize screenSize;
@property (nonatomic, strong) DanceMove *danceMove;

// countdown
@property (nonatomic) CGFloat countdownElapsedTime;
@property (nonatomic) BOOL isCountdownActivated;
@property (nonatomic) NSInteger currentCountdownNum;

// dance detection
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic) BOOL isDanceActivated;
@property (nonatomic) NSInteger currentIteration;
@property (nonatomic) NSInteger currentStep;
@property (nonatomic) NSInteger currentPart;
@property (nonatomic) CGFloat currentStepElapsedTime;
@property (nonatomic) CGFloat currentIterationElapsedTime;
@property (nonatomic) CGFloat timeToMoveToNextStep;
@property (nonatomic) BOOL shouldDetectDanceMove;
@property (nonatomic, strong) NSArray *currentDanceStepParts;
@property (nonatomic, strong) NSMutableArray *currentIterationStepsDetected;
@property (nonatomic, strong) NSMutableArray *danceIterationStepsDetected;

@end

@implementation ConnectedToIpadLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        [GameManager sharedGameManager].client.delegate = self;
        self.screenSize = [CCDirector sharedDirector].winSize;
        
        [self displayPrompt];
        [self displayDisconnectButton];
    }
    
    return self;
}

-(void)displayPrompt {
    CCLabelTTF *promptLabel = [CCLabelTTF labelWithString:@"Follow iPad instructions" fontName:@"Helvetica" fontSize:26];
    promptLabel.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.7);
    [self addChild:promptLabel];
}

-(void)displayDisconnectButton {
    CCMenuItemLabel *disconnectButton = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Disconnect" fontName:@"Helvetica" fontSize:28] block:^(id sender) {
        [GameManager sharedGameManager].client.quitReason = QuitReasonNone;
        [[GameManager sharedGameManager].client disconnectFromServer];
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeMainMenu];
    }];
    disconnectButton.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.3);
    
    CCMenu *menu = [CCMenu menuWithItems:disconnectButton, nil];
    menu.position = ccp(0, 0);
    [self addChild:menu];
}

#pragma mark - MatchmakingClientDelegate methods
- (void)matchmakingClientDidConnectToServer:(NSString *)peerID {
    
}

- (void)matchmakingClientDidDisconnectFromServer:(NSString *)peerID {
    
}

- (void)matchmakingClientStartDanceMoveDanceWithDanceMoveType:(DanceMoves)danceMoveType {
    switch (danceMoveType) {
        case kDanceMoveBernie: {
            self.danceMove = [[DanceMoveBernie alloc] init];
            
            break;
        }
            
        default:
            break;
    }
    
    // start detection!!!
    [self initCountdown];
    [self initDanceMoveDetection];
    [self initMotionManager];
    [self scheduleUpdate];
}

#pragma mark - gameplay

-(void)initCountdown {
    self.isDanceActivated = NO;
    self.isCountdownActivated = NO;
    self.countdownElapsedTime = 0;
    self.currentCountdownNum = 3;
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
        self.currentCountdownNum--;
    } else {
        [self unschedule:@selector(countdown)];
        /* start dance animation and timers */
        // remove countdown label
        self.shouldDetectDanceMove = YES;
        self.isDanceActivated = YES;
    }
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

-(void)initMotionManager {
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 1.0/60.0f;
    [self.motionManager startDeviceMotionUpdates];
}

-(void)resetCurrentIterationStepsDetected {
    self.currentIterationStepsDetected = [NSMutableArray arrayWithCapacity:self.danceMove.numSteps];
    for (int i=0; i < self.danceMove.numSteps; i++) {
        self.currentIterationStepsDetected[i] = [NSNumber numberWithBool:NO];
    }
}

-(void)updateTimers {
    if (self.currentIterationElapsedTime >= self.danceMove.timePerIteration) {
        self.currentIterationElapsedTime = 0;
        self.currentStepElapsedTime = 0;
        if (self.currentIteration == self.danceMove.numIndividualIterations) {
            // end in action
            CCLOG(@"updateTimers: send packet with results to ipad");
            [self sendResultsToIpad];
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
    self.timeToMoveToNextStep = [self.danceMove.timePerSteps[0] floatValue];
    self.currentDanceStepParts = self.danceMove.stepsArray[0];
    self.currentIterationElapsedTime = 0;
    self.currentStepElapsedTime = 0;
    
    [self.danceIterationStepsDetected addObject:self.currentIterationStepsDetected];
    [self resetCurrentIterationStepsDetected];
}

-(void)moveOnToNextStep {
    if (self.currentStep < self.danceMove.numSteps) {
        self.currentStep++;
        self.timeToMoveToNextStep = [self.danceMove.timePerSteps[self.currentStep-1] floatValue];
        self.currentDanceStepParts = self.danceMove.stepsArray[self.currentStep-1];
        self.currentPart = 1;
        self.shouldDetectDanceMove = YES;
        self.currentStepElapsedTime = 0;
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

-(void)sendResultsToIpad {
    [self unscheduleUpdate];
    
    // add last step results
    [self.danceIterationStepsDetected addObject:self.currentIterationStepsDetected];
    
    // create packet with dance step results
    Packet *packet = [PacketSendResults packetWithDanceMoveResults:self.danceIterationStepsDetected];
    [[GameManager sharedGameManager].client sendPacketToServer:packet];
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

@end
