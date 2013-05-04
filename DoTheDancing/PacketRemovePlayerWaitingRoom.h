//
//  PacketRemovePlayerWaitingRoom.h
//  DoTheDancing
//
//  Created by Michael Gao on 5/2/13.
//
//

#import "Packet.h"

@interface PacketRemovePlayerWaitingRoom : Packet

@property (nonatomic) NSInteger peerIndex;

+(id)packetWithPeerIndex:(NSInteger)peerIndex;

@end
