//
//  DanceMovePracticeDanceLayer.m
//  LilD
//
//  Created by Michael Gao on 4/19/13.
//
//

#import "DanceMovePracticeDanceLayer.h"
#import "GameManager.h"
#import "MusicConstants.h"

@interface DanceMovePracticeDanceLayer()

@property (nonatomic) CGSize screenSize;

@end

@implementation DanceMovePracticeDanceLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
        
        [self displayPlaceholderText];
    }
    
    return self;
}

-(void)displayPlaceholderText {
    CCLabelTTF *placeholder = [CCLabelTTF labelWithString:@"Dance now!" fontName:@"Helvetica" fontSize:32];
    placeholder.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.6);
    
    [self addChild:placeholder];
    
    // play track
    [[GameManager sharedGameManager] playBackgroundTrack:kBernieSong];
}

@end
