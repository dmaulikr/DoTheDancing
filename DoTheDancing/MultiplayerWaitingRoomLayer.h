//
//  MultiplayerWaitingRoomLayer.h
//  DoTheDancing
//
//  Created by Michael Gao on 4/25/13.
//
//

#import "CCLayer.h"
#import "MatchmakingClient.h"
#import "MatchmakingServer.h"

@interface MultiplayerWaitingRoomLayer : CCLayer <MatchmakingClientDelegate, MatchmakingServerDelegate>

@end
