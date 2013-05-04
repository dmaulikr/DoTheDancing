//
//  MatchmakingPeer.h
//  DoTheDancing-iPad
//
//  Created by Michael Gao on 5/4/13.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@protocol MatchmakingPeerDelegate <NSObject>

@optional
-(void)matchmakingPeerDidConnectToPeerWithPeerID:(NSString*)peerID;
-(void)matchmakingPeerDidDisconnectFromPeer:(NSString*)peerID;

@end

@interface MatchmakingPeer : NSObject <GKSessionDelegate>

@property (nonatomic) QuitReason quitReason;
@property (nonatomic, strong) GKSession *session;
@property (nonatomic, weak) id<MatchmakingPeerDelegate> delegate;
@property (nonatomic, strong) NSString *connectedPeerID;

-(void)startSearchingForPeersWithSessionID:(NSString *)sessionID;

@end
