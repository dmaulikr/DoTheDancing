//
//  Constants.h
//  chinAndCheeksTemplate
//
//  Created by Michael Gao on 11/17/12.
//
//

#ifndef chinAndCheeksTemplate_Constants_h
#define chinAndCheeksTemplate_Constants_h

typedef enum {
    kSceneTypeNone = -1,
    kSceneTypeTestMotion,
    kSceneTypeMainMenu,
    kSceneTypeDanceMoveSelection,
    kSceneTypeDanceMoveInstructions,
    kSceneTypeDanceMoveSeeInAction,
    kSceneTypeDanceMoveDance,
    kSceneTypeDanceMoveResults
} SceneTypes;

typedef enum {
    kDanceMoveNone = -1,
    kDanceMoveBernie,
    kDanceMoveNum
} DanceMoves;

#define kDanceMoveBernieName @"Bernie"

#define kYawMin -400.0
#define kYawMax 400.0
#define kPitchMin -400.0
#define kPitchMax 400.0
#define kRollMin -400.0
#define kRollMax 400.0
#define kAccelerationXMin -1000.0
#define kAccelerationXMax 1000.0
#define kAccelerationYMin -1000.0
#define kAccelerationYMax 1000.0
#define kAccelerationZMin -1000.0
#define kAccelerationZMax 1000.0

typedef enum {
    kCharacterStateNone = 0,
    kCharacterStateIdle
} GameObjectStates;

// audio items
#define AUDIO_MAX_WAITTIME 150

typedef enum {
    kAudioManagerUninitialized = 0,
    kAudioManagerFailed = 1,
    kAudioManagerInitializing = 2,
    kAudioManagerInitialized = 100,
    kAudioManagerLoading = 200,
    kAudioManagerReady = 300
    
} GameManagerSoundState;

#define SFX_NOTLOADED NO
#define SFX_LOADED YES

#define PLAYSOUNDEFFECT(...) \
[[GameManager sharedGameManager] playSoundEffect:@#__VA_ARGS__]

#define STOPSOUNDEFFECT(...) \
[[GameManager sharedGameManager] stopSoundEffect:__VA_ARGS__]

#endif
