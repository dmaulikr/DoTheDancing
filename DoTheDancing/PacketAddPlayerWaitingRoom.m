//
//  PacketAddPlayerWaitingRoom.m
//  DoTheDancing
//
//  Created by Michael Gao on 4/28/13.
//
//

#import "PacketAddPlayerWaitingRoom.h"

@implementation PacketAddPlayerWaitingRoom

+ (id)packetWithData:(NSData *)data
{
	size_t count;
	NSString *peerIDs = [data rw_stringAtOffset:PACKET_HEADER_SIZE bytesRead:&count];
    
	return [[self class] packetWithPeerIDs:peerIDs];
}

+ (id)packetWithPeerIDs:(NSString *)peerIDs
{
	return [[[self class] alloc] initWithPeerIDs:peerIDs];
}

- (id)initWithPeerIDs:(NSString *)peerIDs
{
	if ((self = [super initWithType:PacketTypeAddPlayerWaitingRoom]))
	{
		self.peerIDsString = peerIDs;
	}
	return self;
}

- (void)addPayloadToData:(NSMutableData *)data
{
	[data rw_appendString:self.peerIDsString];
}

@end
