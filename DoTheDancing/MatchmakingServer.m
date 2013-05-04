//
//  MatchmakingServer.m
//  DoTheDancing
//
//  Created by Michael Gao on 4/25/13.
//
//

#import "MatchmakingServer.h"
#import "PacketAddPlayerWaitingRoom.h"

typedef enum
{
	ServerStateIdle,
	ServerStateAcceptingConnections,
	ServerStateIgnoringNewConnections,
}
ServerState;

@interface MatchmakingServer()

@property (nonatomic) ServerState serverState;

@end

@implementation MatchmakingServer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.serverState = ServerStateIdle;
        self.maxClients = 7;
        self.quitReason = QuitReasonNone;
    }
    
    return self;
}

- (void)startAcceptingConnectionsForSessionID:(NSString *)sessionID
{
    if (self.serverState == ServerStateIdle) {
        self.connectedClients = [NSMutableArray arrayWithCapacity:self.maxClients];
        
        self.session = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModeServer];
        self.serverState = ServerStateAcceptingConnections;
        self.session.delegate = self;
        [self.session setDataReceiveHandler:self withContext:nil];
        self.session.available = YES;
    }
}

- (void)endSession
{
    if (self.serverState != ServerStateIdle) {
        self.serverState = ServerStateIdle;
        
        [self.session disconnectFromAllPeers];
        self.session.available = NO;
        self.session.delegate = nil;
        self.session = nil;
        
        self.connectedClients = nil;
        
        [self.delegate matchmakingServerSessionDidEnd];
    }
}

-(void)stopAcceptingConnections {
    if (self.serverState == ServerStateAcceptingConnections) {
        self.serverState = ServerStateIgnoringNewConnections;
        self.session.available = NO;
    }
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	CCLOG(@"MatchmakingServer: peer %@ changed state %d", [session displayNameForPeer:peerID], state);
    switch (state)
	{
		case GKPeerStateAvailable:
			break;
            
		case GKPeerStateUnavailable:
			break;
            
            // A new client has connected to the server.
		case GKPeerStateConnected:
			if (self.serverState == ServerStateAcceptingConnections)
			{
				if (![self.connectedClients containsObject:peerID])
				{
                    [self.connectedClients addObject:peerID];
                    [self.delegate matchmakingServerClientDidConnect:peerID];
				}
			}
			break;
            
            // A client has disconnected from the server.
		case GKPeerStateDisconnected:
			if (self.serverState != ServerStateIdle)
			{
				if ([self.connectedClients containsObject:peerID])
				{
                    [self.connectedClients removeObject:peerID];
					[self.delegate matchmakingServerClientDidDisconnect:peerID];
				}
			}
			break;
            
		case GKPeerStateConnecting:
			break;
	}
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
	CCLOG(@"MatchmakingServer: connection request from peer %@", [session displayNameForPeer:peerID]);
    
    if (self.serverState == ServerStateAcceptingConnections && self.connectedClients.count < self.maxClients)
	{
		NSError *error;
		if ([session acceptConnectionFromPeer:peerID error:&error])
			CCLOG(@"MatchmakingServer: Connection accepted from peer %@", [session displayNameForPeer:peerID]);
		else
			CCLOG(@"MatchmakingServer: Error accepting connection from peer %@, %@", [session displayNameForPeer:peerID], error);
	}
	else  // not accepting connections or too many clients
	{
        CCLOG(@"MatchmakingServer: Deny connection to peer: %@", [session displayNameForPeer:peerID]);
		[session denyConnectionFromPeer:peerID];
	}
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
	CCLOG(@"MatchmakingServer: connection with peer %@ failed %@", [session displayNameForPeer:peerID], error);
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
	CCLOG(@"MatchmakingServer: session failed %@", error);
    
    // no network error
#warning - no network error not working (for bluetooth/wifi off)
    if ([[error domain] isEqualToString:GKSessionErrorDomain])
	{
		if ([error code] == GKSessionCannotEnableError)
		{
			[self.delegate matchmakingServerNoNetwork];
			[self endSession];
		}
	}
}

#pragma mark - GKSession Data Receive Handler

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peerID inSession:(GKSession *)session context:(void *)context
{
	CCLOG(@"MatchmakingServer: receive data from peer: %@, data: %@, length: %d", peerID, data, [data length]);
}

- (void)sendPacketToAllClients:(Packet *)packet
{
	GKSendDataMode dataMode = GKSendDataReliable;
	NSData *data = [packet data];
	NSError *error;
	if (![self.session sendDataToAllPeers:data withDataMode:dataMode error:&error])
	{
		CCLOG(@"Error sending data to clients: %@", error);
	}
}

@end
