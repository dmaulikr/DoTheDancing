//
//  PacketStartDanceMoveDance.h
//  DoTheDancing-iPad
//
//  Created by Michael Gao on 5/5/13.
//
//

#import "Packet.h"
#import "Constants.h"

@interface PacketStartDanceMoveDance : Packet

@property (nonatomic) DanceMoves danceMoveType;

+(id)packetWithDanceMoveType:(DanceMoves)danceMoveType;

@end
