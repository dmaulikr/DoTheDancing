//
//  MultiplayerWaitingRoomLayer.m
//  DoTheDancing
//
//  Created by Michael Gao on 4/25/13.
//
//

#import "MultiplayerWaitingRoomLayer.h"
#import "Constants.h"
#import "GameManager.h"
#import "Packet.h"
#import "PacketAddPlayerWaitingRoom.h"

@interface MultiplayerWaitingRoomLayer()

@property (nonatomic) CGSize screenSize;
@property (nonatomic, strong) CCSpriteBatchNode *batchNode;
@property (nonatomic, strong) GameManager *gm;

// sprite management
@property (nonatomic, strong) CCSprite *loadingDots;

// matchmaking
@property (nonatomic, strong) NSMutableArray *connectedClientAvatars;
@property (nonatomic, strong) CCLabelTTF *hostAvatar;

@end

@implementation MultiplayerWaitingRoomLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
        self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet.pvr.ccz"];
        [self addChild:self.batchNode z:5];
        self.gm = [GameManager sharedGameManager];
        
        /* for both host and client */
        [self displayBackground];
        [self displayTopBar];
        [self displayBackButton];
        
        /* host only */
        if (self.gm.isHost) {
            [self displayWaitingPrompt];
        } else {
        /* clients only */
            
        }

//        if (self.gm.isHost == NO) {
//            [self displayClientTemp];
//        } else {
//            [self displayHostTemp];
//        }
//        [self setupMatchmaking];
    }
    
    return self;
}

-(void)displayBackground {
    CCSprite *bg = [CCSprite spriteWithFile:@"mainmenu_bg.png"];
    bg.anchorPoint = ccp(0.5, 1);
    bg.position = ccp(self.screenSize.width * 0.5, self.screenSize.height);
    [self addChild:bg z:-1];
}

-(void)displayTopBar {
    // top banner bg
    CCSprite *topBannerBg = [CCSprite spriteWithSpriteFrameName:@"instructions_top_banner.png"];
    topBannerBg.anchorPoint = ccp(0, 1);
    topBannerBg.position = ccp(0, self.screenSize.height);
    [self addChild:topBannerBg];
    
    // multiplayer label
    CCLabelBMFont *multiplayerLabel = [CCLabelBMFont labelWithString:@"Waiting Room" fntFile:@"economica-bold_64.fnt"];
    multiplayerLabel.color = ccc3(249, 185, 56);
    multiplayerLabel.position = ccp(self.screenSize.width * 0.5, topBannerBg.contentSize.height * 0.5);
    [topBannerBg addChild:multiplayerLabel];
}

-(void)displayBackButton {
    CCMenuItemSprite *backButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"instructions_button_back1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"instructions_button_back2.png"] block:^(id sender) {
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeMultiplayerHostOrJoin];
    }];
    backButton.anchorPoint = ccp(0, 1);
    backButton.position = ccp(0, self.screenSize.height * 0.992);
    
    CCMenu *menu = [CCMenu menuWithItems:backButton, nil];
    menu.position = ccp(0, 0);
    [self addChild:menu];
}

-(void)displayWaitingPrompt {
    // background
    CCSprite *waitingBg = [CCSprite spriteWithSpriteFrameName:@"waitingroom_cream_box.png"];
    waitingBg.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.7);
    [self addChild:waitingBg];
    
    // label
    CCLabelBMFont *waitingLabel = [CCLabelBMFont labelWithString:@"Waiting for other dancers..." fntFile:@"economica-bold_40.fnt"];
    waitingLabel.color = ccc3(56, 56, 56);
    waitingLabel.anchorPoint = ccp(0.5, 1);
    waitingLabel.position = ccp(waitingBg.contentSize.width * 0.5, waitingBg.contentSize.height * 0.9);
    [waitingBg addChild:waitingLabel];
    
    // loading dots
    self.loadingDots = [CCSprite spriteWithSpriteFrameName:@"waitingroom_loader1.png"];
    self.loadingDots.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.7);
    [self.batchNode addChild:self.loadingDots];
    
    // animate loading dots
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:@[[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"waitingroom_loader1.png"],
                                                                      [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"waitingroom_loader2.png"],
                                                                      [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"waitingroom_loader3.png"],
                                                                      [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"waitingroom_loader4.png"],
                                                                      [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"waitingroom_loader5.png"]]
                                                              delay:0.5];
    animation.restoreOriginalFrame = YES;
    id action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]];
    [self.loadingDots runAction:action];
}

-(void)displayHostTemp {
    CCLabelTTF *multiplayerLabel = [CCLabelTTF labelWithString:@"Multiplayer Waiting Room" fontName:@"Helvetica" fontSize:24];
    multiplayerLabel.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.80);
    [self addChild:multiplayerLabel];
    
    CCMenuItemLabel *backButton = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Back" fontName:@"Helvetica" fontSize:20] block:^(id sender) {
        // set appropriate quit reason
        if (self.gm.isHost) {
            self.gm.server.quitReason = QuitReasonUserQuit;
        } else {
            self.gm.client.quitReason = QuitReasonUserQuit;
        }
        [self.gm runSceneWithID:kSceneTypeMultiplayerHostOrJoin];
    }];
    backButton.anchorPoint = ccp(0, 1);
    backButton.position = ccp(self.screenSize.width * 0.03, self.screenSize.height * 0.97);
    
    CCMenu *menu = [CCMenu menuWithItems:backButton, nil];
    menu.position = ccp(0, 0);
    [self addChild:menu];
}

