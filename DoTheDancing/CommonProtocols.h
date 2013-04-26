//
//  CommonProtocols.h
//  chinAndCheeksTemplate
//
//  Created by Michael Gao on 11/17/12.
//
//

#ifndef chinAndCheeksTemplate_CommonProtocols_h
#define chinAndCheeksTemplate_CommonProtocols_h

typedef enum {
    kGameObjectTypeNone = 0
} GameObjectType;

@protocol GameplayLayerDelegate

-(void) createObjectOfType:(GameObjectType)objectType atLocation:(CGPoint)spawnLocation withZValue:(int)ZValue;

@end


#endif
