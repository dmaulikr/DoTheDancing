//
//  Packet.h
//  DoTheDancing
//
//  Created by Michael Gao on 4/28/13.
//
//

#import <Foundation/Foundation.h>
#import "NSData+DTDAdditions.h"

//typedef enum
//{
//	PacketTypeSignInRequest = 0x64,    // server to client
//	PacketTypeSignInResponse,          // client to server
//    
//	PacketTypeServerReady,             // server to client
//	PacketTypeClientReady,             // client to server
//    
//	PacketTypeDealCards,               // server to client
//	PacketTypeClientDealtCards,        // client to server
//    
//	PacketTypeActivatePlayer,          // server to client
//	PacketTypeClientTurnedCard,        // client to server
//    
//	PacketTypePlayerShouldSnap,        // client to server
//	PacketTypePlayerCalledSnap,        // server to client
//    
//	PacketTypeOtherClientQuit,         // server to client
//	PacketTypeServerQuit,              // server to client
//	PacketTypeClientQuit,              // client to server
//}
//PacketType;

typedef enum
{
	PacketTypeAddPlayerWaitingRoom = 0x64,      // server to client
    PacketTypeRemovePlayerWaitingRoom,          // server to client
    PacketTypeSegueToDanceMoveSelection,        // server to client
    PacketTypeSegueToDanceMoveInstructions,     // server to client
}
PacketType;

const size_t PACKET_HEADER_SIZE;

@interface Packet : NSObject

@property (nonatomic) PacketType packetType;

+ (id)packetWithType:(PacketType)packetType;
- (id)initWithType:(PacketType)packetType;

+ (id)packetWithData:(NSData *)data;
- (NSData *)data;

@end
