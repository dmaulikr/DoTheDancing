//
//  PacketAddPlayerWaitingRoom.h
//  DoTheDancing
//
//  Created by Michael Gao on 4/28/13.
//
//

#import "Packet.h"

@interface PacketAddPlayerWaitingRoom : Packet

@property (nonatomic, strong) NSString *peerIDsString;

+(id)packetWithPeerIDs:(NSString*)peerIDs;

@end
