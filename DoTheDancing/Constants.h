//
//  Constants.h
//  chinAndCheeksTemplate
//
//  Created by Michael Gao on 11/17/12.
//
//

#ifndef chinAndCheeksTemplate_Constants_h
#define chinAndCheeksTemplate_Constants_h

#define SESSION_ID @"Do the Dancing!"

typedef enum {
    kSceneTypeNone = -1,
    kSceneTypeTestMotion,
    kSceneTypeMainMenu,
    kSceneTypeDanceMoveSelection,
    kSceneTypeDanceMoveInstructions,
    kSceneTypeDanceMoveSeeInAction,
    kSceneTypeDanceMoveDance,
    kSceneTypeDanceMoveResults,
    kSceneTypeMultiplayerHostOrJoin,
    kSceneTypeMultiplayerWaitingRoom
} SceneTypes;

typedef enum {
    kDanceMoveNone = -1,
    kDanceMoveBernie,
    kDanceMoveNum
} DanceMoves;

typedef enum
{
    QuitReasonNone,
	QuitReasonNoNetwork,          // no Wi-Fi or Bluetooth
	QuitReasonConnectionDropped,  // communication failure with server
	QuitReasonUserQuit,           // the user terminated the connection
	QuitReasonHostQuit,           // the host quit the game (on purpose)
}
QuitReason;

#define kDanceMoveBernieName @"Bernie"

#define kStep1_SFX @"step1_alice.caf"
#define kStep2_SFX @"step2_alice.caf"

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

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_4 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0f)

#define PLAYSOUNDEFFECT(...) \
[[GameManager sharedGameManager] playSoundEffect:@#__VA_ARGS__]

#define STOPSOUNDEFFECT(...) \
[[GameManager sharedGameManager] stopSoundEffect:__VA_ARGS__]

#endif
