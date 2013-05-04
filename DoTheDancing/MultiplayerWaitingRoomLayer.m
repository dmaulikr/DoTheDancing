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
#import "PacketRemovePlayerWaitingRoom.h"

@interface MultiplayerWaitingRoomLayer()

@property (nonatomic) CGSize screenSize;
@property (nonatomic, strong) CCSpriteBatchNode *batchNode;
@property (nonatomic, strong) GameManager *gm;

// sprite management
@property (nonatomic, strong) CCSprite *loadingDots;
@property (nonatomic, strong) CCSprite *promptBg;
@property (nonatomic, strong) CCLabelBMFont *promptLabel;
@property (nonatomic, strong) CCMenu *startMenu;
@property (nonatomic, strong) CCSprite *youSign;

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
        if (self.gm.isHost) {
            self.gm.server.quitReason = QuitReasonUserQuit;
        } else {
            self.gm.client.quitReason = QuitReasonUserQuit;
        }
        
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
    self.promptBg = [CCSprite spriteWithSpriteFrameName:@"instructions_bg.png"];
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
    // check if peer was just added
    BOOL shouldAddYouSign = NO;
    // add host label to first avatar
    if (self.playerAvatars.count == 0) {
        shouldAddYouSign = YES;
        CCSprite *tempAvatar = [CCSprite spriteWithSpriteFrameName:@"waitingroom_avatar1.png"];
        
        CCSprite *hostSign = [CCSprite spriteWithSpriteFrameName:@"waitingroom_label_host.png"];
        hostSign.anchorPoint = ccp(0.5, 0);
        if (IS_IPHONE_4) {
            hostSign.position = ccp(self.screenSize.width * 0.15, self.screenSize.height * 0.35 + tempAvatar.contentSize.height * 0.5);
        } else {
            hostSign.position = ccp(self.screenSize.width * 0.15, self.screenSize.height * 0.4 + tempAvatar.contentSize.height * 0.5);
        }
        [self.batchNode addChild:hostSign];
    }
    
    while (self.playerAvatars.count < self.connectedPlayers.count) {
        CCSprite *avatar = [CCSprite spriteWithSpriteFrameName:@"waitingroom_avatar1.png"];
        if (IS_IPHONE_4) {
            avatar.position = ccp(self.screenSize.width * 0.15 * (self.playerAvatars.count+1), self.screenSize.height * 0.35);
        } else {
            avatar.position = ccp(self.screenSize.width * 0.15 * (self.playerAvatars.count+1), self.screenSize.height * 0.4);
        }
        [self.playerAvatars addObject:avatar];
        [self.batchNode addChild:avatar];
    }
    
    if (shouldAddYouSign) {
        CCSprite *tempAvatar = [CCSprite spriteWithSpriteFrameName:@"waitingroom_avatar1.png"];
        
        self.youSign = [CCSprite spriteWithSpriteFrameName:@"waitingroom_label_you.png"];
        self.youSign.anchorPoint = ccp(0.5, 1);
        if (IS_IPHONE_4) {
            self.youSign.position = ccp(self.screenSize.width * 0.15 * self.playerAvatars.count, self.screenSize.height * 0.35 - tempAvatar.contentSize.height * 0.5);
        } else {
            self.youSign.position = ccp(self.screenSize.width * 0.15 * self.playerAvatars.count, self.screenSize.height * 0.4 - tempAvatar.contentSize.height * 0.5);
        }
        [self.batchNode addChild:self.youSign];
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
    self.loadingDots = nil;
    
    // update label
    self.promptLabel.string = @"Ready when you are!";
    
    // add start button
    if (!self.startMenu) {
        CCMenuItemSprite *startButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"waitingroom_button_start1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"waitingroom_button_start2.png"] block:^(id sender) {
            if (self.gm.isHost) {
                // tell server to stop accepting connections if host
                [self.gm.server stopAcceptingConnections];
                
                // notify all clients
                Packet *packet = [Packet packetWithType:PacketTypeSegueToDanceMoveSelection];
                [self sendPacketToAllClients:packet];
                
                // segue to dance move selection!
                [[GameManager sharedGameManager] runSceneWithID:kSceneTypeDanceMoveSelection];
            }
        }];
        startButton.anchorPoint = ccp(0.5, 0);
        startButton.position = ccp(self.promptBg.contentSize.width * 0.5, self.promptBg.contentSize.height * 0.1);
        
        self.startMenu = [CCMenu menuWithItems:startButton, nil];
        self.startMenu.position = ccp(0, 0);
    }
    [self.promptBg addChild:self.startMenu];
}

