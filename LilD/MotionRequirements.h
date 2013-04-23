//
//  MotionRequirements.h
//  LilD
//
//  Created by Michael Gao on 4/22/13.
//
//

#import <Foundation/Foundation.h>

@interface MotionRequirements : NSObject

@property (nonatomic) CGFloat yawMin;
@property (nonatomic) CGFloat yawMax;
@property (nonatomic) CGFloat pitchMin;
@property (nonatomic) CGFloat pitchMax;
@property (nonatomic) CGFloat rollMin;
@property (nonatomic) CGFloat rollMax;
@property (nonatomic) CGFloat accelerationXMin;
@property (nonatomic) CGFloat accelerationXMax;
@property (nonatomic) CGFloat accelerationYMin;
@property (nonatomic) CGFloat accelerationYMax;
@property (nonatomic) CGFloat accelerationZMin;
@property (nonatomic) CGFloat accelerationZMax;

@end
