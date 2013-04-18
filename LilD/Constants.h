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
    kSceneTypeNone = 0,
    kSceneTypeMainMenu,
    kSceneTypeGame
} SceneTypes;

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
