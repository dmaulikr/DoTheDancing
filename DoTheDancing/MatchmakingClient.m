//
//  MatchmakingClient.m
//  DoTheDancing
//
//  Created by Michael Gao on 4/25/13.
//
//

#import "MatchmakingClient.h"
#import "Packet.h"
#import "PacketAddPlayerWaitingRoom.h"
#import "PacketRemovePlayerWaitingRoom.h"
#import "PacketSegueToDanceMoveInstructions.h"

typedef enum
{
	ClientStateIdle,
	ClientStateSearchingForServers,
	ClientStateConnecting,
	ClientStateConnected,
}
ClientState;

@interface MatchmakingClient()

@property (nonatomic) ClientState clientState;

@end

@implementation MatchmakingClient

-(id)init {
    self = [super init];
    if (self != nil) {
        self.clientState = ClientStateIdle;
        self.quitReason = QuitReasonNone;
    }
    
    return self;
}

- (void)startSearchingForServersWithSessionID:(NSString *)sessionID
{
    if (self.clientState == ClientStateIdle) {
        self.session = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModeClient];
        self.clientState = ClientStateSearchingForServers;
        self.session.delegate = self;
        self.session.available = YES;
    }
}

- (void)connectToServerWithPeerID:(NSString *)peerID
{
    if (self.clientState == ClientStateSearchingForServers) {
        self.clientState = ClientStateConnecting;
        self.serverPeerID = peerID;
        [self.session connectToPeer:peerID withTimeout:self.session.disconnectTimeout];
    }
}

- (void)disconnectFromServer
{
    if (self.clientState != ClientStateIdle) {
        self.clientState = ClientStateIdle;
        
        [self.session disconnectFromAllPeers];
        self.session.available = NO;
        self.session.delegate = nil;
        self.session = nil;
        
        [self.delegate matchmakingClientDidDisconnectFromServer:self.serverPeerID];
    }
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	CCLOG(@"MatchmakingClient: peer %@ changed state %d", [session displayNameForPeer:peerID], state);
    
    switch (state)
	{
            // The client has discovered a new server.
		case GKPeerStateAvailable:
            if (self.clientState == ClientStateSearchingForServers) {
                [self connectToServerWithPeerID:peerID];
            }
			break;
            
            // The client sees that a server goes away.
		case GKPeerStateUnavailable:
            if (self.clientState == ClientStateSearchingForServers) {
                [self.delegate matchmakingClientServerBecameUnavailable:peerID];
            }
            
            if (self.clientState == ClientStateConnecting && [peerID isEqualToString:self.serverPeerID]) {
                [self disconnectFromServer];
            }
			break;
            
            // You're now connected to the server.
		case GKPeerStateConnected:
			if (self.clientState == ClientStateConnecting)
			{
				self.clientState = ClientStateConnected;
                [self.delegate matchmakingClientDidConnectToServer:peerID];
                
                // no longer searching for a server
                self.session.available = NO;
                [self.session setDataReceiveHandler:self withContext:nil];
			}
			break;
            
            // You're now no longer connected to the server.
		case GKPeerStateDisconnected:
			if (self.clientState == ClientStateConnected && [peerID isEqualToString:self.serverPeerID])
			{
				[self disconnectFromServer];
			}
			break;
            
		case GKPeerStateConnecting:
			break;
	}
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
	CCLOG(@"MatchmakingClient: connection request from peer %@", [session displayNameForPeer:peerID]);
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
	CCLOG(@"MatchmakingClient: connection with peer %@ failed %@", [session displayNameForPeer:peerID], error);
    
    [self disconnectFromServer];
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
	CCLOG(@"MatchmakingClient: session failed %@", error);
    
    // network error
#warning - no network error not working (for bluetooth/wifi off)
    if ([[error domain] isEqualToString:GKSessionErrorDomain])
	{
		if ([error code] == GKSessionCannotEnableError)
		{
			[self.delegate matchmakingClientNoNetwork];
			[self disconnectFromServer];
		}
	}
}

#pragma mark - GKSession Data Receive Handler

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peerID inSession:(GKSession *)session context:(void *)context
{
	CCLOG(@"MatchmakingClient: receive data from peer: %@, data: %@, length: %d", peerID, data, [data length]);
    
    Packet *packet = [Packet packetWithData:data];
	if (packet == nil)
	{
		CCLOG(@"Invalid packet: %@", data);
		return;
	}
    
	[self clientReceivedPacket:packet];
}

- (void)clientReceivedPacket:(Packet *)packet
{
	switch (packet.packetType)
	{
		case PacketTypeAddPlayerWaitingRoom: {
            PacketAddPlayerWaitingRoom *newPacket = (PacketAddPlayerWaitingRoom*)packet;
            CCLOG(@"Received peerIDs: %@", newPacket.peerIDsString);
            if ([self.delegate respondsToSelector:@selector(matchmakingClientDidReceiveNewConnectedPeersList:)]) {
                [self.delegate matchmakingClientDidReceiveNewConnectedPeersList:newPacket.peerIDsString];
            }
            
			break;
        }
            
        case PacketTypeRemovePlayerWaitingRoom: {
            PacketRemovePlayerWaitingRoom *newPacket = (PacketRemovePlayerWaitingRoom*)packet;
            CCLOG(@"Received peerIndex: %i", newPacket.peerIndex);
            if ([self.delegate respondsToSelector:@selector(matchmakingClientDidReceiveIndexOfRemovedClient:)]) {
                [self.delegate matchmakingClientDidReceiveIndexOfRemovedClient:newPacket.peerIndex];
            }
            
            break;
        }
            
        case PacketTypeSegueToDanceMoveSelection: {
            if ([self.delegate respondsToSelector:@selector(matchmakingClientSegueToSelectDanceMove)]) {
                [self.delegate matchmakingClientSegueToSelectDanceMove];
            }
            
            break;
        }
            
        case PacketTypeSegueToDanceMoveInstructions: {
            PacketSegueToDanceMoveInstructions *newPacket = (PacketSegueToDanceMoveInstructions*)packet;
            
            if ([self.delegate respondsToSelector:@selector(matchmakingClientSegueToInstructionsWithDanceMoveType:)]) {
                [self.delegate matchmakingClientSegueToInstructionsWithDanceMoveType:newPacket.danceMoveType];
            }
        }
            
		default:
			CCLOG(@"Client received unexpected packet: %@", packet);
			break;
	}
}

- (void)sendPacketToServer:(Packet *)packet
{
	GKSendDataMode dataMode = GKSendDataReliable;
	NSData *data = [packet data];
	NSError *error;
	if (![self.session sendData:data toPeers:[NSArray arrayWithObject:self.serverPeerID] withDataMode:dataMode error:&error])
	{
		CCLOG(@"Error sending data to server: %@", error);
	}
}

@end
