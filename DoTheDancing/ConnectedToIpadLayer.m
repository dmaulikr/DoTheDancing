//
//  ConnectedToIpadLayer.m
//  DoTheDancing
//
//  Created by Michael Gao on 5/4/13.
//
//

#import "ConnectedToIpadLayer.h"
#import "GameManager.h"

@interface ConnectedToIpadLayer()

@property (nonatomic) CGSize screenSize;

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


@end
