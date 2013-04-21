//
//  GameManager.h
//  chinAndCheeksTemplate
//
//  Created by Michael Gao on 11/17/12.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "SimpleAudioEngine.h"
#import "DanceMove.h"

@interface GameManager : NSObject

@property (nonatomic) BOOL isMusicOn;
@property (nonatomic) BOOL isSoundEffectsOn;
@property (nonatomic) GameManagerSoundState managerSoundState;
@property (nonatomic, strong) NSMutableDictionary *listOfSoundEffectFiles;
@property (nonatomic, strong) NSMutableDictionary *soundEffectsState;

// individual dance moves practice
@property (nonatomic, strong) DanceMove *individualDanceMove;
@property (nonatomic) BOOL danceMove1Correct;
@property (nonatomic) BOOL danceMove2Correct;
@property (nonatomic) BOOL danceMove3Correct;
@property (nonatomic) BOOL danceMove4Correct;
@property (nonatomic) BOOL danceMove5Correct;

+(GameManager*)sharedGameManager;
-(void)runSceneWithID:(SceneTypes)sceneID;
-(void)setupAudioEngine;
-(ALuint)playSoundEffect:(NSString*)soundEffectKey;
-(void)stopSoundEffect:(ALuint)soundEffectID;
-(void)playBackgroundTrack:(NSString*)trackFileName;
-(void)stopBackgroundTrack;
-(void)resetForDanceMovePractice;

@end
