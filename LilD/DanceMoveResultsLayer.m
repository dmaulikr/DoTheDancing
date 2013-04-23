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

@end

@implementation DanceMoveResultsLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
        
        [self showResults];
        [self addMenu];
    }
    
    return self;
}

-(void)showResults {
    CCLabelTTF *resultsLabel = [CCLabelTTF labelWithString:@"Results" fontName:@"Helvetica" fontSize:38];
    resultsLabel.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.9);
    [self addChild:resultsLabel];
    
    int numIterations = [GameManager sharedGameManager].individualDanceMove.numIndividualIterations;
    CGFloat resultPadding = self.screenSize.width / (float)numIterations;
    CGPoint currentTitlePosition = ccp(resultPadding - resultPadding/2, self.screenSize.height * 0.5);
    
    for (int i=0; i<numIterations; i++) {
        CCLabelTTF *danceMoveTitle = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", i+1] fontName:@"Helvetica" fontSize:24];
        danceMoveTitle.position = currentTitlePosition;
        
        CCLabelTTF *danceMoveResult = [CCLabelTTF labelWithString:@"Yes" fontName:@"Helvetica" fontSize:24];
        if ([[GameManager sharedGameManager].danceMoveIterationResults[i] boolValue] == NO) {
            danceMoveResult.string = @"No";
        }
        danceMoveResult.position = ccp(currentTitlePosition.x, currentTitlePosition.y - self.screenSize.height * 0.1);
        
        currentTitlePosition = ccp(currentTitlePosition.x + resultPadding, currentTitlePosition.y);
        
        [self addChild:danceMoveTitle];
        [self addChild:danceMoveResult];
    }
}

-(void)addMenu {
    CCMenuItemLabel *tryAgainButton = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Try Again" fontName:@"Helvetica" fontSize:24] block:^(id sender) {
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeDanceMoveInstructions];
    }];
    tryAgainButton.position = ccp(self.screenSize.width * 0.25, self.screenSize.height * 0.2);
    
    CCMenuItemLabel *mainMenuButton = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Main Menu" fontName:@"Helvetica" fontSize:24] block:^(id sender) {
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeDanceMoveSelection];
    }];
    mainMenuButton.position = ccp(self.screenSize.width * 0.75, tryAgainButton.position.y);
    
    CCMenu *menu = [CCMenu menuWithItems:tryAgainButton, mainMenuButton, nil];
    menu.position = ccp(0, 0);
    
    [self addChild:menu];
}

@end
