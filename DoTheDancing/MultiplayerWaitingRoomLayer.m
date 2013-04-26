//
//  MultiplayerWaitingRoomLayer.m
//  DoTheDancing
//
//  Created by Michael Gao on 4/25/13.
//
//

#import "MultiplayerWaitingRoomLayer.h"
#import "MatchmakingClient.h"
#import "MatchingmakingServer.h"
#import "Constants.h"
#import "GameManager.h"

@interface MultiplayerWaitingRoomLayer()

@property (nonatomic) CGSize screenSize;
//@property (nonatomic, strong) CCSpriteBatchNode *batchNode;

// matchmaking
@property (nonatomic, strong) MatchingmakingServer *server;
@property (nonatomic, strong) MatchmakingClient *client;
@property (nonatomic) BOOL isHost;

@end

@implementation MultiplayerWaitingRoomLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
//        self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet.pvr.ccz"];
//        [self addChild:self.batchNode];

        [self displayTemp];
        [self setupMatchmaking];
    }
    
    return self;
}

-(void)displayTemp {
    CCLabelTTF *multiplayerLabel = [CCLabelTTF labelWithString:@"Multiplayer Waiting Room" fontName:@"Helvetica" fontSize:24];
    multiplayerLabel.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.90);
    [self addChild:multiplayerLabel];
}

-(void)setupMatchmaking {
    self.isHost = [GameManager sharedGameManager].isHost;
    if (self.isHost) {
        CCLOG(@"host: start accepting connections");
        self.server = [[MatchingmakingServer alloc] init];
        [self.server startAcceptingConnectionsForSessionID:SESSION_ID];
    } else {
        CCLOG(@"client: start searching for host");
        self.client = [[MatchmakingClient alloc] init];
        [self.client startSearchingForServersWithSessionID:SESSION_ID];
    }
}

@end