-(void)hostRemoveStartAndDisplayWaitingPrompt {
    // remove start menu
    [self.startMenu removeFromParentAndCleanup:YES];
    
    // update label
    self.promptLabel.string = @"Waiting for other dancers...";
    
    // display loading dots with animation
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
    }
    
    // store new peers list in connectedPlayers array
    self.connectedPlayers = [[peerString componentsSeparatedByString:@","] mutableCopy];
    
    [self updateAvatars];
}

- (void)matchmakingClientDidReceiveIndexOfRemovedClient:(NSInteger)peerIndex {
    NSInteger indexOfCurrentClient;
    NSInteger currentIndex = 0;
    for (NSString *currentClientID in self.connectedPlayers) {
        if ([currentClientID isEqualToString:self.gm.client.session.peerID]) {
            indexOfCurrentClient = currentIndex;
            
            break;
        }
        currentIndex++;
    }
    
    // remove client's avatar and shift proceeding avatars to the left
    CCSprite *removedClientAvatar = self.playerAvatars[peerIndex];
    [removedClientAvatar removeFromParentAndCleanup:YES];
    
    for (int i=peerIndex+1; i<self.playerAvatars.count; i++) {
        CCSprite *currentAvatar = self.playerAvatars[i];
        currentAvatar.position = ccp(currentAvatar.position.x - self.screenSize.width * 0.15, currentAvatar.position.y);
        
        // check to move 'you' sign
        if ([self.connectedPlayers[i] isEqualToString:self.gm.client.session.peerID]) {
            self.youSign.position = ccp(currentAvatar.position.x, self.youSign.position.y);
        }
    }
    
    // remove client from array
    [self.connectedPlayers removeObjectAtIndex:peerIndex];
    [self.playerAvatars removeObjectAtIndex:peerIndex];
}

- (void)matchmakingClientSegueToSelectDanceMove {
    CCLOG(@"preparing to segue to select dance move");
    [[GameManager sharedGameManager] runSceneWithID:kSceneTypeDanceMoveSelection];
    CCLOG(@"finished to segue to select dance move");
}

#pragma mark - MatchmakingServerDelegate

- (void)matchmakingServerClientDidConnect:(NSString *)peerID
{
    [self.connectedPlayers addObject:peerID];
    
    // update displayed avatars for host
    [self updateAvatars];
    
    // if >= 1 client is connected, remove "waiting" prompt for host
    if (self.loadingDots != nil && self.connectedPlayers.count > 1) {
        [self hostRemoveWaitingAndDisplayStartPrompt];
    }
    
    /* update displayed avatars for all clients */
    NSString *connectedPlayersString = [self.connectedPlayers componentsJoinedByString:@","];
    Packet *packet = [PacketAddPlayerWaitingRoom packetWithPeerIDs:connectedPlayersString];
    [self sendPacketToAllClients:packet];
}

- (void)matchmakingServerClientDidDisconnect:(NSString *)peerID
{
    /* update displayed avatars for host */
    NSInteger peerAvatarIndex = 0;
    for (NSString *currentPeerId in self.connectedPlayers) {
        if ([currentPeerId isEqualToString:peerID]) {
            CCSprite *clientAvatar = self.playerAvatars[peerAvatarIndex];
            [clientAvatar removeFromParentAndCleanup:YES];
            [self.connectedPlayers removeObjectAtIndex:peerAvatarIndex];
            
            break;
        }
        
        peerAvatarIndex++;
    }
    
    // move proceeding avatars to the left
    for (int i=peerAvatarIndex+1; i<self.playerAvatars.count; i++) {
        CCSprite *currentAvatar = self.playerAvatars[i];
        currentAvatar.position = ccp(currentAvatar.position.x - self.screenSize.width * 0.15, currentAvatar.position.y);
    }
    
    [self.playerAvatars removeObjectAtIndex:peerAvatarIndex];
    
    // check if there are no connected clients
    if (self.connectedPlayers.count == 1) {
        // only host is connected
        [self hostRemoveStartAndDisplayWaitingPrompt];
    } else {
        // update displayed avatars for all clients
        Packet *packet = [PacketRemovePlayerWaitingRoom packetWithPeerIndex:peerAvatarIndex];
        [self sendPacketToAllClients:packet];
    }
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
