//
//  AppDelegate.h
//  <PROJECT NAME>
//
//  Created by Michael Gao on <DATE>
//  Copyright Chin and Cheeks <YEAR>. All rights reserved.
//

@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow *window_;
	UINavigationController *navController_;

	CCDirectorIOS	*__unsafe_unretained director_;							// weak ref
}

@property (nonatomic) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (unsafe_unretained, readonly) CCDirectorIOS *director;

@end
