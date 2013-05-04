//
//  MatchmakingPeer.m
//  DoTheDancing-iPad
//
//  Created by Michael Gao on 5/4/13.
//
//

#import "MatchmakingPeer.h"

typedef enum
{
	PeerStateIdle,
	PeerStateSearchingForPeers,
	PeerStateConnecting,
	PeerStateConnected,
}
PeerState;

@interface MatchmakingPeer()

@property (nonatomic) PeerState peerState;

@end

@implementation MatchmakingPeer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.peerState = PeerStateIdle;
        self.quitReason = QuitReasonConnectionDropped;
    }
    
    return self;
}

- (void)startSearchingForPeersWithSessionID:(NSString *)sessionID {
    if (self.peerState == PeerStateIdle) {
        CCLOG(@"startSearchingForPeersWithSessionID: %@", sessionID);
        self.session = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModePeer];
        self.peerState = PeerStateSearchingForPeers;
        self.session.delegate = self;
        self.session.available = YES;
    }
}

- (void)connectToPeerWithPeerID:(NSString *)peerID {
    if (self.peerState == PeerStateSearchingForPeers) {
        self.peerState = PeerStateConnecting;
        self.connectedPeerID = peerID;
        [self.session connectToPeer:peerID withTimeout:self.session.disconnectTimeout];
    }
}

- (void)disconnectFromPeer {
    if (self.peerState != PeerStateIdle) {
        self.peerState = PeerStateIdle;
        
        [self.session disconnectFromAllPeers];
        self.session.available = NO;
        self.session.delegate = nil;
        self.session = nil;
        
        [self.delegate matchmakingPeerDidDisconnectFromPeer:self.connectedPeerID];
    }
}

#pragma mark - GKSessionDelegate methods

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	CCLOG(@"MatchmakingPeer: peer %@ changed state %d", [session displayNameForPeer:peerID], state);
    
    switch (state)
	{
            // You have discovered a new peer.
		case GKPeerStateAvailable:
            if (self.peerState == PeerStateSearchingForPeers) {
                [self connectToPeerWithPeerID:peerID];
            }
			break;
            
            // You see that a peer goes away.
		case GKPeerStateUnavailable:

			break;
            
            // You are now connected to new peer.
		case GKPeerStateConnected:
			if (self.peerState == PeerStateConnecting)
			{
				self.peerState = PeerStateConnected;
                [self.delegate matchmakingPeerDidConnectToPeerWithPeerID:peerID];
                
                // no longer searching for a peer
                self.session.available = NO;
                
                // begin to receive packets
                [self.session setDataReceiveHandler:self withContext:nil];
			}
			break;
            
            // You're now no longer connected to the peer.
		case GKPeerStateDisconnected:
			if (self.peerState == PeerStateConnected)
			{
				[self disconnectFromPeer];
			}
			break;
            
		case GKPeerStateConnecting:
			break;
	}
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
	CCLOG(@"MatchmakingPeer: connection request from peer %@", [session displayNameForPeer:peerID]);
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
	CCLOG(@"MatchmakingPeer: connection with peer %@ failed %@", [session displayNameForPeer:peerID], error);
    
    [self disconnectFromPeer];
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
	CCLOG(@"MatchmakingPeer: session failed %@", error);
    
    // network error
#warning - no network error not working (for bluetooth/wifi off)
    if ([[error domain] isEqualToString:GKSessionErrorDomain])
	{
		if ([error code] == GKSessionCannotEnableError)
		{
            self.quitReason = QuitReasonNoNetwork;
			[self disconnectFromPeer];
		}
	}
}

#pragma mark - GKSession Data Receive Handler
//
//- (void)receiveData:(NSData *)data fromPeer:(NSString *)peerID inSession:(GKSession *)session context:(void *)context
//{
//	CCLOG(@"MatchmakingClient: receive data from peer: %@, data: %@, length: %d", peerID, data, [data length]);
//    
//    Packet *packet = [Packet packetWithData:data];
//	if (packet == nil)
//	{
//		CCLOG(@"Invalid packet: %@", data);
//		return;
//	}
//    
//	[self clientReceivedPacket:packet];
//}
//
//- (void)clientReceivedPacket:(Packet *)packet
//{
//	switch (packet.packetType)
//	{
//		case PacketTypeAddPlayerWaitingRoom: {
//            PacketAddPlayerWaitingRoom *newPacket = (PacketAddPlayerWaitingRoom*)packet;
//            CCLOG(@"Received peerIDs: %@", newPacket.peerIDsString);
//            if ([self.delegate respondsToSelector:@selector(matchmakingClientDidReceiveNewConnectedPeersList:)]) {
//                [self.delegate matchmakingClientDidReceiveNewConnectedPeersList:newPacket.peerIDsString];
//            }
//            
//			break;
//        }
//            
//        case PacketTypeRemovePlayerWaitingRoom: {
//            PacketRemovePlayerWaitingRoom *newPacket = (PacketRemovePlayerWaitingRoom*)packet;
//            CCLOG(@"Received peerIndex: %i", newPacket.peerIndex);
//            if ([self.delegate respondsToSelector:@selector(matchmakingClientDidReceiveIndexOfRemovedClient:)]) {
//                [self.delegate matchmakingClientDidReceiveIndexOfRemovedClient:newPacket.peerIndex];
//            }
//            
//            break;
//        }
//            
//        case PacketTypeSegueToDanceMoveSelection: {
//            if ([self.delegate respondsToSelector:@selector(matchmakingClientSegueToSelectDanceMove)]) {
//                [self.delegate matchmakingClientSegueToSelectDanceMove];
//            }
//            
//            break;
//        }
//            
//        case PacketTypeSegueToDanceMoveInstructions: {
//            PacketSegueToDanceMoveInstructions *newPacket = (PacketSegueToDanceMoveInstructions*)packet;
//            
//            if ([self.delegate respondsToSelector:@selector(matchmakingClientSegueToInstructionsWithDanceMoveType:)]) {
//                [self.delegate matchmakingClientSegueToInstructionsWithDanceMoveType:newPacket.danceMoveType];
//            }
//        }
//            
//		default:
//			CCLOG(@"Client received unexpected packet: %@", packet);
//			break;
//	}
//}
//
//- (void)sendPacketToPeer:(Packet *)packet
//{
//	GKSendDataMode dataMode = GKSendDataReliable;
//	NSData *data = [packet data];
//	NSError *error;
//	if (![self.session sendData:data toPeers:[NSArray arrayWithObject:self.serverPeerID] withDataMode:dataMode error:&error])
//	{
//		CCLOG(@"Error sending data to server: %@", error);
//	}
//}


@end
