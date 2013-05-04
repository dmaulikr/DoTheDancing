//
//  PacketSegueToDanceMoveInstructions.h
//  DoTheDancing
//
//  Created by Michael Gao on 5/3/13.
//
//

#import "Packet.h"
#import "Constants.h"

@interface PacketSegueToDanceMoveInstructions : Packet

@property (nonatomic) DanceMoves danceMoveType;

+(id)packetWithDanceMoveType:(DanceMoves)danceMoveType;

@end
