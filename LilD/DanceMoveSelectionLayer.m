//
//  DanceMoveSelectionLayer.m
//  LilD
//
//  Created by Michael Gao on 4/19/13.
//
//

#import "DanceMoveSelectionLayer.h"
#import "GameManager.h"

@interface DanceMoveSelectionLayer()

@property (nonatomic) CGSize screenSize;

@end

@implementation DanceMoveSelectionLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
        
        [self setUpListOfDanceMoves];
    }
    
    return self;
}

-(void)setUpListOfDanceMoves {
    CCMenuItemLabel *bernieButton = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"The Bernie" fontName:@"Helvetica" fontSize:28] block:^(id sender) {
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeDanceMoveInstructions];
    }];
    bernieButton.anchorPoint = ccp(0, 0.5);
    bernieButton.position = ccp(self.screenSize.width * 0.05, self.screenSize.height * 0.9);
    
    CCMenu *danceMovesMenu = [CCMenu menuWithItems:bernieButton, nil];
    danceMovesMenu.position = ccp(0, 0);
    
    [self addChild:danceMovesMenu];
}

@end
