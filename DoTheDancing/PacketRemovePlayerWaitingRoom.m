//
//  PacketRemovePlayerWaitingRoom.m
//  DoTheDancing
//
//  Created by Michael Gao on 5/2/13.
//
//

#import "PacketRemovePlayerWaitingRoom.h"

@implementation PacketRemovePlayerWaitingRoom

+ (id)packetWithData:(NSData *)data
{
    NSInteger peerIndex = [data rw_int8AtOffset:PACKET_HEADER_SIZE];
    
	return [[self class] packetWithPeerIndex:peerIndex];
}

+ (id)packetWithPeerIndex:(NSInteger)peerIndex
{
	return [[[self class] alloc] initWithPeerIndex:peerIndex];
}

- (id)initWithPeerIndex:(NSInteger)peerIndex
{
	if ((self = [super initWithType:PacketTypeRemovePlayerWaitingRoom]))
	{
		self.peerIndex = peerIndex;
	}
	return self;
}

- (void)addPayloadToData:(NSMutableData *)data
{
    [data rw_appendInt8:self.peerIndex];
}


@end
