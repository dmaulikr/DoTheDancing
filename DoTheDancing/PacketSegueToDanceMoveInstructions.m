//
//  PacketSegueToDanceMoveInstructions.m
//  DoTheDancing
//
//  Created by Michael Gao on 5/3/13.
//
//

#import "PacketSegueToDanceMoveInstructions.h"

@implementation PacketSegueToDanceMoveInstructions

+ (id)packetWithData:(NSData *)data
{
    DanceMoves danceMoveType = [data rw_int8AtOffset:PACKET_HEADER_SIZE];
    
	return [[self class] packetWithDanceMoveType:danceMoveType];
}

+ (id)packetWithDanceMoveType:(DanceMoves)danceMoveType
{
	return [[[self class] alloc] initWithDanceMoveType:danceMoveType];
}

- (id)initWithDanceMoveType:(DanceMoves)danceMoveType
{
	if ((self = [super initWithType:PacketTypeSegueToDanceMoveInstructions]))
	{
		self.danceMoveType = danceMoveType;
	}
	return self;
}

- (void)addPayloadToData:(NSMutableData *)data
{
    [data rw_appendInt8:self.danceMoveType];
}

@end
