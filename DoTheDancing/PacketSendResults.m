//
//  PacketSendResults.m
//  DoTheDancing
//
//  Created by Michael Gao on 5/12/13.
//
//

#import "PacketSendResults.h"

@implementation PacketSendResults

+(id)packetWithDanceMoveResults:(NSArray*)danceMoveResults {
    return [[[self class] alloc] initWithDanceMoveResults:danceMoveResults];
}

-(id)initWithDanceMoveResults:(NSArray*)danceMoveResults {
    self = [super initWithType:PacketTypeSendResults];
    if (self != nil) {
        self.danceMoveResults = danceMoveResults;
    }
    
    return self;
}

-(void)addPayloadToData:(NSMutableData*)data {
    // add num iterations
    [data rw_appendInt8:self.danceMoveResults.count];
    
    // add num steps
    NSArray *steps = self.danceMoveResults[0];
    [data rw_appendInt8:steps.count];
    
    for (NSArray *currentIterationResults in self.danceMoveResults) {
        for (NSNumber *currentStepResult in currentIterationResults) {
            if ([currentStepResult boolValue] == YES) {
                [data rw_appendInt8:1];
            } else {
                [data rw_appendInt8:0];
            }
        }
    }
}

@end
