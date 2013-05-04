//
//  Packet.m
//  DoTheDancing
//
//  Created by Michael Gao on 4/28/13.
//
//

#import "Packet.h"
#import "PacketAddPlayerWaitingRoom.h"
#import "PacketRemovePlayerWaitingRoom.h"
#import "PacketSegueToDanceMoveInstructions.h"

const size_t PACKET_HEADER_SIZE = 10;

@implementation Packet

+ (id)packetWithType:(PacketType)packetType
{
	return [[[self class] alloc] initWithType:packetType];
}

- (id)initWithType:(PacketType)packetType
{
	if ((self = [super init]))
	{
		self.packetType = packetType;
	}
	return self;
}

+ (id)packetWithData:(NSData *)data
{
	if ([data length] < PACKET_HEADER_SIZE)
	{
		CCLOG(@"Error: Packet too small");
		return nil;
	}
    
	if ([data rw_int32AtOffset:0] != 'DTD!')
	{
		CCLOG(@"Error: Packet has invalid header");
		return nil;
	}
    
	int packetNumber = [data rw_int32AtOffset:4];
	PacketType packetType = [data rw_int16AtOffset:8];
    
	Packet *packet;
    
	switch (packetType)
	{
		case PacketTypeAddPlayerWaitingRoom:
			packet = [PacketAddPlayerWaitingRoom packetWithData:data];
			break;
            
        case PacketTypeRemovePlayerWaitingRoom:
            packet = [PacketRemovePlayerWaitingRoom packetWithData:data];
            break;
            
        case PacketTypeSegueToDanceMoveSelection:
            packet = [Packet packetWithType:packetType];
            break;
            
        case PacketTypeSegueToDanceMoveInstructions:
            packet = [PacketSegueToDanceMoveInstructions packetWithData:data];
            break;
            
		default:
			CCLOG(@"Error: Packet has invalid type");
			return nil;
	}
    
	return packet;
}

- (NSData *)data
{
	NSMutableData *data = [[NSMutableData alloc] initWithCapacity:100];
    
	[data rw_appendInt32:'DTD!'];   // 0x534E4150
	[data rw_appendInt32:0];
	[data rw_appendInt16:self.packetType];
    
    [self addPayloadToData:data];
	return data;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@, type=%d", [super description], self.packetType];
}

- (void)addPayloadToData:(NSMutableData *)data
{
	// base class does nothing
}

@end
