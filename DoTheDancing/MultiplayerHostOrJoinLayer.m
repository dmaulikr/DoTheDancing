//
//  MultiplayerHostOrJoinLayer.m
//  DoTheDancing
//
//  Created by Michael Gao on 4/25/13.
//
//

#import "MultiplayerHostOrJoinLayer.h"
#import "GameManager.h"

@interface MultiplayerHostOrJoinLayer()

@property (nonatomic) CGSize screenSize;
//@property (nonatomic, strong) CCSpriteBatchNode *batchNode;

@end

@implementation MultiplayerHostOrJoinLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
        //        self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet.pvr.ccz"];
        //        [self addChild:self.batchNode];
        
        [self displayTemp];
    }
    
    return self;
}

-(void)displayTemp {
    CCMenuItemLabel *hostButton = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Host a Dance Party!" fontName:@"Helvetica" fontSize:28] block:^(id sender) {
        [GameManager sharedGameManager].isHost = YES;
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeMultiplayerWaitingRoom];
    }];
    hostButton.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.7);
    
    CCMenuItemLabel *joinButton = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Join a Dance Party!" fontName:@"Helvetica" fontSize:28] block:^(id sender) {
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeMultiplayerWaitingRoom];
    }];
    joinButton.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.3);
    
    CCMenu *menu = [CCMenu menuWithItems:hostButton, joinButton, nil];
    menu.position = ccp(0, 0);
    
    [self addChild:menu];
}

@end
