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
    
    // display results for 5 attempts
    CCLabelTTF *danceMove1Title = [CCLabelTTF labelWithString:@"1" fontName:@"Helvetica" fontSize:24];
    CCLabelTTF *danceMove2Title = [CCLabelTTF labelWithString:@"2" fontName:@"Helvetica" fontSize:24];
    CCLabelTTF *danceMove3Title = [CCLabelTTF labelWithString:@"3" fontName:@"Helvetica" fontSize:24];
    CCLabelTTF *danceMove4Title = [CCLabelTTF labelWithString:@"4" fontName:@"Helvetica" fontSize:24];
    CCLabelTTF *danceMove5Title = [CCLabelTTF labelWithString:@"5" fontName:@"Helvetica" fontSize:24];
    
    danceMove1Title.position = ccp(self.screenSize.width * 0.17, self.screenSize.height * 0.5);
    danceMove2Title.position = ccp(self.screenSize.width * 0.34, danceMove1Title.position.y);
    danceMove3Title.position = ccp(self.screenSize.width * 0.51, danceMove1Title.position.y);
    danceMove4Title.position = ccp(self.screenSize.width * 0.68, danceMove1Title.position.y);
    danceMove5Title.position = ccp(self.screenSize.width * 0.85, danceMove1Title.position.y);
    
    CCLabelTTF *danceMove1Result = [CCLabelTTF labelWithString:@"Yes" fontName:@"Helvetica" fontSize:24];
    CCLabelTTF *danceMove2Result = [CCLabelTTF labelWithString:@"Yes" fontName:@"Helvetica" fontSize:24];
    CCLabelTTF *danceMove3Result = [CCLabelTTF labelWithString:@"Yes" fontName:@"Helvetica" fontSize:24];
    CCLabelTTF *danceMove4Result = [CCLabelTTF labelWithString:@"Yes" fontName:@"Helvetica" fontSize:24];
    CCLabelTTF *danceMove5Result = [CCLabelTTF labelWithString:@"Yes" fontName:@"Helvetica" fontSize:24];
    
    GameManager *gm = [GameManager sharedGameManager];
    
    if (!gm.danceMove1Correct) {
        danceMove1Result.string = @"No";
    }
    if (!gm.danceMove2Correct) {
        danceMove2Result.string = @"No";
    }
    if (!gm.danceMove3Correct) {
        danceMove3Result.string = @"No";
    }
    if (!gm.danceMove4Correct) {
        danceMove4Result.string = @"No";
    }
    if (!gm.danceMove5Correct) {
        danceMove5Result.string = @"No";
    }
    
    danceMove1Result.position = ccp(danceMove1Title.position.x, self.screenSize.height * 0.4);
    danceMove2Result.position = ccp(danceMove2Title.position.x, self.screenSize.height * 0.4);
    danceMove3Result.position = ccp(danceMove3Title.position.x, self.screenSize.height * 0.4);
    danceMove4Result.position = ccp(danceMove4Title.position.x, self.screenSize.height * 0.4);
    danceMove5Result.position = ccp(danceMove5Title.position.x, self.screenSize.height * 0.4);
    
    [self addChild:danceMove1Title];
    [self addChild:danceMove2Title];
    [self addChild:danceMove3Title];
    [self addChild:danceMove4Title];
    [self addChild:danceMove5Title];
    
    [self addChild:danceMove1Result];
    [self addChild:danceMove2Result];
    [self addChild:danceMove3Result];
    [self addChild:danceMove4Result];
    [self addChild:danceMove5Result];
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
