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

@interface DanceMoveSelectionLayer()

@property (nonatomic) CGSize screenSize;

@end

@implementation DanceMoveSelectionLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        // load texture atlas
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"spritesheet.plist"];
        
        self.screenSize = [CCDirector sharedDirector].winSize;
        
        // set individual dance move to nil
        [GameManager sharedGameManager].individualDanceMove = nil;
        [self setUpListOfDanceMoves];
    }
    
    return self;
}

-(void)setUpListOfDanceMoves {
    CCMenuItemLabel *bernieButton = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:kDanceMoveBernieName fontName:@"Helvetica" fontSize:28] block:^(id sender) {
        // create bernie object and pass to instructions class
        [GameManager sharedGameManager].individualDanceMove = [[DanceMoveBernie alloc] init];
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeDanceMoveInstructions];
    }];
    bernieButton.anchorPoint = ccp(0, 0.5);
    bernieButton.position = ccp(self.screenSize.width * 0.05, self.screenSize.height * 0.9);
    
    CCMenu *danceMovesMenu = [CCMenu menuWithItems:bernieButton, nil];
    danceMovesMenu.position = ccp(0, 0);
    
    [self addChild:danceMovesMenu];
}

@end