-(void)displayClientTemp {
    CCLabelTTF *multiplayerLabel = [CCLabelTTF labelWithString:@"Connecting..." fontName:@"Helvetica" fontSize:28];
    multiplayerLabel.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.5);
    [self addChild:multiplayerLabel];
    
    CCMenuItemLabel *backButton = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Back" fontName:@"Helvetica" fontSize:20] block:^(id sender) {
        // set appropriate quit reason
        if (self.gm.isHost) {
            self.gm.server.quitReason = QuitReasonUserQuit;
        } else {
            self.gm.client.quitReason = QuitReasonUserQuit;
        }
        [self.gm runSceneWithID:kSceneTypeMultiplayerHostOrJoin];
    }];
    backButton.anchorPoint = ccp(0, 1);
    backButton.position = ccp(self.screenSize.width * 0.03, self.screenSize.height * 0.97);
    
    CCMenu *menu = [CCMenu menuWithItems:backButton, nil];
    menu.position = ccp(0, 0);
    [self addChild:menu];
}

-(void)setupMatchmaking {
    if (self.gm.isHost) {
        CCLOG(@"host: start accepting connections");
        self.connectedClientAvatars = [NSMutableArray array];
        self.gm.server = [[MatchmakingServer alloc] init];
        self.gm.server.delegate = self;
        self.gm.server.quitReason = QuitReasonConnectionDropped;       // set up default quit reason
        [self.gm.server startAcceptingConnectionsForSessionID:SESSION_ID];
        
        // add host label
        self.hostAvatar = [CCLabelTTF labelWithString:@"1" fontName:@"Helvetica" fontSize:24];
        self.hostAvatar.position = ccp(self.screenSize.width * 0.2, self.screenSize.height * 0.75);
        [self addChild:self.hostAvatar];
    } else {
        CCLOG(@"client: start searching for host");
        self.gm.client = [[MatchmakingClient alloc] init];
        self.gm.client.delegate = self;
        self.gm.client.quitReason = QuitReasonConnectionDropped;        // set up default quit reason
        [self.gm.client startSearchingForServersWithSessionID:SESSION_ID];
    }
}

#pragma mark - Server networking

- (void)sendPacketToAllClients:(Packet *)packet
{    
    [self.gm.server sendPacketToAllClients:packet];
}

#pragma mark - MatchmakingClientDelegate

- (void)matchmakingClientServerBecameAvailable:(NSString *)peerID
{
    
}

- (void)matchmakingClientServerBecameUnavailable:(NSString *)peerID
{
    
}

- (void)matchmakingClientDidConnectToServer:(NSString *)peerID
{
    
}

- (void)matchmakingClientDidDisconnectFromServer:(NSString *)peerID
{
    // return to host or join page
    [[GameManager sharedGameManager] runSceneWithID:kSceneTypeMultiplayerHostOrJoin];
}

- (void)matchmakingClientNoNetwork
{
    self.gm.client.quitReason = QuitReasonNoNetwork;
}

#pragma mark - MatchmakingServerDelegate

- (void)matchmakingServerClientDidConnect:(NSString *)peerID
{
    [self.gm.server.connectedClients addObject:peerID];
    
    // update displayed avatars for host
    
    NSInteger peerAvatarNum = 2;
    for (NSString *currentPeerId in self.gm.server.connectedClients) {
        if ([currentPeerId isEqualToString:peerID]) {
            break;
        }
        
        peerAvatarNum++;
    }
    
    // add temp label
    CCLabelTTF *tempClientNumLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", peerAvatarNum] fontName:@"Helvetica" fontSize:24];
    tempClientNumLabel.position = ccp(self.screenSize.width * 0.2 * peerAvatarNum, self.screenSize.height * 0.75);
    [self addChild:tempClientNumLabel];
    
    [self.connectedClientAvatars addObject:tempClientNumLabel];
    
    /* update displayed avatars for all clients */
//    Packet *packet = [Packet packetWithType:PacketTypeAddPlayerWaitingRoom];
    NSMutableString *hostAndPeerIDsString = [NSMutableString stringWithString:self.gm.server.session.peerID];
    Packet *packet = [PacketAddPlayerWaitingRoom packetWithPeerIDs:hostAndPeerIDsString];
    [self sendPacketToAllClients:packet];
}

- (void)matchmakingServerClientDidDisconnect:(NSString *)peerID
{
    /* update displayed avatars for all clients */
    
    
    /* update displayed avatars for host */
    // remove temp label
    NSInteger peerAvatarIndex = 0;
    for (NSString *currentPeerId in self.gm.server.connectedClients) {
        if ([currentPeerId isEqualToString:peerID]) {
            CCLabelTTF *clientAvatar = self.connectedClientAvatars[peerAvatarIndex];
            [clientAvatar removeFromParentAndCleanup:YES];
            [self.connectedClientAvatars removeObjectAtIndex:peerAvatarIndex];
            
            break;
        }
        
        peerAvatarIndex++;
    }
    
    [self.gm.server.connectedClients removeObjectAtIndex:peerAvatarIndex];
}

- (void)matchmakingServerSessionDidEnd
{    
    // return to host or join page
    [[GameManager sharedGameManager] runSceneWithID:kSceneTypeMultiplayerHostOrJoin];
}

- (void)matchmakingServerNoNetwork
{
    self.gm.server.quitReason = QuitReasonNoNetwork;
}

@end
