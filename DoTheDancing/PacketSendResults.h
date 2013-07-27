//
//  PacketSendResults.h
//  DoTheDancing
//
//  Created by Michael Gao on 5/12/13.
//
//

#import "Packet.h"

@interface PacketSendResults : Packet

@property (nonatomic, strong) NSArray *danceMoveResults;

+ (id)packetWithDanceMoveResults:(NSArray*)danceMoveResults;

@end
