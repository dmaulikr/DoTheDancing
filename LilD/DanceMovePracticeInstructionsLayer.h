//
//  DanceMovePracticeInstructionsLayer.h
//  LilD
//
//  Created by Michael Gao on 4/19/13.
//
//

#import "CCLayer.h"

@protocol DanceMovePracticeSceneDelegate <NSObject>

-(void)segueToDanceLayer;

@end

@interface DanceMovePracticeInstructionsLayer : CCLayer

@property (nonatomic, weak) id<DanceMovePracticeSceneDelegate> delegate;

@end
