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
@property (nonatomic, strong) CCSprite *promptBg;
@property (nonatomic, strong) CCLabelBMFont *promptLabel;
@property (nonatomic, strong) CCMenu *startMenu;

// matchmaking
@property (nonatomic, strong) NSMutableArray *connectedPlayers;
@property (nonatomic, strong) NSMutableArray *playerAvatars;

@end

@implementation MultiplayerWaitingRoomLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
        self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet.pvr.ccz"];
        [self addChild:self.batchNode z:5];
        self.gm = [GameManager sharedGameManager];
        
        self.connectedPlayers = [NSMutableArray array];
        self.playerAvatars = [NSMutableArray array];
        
        /* for both host and client */
        [self displayBackground];
        [self displayTopBar];
        [self displayBackButton];
        
        /* host only */
        if (self.gm.isHost) {
            [self displayWaitingPrompt];
        } else {
        /* clients only */
            [self displayConnectingPrompt];
        }
        
        [self setupMatchmaking];

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
    self.promptBg = [CCSprite spriteWithSpriteFrameName:@"waitingroom_cream_box.png"];
    self.promptBg.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.7);
    [self addChild:self.promptBg];
    
    // label
    self.promptLabel = [CCLabelBMFont labelWithString:@"Waiting for other dancers..." fntFile:@"economica-bold_40.fnt"];
    self.promptLabel.color = ccc3(56, 56, 56);
    self.promptLabel.anchorPoint = ccp(0.5, 1);
    self.promptLabel.position = ccp(self.promptBg.contentSize.width * 0.5, self.promptBg.contentSize.height * 0.9);
    [self.promptBg addChild:self.promptLabel];
    
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

-(void)setupMatchmaking {
    if (self.gm.isHost) {
        CCLOG(@"host: start accepting connections");
        self.gm.server = [[MatchmakingServer alloc] init];
        self.gm.server.delegate = self;
        self.gm.server.quitReason = QuitReasonConnectionDropped;       // set up default quit reason
        [self.gm.server startAcceptingConnectionsForSessionID:SESSION_ID];
        
        [self.connectedPlayers addObject:self.gm.server.session.peerID];
        [self updateAvatars];
    } else {
        CCLOG(@"client: start searching for host");
        self.gm.client = [[MatchmakingClient alloc] init];
        self.gm.client.delegate = self;
        self.gm.client.quitReason = QuitReasonConnectionDropped;        // set up default quit reason
        [self.gm.client startSearchingForServersWithSessionID:SESSION_ID];
    }
}

-(void)updateAvatars {
    while (self.playerAvatars.count < self.connectedPlayers.count) {
        CCSprite *avatar = [CCSprite spriteWithSpriteFrameName:@"waitingroom_avatar1.png"];
        avatar.position = ccp(self.screenSize.width * 0.15 * (self.playerAvatars.count+1), self.screenSize.height * 0.4);
        [self.playerAvatars addObject:avatar];
        [self.batchNode addChild:avatar];
    }
}

-(void)displayConnectingPrompt {
    CCSprite *connectingSprite = [CCSprite spriteWithSpriteFrameName:@"waitingroom_connecting1.png"];
    connectingSprite.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.7);
    [self.batchNode addChild:connectingSprite];
    
    // animate logo
    CCAnimation *animation = [CCAnimation animation];
    animation.restoreOriginalFrame = YES;
    animation.delayPerUnit = 0.25;
    [animation addSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"waitingroom_connecting2.png"]];
    [animation addSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"waitingroom_connecting1.png"]];
    id action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]];
    [connectingSprite runAction:action];
}

#pragma mark - Server methods

- (void)sendPacketToAllClients:(Packet *)packet
{    
    [self.gm.server sendPacketToAllClients:packet];
}

-(void)hostRemoveWaitingAndDisplayStartPrompt {
    // remove loading dots
    [self.loadingDots removeFromParentAndCleanup:YES];
    
    // update label
    self.promptLabel.string = @"Ready to start the party when you are!";
    
    // add start button
    CCMenuItemSprite *startButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"waitingroom_button_start1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"waitingroom_button_start2.png"] block:^(id sender) {
        // placeholder
    }];
    startButton.anchorPoint = ccp(0.5, 0);
    startButton.position = ccp(self.promptBg.contentSize.width * 0.5, self.promptBg.contentSize.height * 0.1);
    
    self.startMenu = [CCMenu menuWithItems:startButton, nil];
    self.startMenu.position = ccp(0, 0);
    [self.promptBg addChild:self.startMenu];
}

#pragma mark - Client methods

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

- (void)matchmakingClientDidReceiveNewConnectedPeersList:(NSString*)peerString {
    // check if client just joined
    if (self.connectedPlayers.count == 0) {
        // player just joined -- remove connecting prompt
        [self.batchNode removeAllChildrenWithCleanup:YES];
        
        // add waiting for dancers prompt
        [self displayWaitingPrompt];
        
        // store new peers list in connectedPlayers array
        self.connectedPlayers = [[peerString componentsSeparatedByString:@","] mutableCopy];
        
        [self updateAvatars];
    }
}

#pragma mark - MatchmakingServerDelegate

- (void)matchmakingServerClientDidConnect:(NSString *)peerID
{
    [self.gm.server.connectedClients addObject:peerID];
    [self.connectedPlayers addObject:peerID];
    
    // update displayed avatars for host
    [self updateAvatars];
    
    // if >= 1 client is connected, remove "waiting" prompt for host
    if (self.loadingDots != nil && self.connectedPlayers.count > 1) {
        
    }
    
    /* update displayed avatars for all clients */
    NSString *connectedPlayersString = [self.connectedPlayers componentsJoinedByString:@","];
    Packet *packet = [PacketAddPlayerWaitingRoom packetWithPeerIDs:connectedPlayersString];
//    Packet *packet = [Packet packetWithType:PacketTypeAddPlayerWaitingRoom];
    [self sendPacketToAllClients:packet];
}

- (void)matchmakingServerClientDidDisconnect:(NSString *)peerID
{
    /* update displayed avatars for all clients */
    
    
    /* update displayed avatars for host */
    // remove temp label
    NSInteger peerAvatarIndex = 0;
    for (NSString *currentPeerId in self.connectedPlayers) {
        if ([currentPeerId isEqualToString:peerID]) {
//            CCLabelTTF *clientAvatar = self.connectedClientAvatars[peerAvatarIndex];
//            [clientAvatar removeFromParentAndCleanup:YES];
//            [self.connectedClientAvatars removeObjectAtIndex:peerAvatarIndex];
            
            break;
        }
        
        peerAvatarIndex++;
    }
    
    [self.connectedPlayers removeObjectAtIndex:peerAvatarIndex];
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
