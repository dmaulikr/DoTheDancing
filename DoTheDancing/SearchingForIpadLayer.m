//
//  SearchingForIpadLayer.m
//  DoTheDancing
//
//  Created by Michael Gao on 5/4/13.
//
//

#import "SearchingForIpadLayer.h"
#import "GameManager.h"

@interface SearchingForIpadLayer()

@property (nonatomic) CGSize screenSize;

@end

@implementation SearchingForIpadLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
        
        [self displaySearchingForIpad];
        [self displayBackButton];
        [self startSearchingForIpad];
    }
    
    return self;
}

-(void)displaySearchingForIpad {
    CCLabelTTF *searchingLabel = [CCLabelTTF labelWithString:@"Searching for iPad..." fontName:@"Helvetica" fontSize:32];
    searchingLabel.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.5);
    [self addChild:searchingLabel];
}

-(void)displayBackButton {
    CCMenuItemLabel *backButton = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Back" fontName:@"Helvetica" fontSize:28] block:^(id sender) {
        [GameManager sharedGameManager].client.quitReason = QuitReasonNone;
        [[GameManager sharedGameManager].client disconnectFromServer];
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeMainMenu];
    }];
    backButton.anchorPoint = ccp(0, 1);
    backButton.position = ccp(self.screenSize.width * 0.03, self.screenSize.height * 0.97);
    
    CCMenu *menu = [CCMenu menuWithItems:backButton, nil];
    menu.position = ccp(0, 0);
    [self addChild:menu];
}

-(void)startSearchingForIpad {
    GameManager *gm = [GameManager sharedGameManager];
    gm.client = [[MatchmakingClient alloc] init];
    gm.client.delegate = self;
    [gm.client startSearchingForServersWithSessionID:SESSION_ID_IPAD];
}

#pragma mark - MatchmakingClientDelegate methods
- (void)matchmakingClientDidConnectToServer:(NSString *)peerID {
    [[GameManager sharedGameManager] runSceneWithID:kSceneTypeConnectedToIpad];
}

- (void)matchmakingClientDidDisconnectFromServer:(NSString *)peerID {
    
}

@end
