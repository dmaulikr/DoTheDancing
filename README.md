README
======

Hi. We are [Chin and Cheeks](http://twitter.com/chinandcheeks)! We travel 
around the world and make mobile games that make us (and hopefully you) smile :)

We use this template for our Cocos2D-based iPhone games! The file structure was 
heavily inspired by [Learning Cocos2D](http://amzn.com/0321735625) by 
[Rod Strougo](http://twitter.com/rodstrougo) and 
[Ray Wenderlich](http://www.raywenderlich.com/).

File Structure
--------------

	chinAndCheeksTemplate/
		Classes/
			Scenes/
				MainMenu/
					MainMenuScene.h, .m
					MainMenuLayer.h, .m
			GameObjects/
				GameObject.h, .m
			Constants/
				Constants.h
				CommonProtocols.h
			Singletons/
				AppDelegate.h, .m
				GameManager.h, .m
		Plists/
			SoundEffects.plist
		SpriteSheets/
			mainmenu_art.hd.plist, .pvr.ccz
			mainmenu_art.plist, .pvr.ccz
		Resources/
			Fonts/
			Sounds/
			Particles/
		Assets/
			mainmenu_art/
		Scripts/

### MainMenu

Adds a temporary background from the provided texture atlas and a 
menu with the following placeholder buttons: start and settings.

### GameObject

Base class that is inherited by all of our game objects. Includes method 
that animates object given a .plist of animations.

### Constants

Basic constants to keep track of the game flow and setup audio.

### CommonProtocols

Our objects communicate with the GameplayLayerDelegate when a new object 
needs to be created.

### GameManager

Handles all audio playback, global settings, and the scene stack.

### Scripts/

Folder is empty but we often integrate a shell script with the XCode build 
process to update our texture atlases during compile time. This ensures the 
texture atlases are up to date with any new or removed assets and it 
saves memory by not checking in your texture atlases to your repo. Here's 
an awesome tutorial: (http://www.codeandweb.com/blog/2011/05/11/xcode4-integration-tutorial-of-texturepacker-for-cocos2d-and-sparrow-framework)

Contact
-------
Feel free to drop us a [note](mailto:chinandcheeks@gmail.com) or tweet 
us [@chinandcheeks](http://www.twitter.com/chinandcheeks)!