//
//  GameObject.h
//  chinAndCheeksTemplate
//
//  Created by Michael Gao on 11/17/12.
//
//

#import "CCSprite.h"
#import "Constants.h"
#import "CommonProtocols.h"

@interface GameObject : CCSprite

@property (nonatomic) BOOL isActive;
@property (nonatomic) CGSize screenSize;
@property (nonatomic) GameObjectType gameObjectType;
@property (nonatomic) GameObjectStates characterState;

-(void)changeState:(GameObjectStates)newState;
-(void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray*)listOfGameObjects;
-(CCAnimation*)loadPlistForAnimationWithName:(NSString*)animationName andClassName:(NSString*)className;

@end
