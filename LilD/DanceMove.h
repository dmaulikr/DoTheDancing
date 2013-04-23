//
//  DanceMove.h
//  LilD
//
//  Created by Michael Gao on 4/20/13.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "MotionRequirements.h"

@interface DanceMove : NSObject

@property (nonatomic) DanceMoves danceMoveType;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *trackName;
@property (nonatomic) NSInteger numSteps;
@property (nonatomic, strong) NSArray *stepsArray;
@property (nonatomic) NSInteger numIndividualIterations;
@property (nonatomic) CGFloat timePerIteration;         // eventually change to time per step
@property (nonatomic, strong) NSArray *illustrationsForSteps;
@property (nonatomic, strong) NSArray *delayForIllustrationAnimations;
@property (nonatomic, strong) NSArray *instructionsForSteps;

@end
