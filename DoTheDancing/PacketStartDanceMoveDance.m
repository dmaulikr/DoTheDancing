//
//  PacketStartDanceMoveDance.m
//  DoTheDancing-iPad
//
//  Created by Michael Gao on 5/5/13.
//
//

#import "PacketStartDanceMoveDance.h"

@implementation PacketStartDanceMoveDance

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
	if ((self = [super initWithType:PacketTypeStartDanceMoveDance]))
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
