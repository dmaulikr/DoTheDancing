//
//  DanceMove.h
//  LilD
//
//  Created by Michael Gao on 4/20/13.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface DanceMove : NSObject

@property (nonatomic) DanceMoves danceMoveType;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *trackName;

@end
