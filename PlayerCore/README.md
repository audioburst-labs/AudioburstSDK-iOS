# AudioburstSDK player core library module
A library that allows you to access Audioburst content and add playback functionality to your app.

## Get Started

This guide is a quick walkthrough to add `AudioburstPlayerCore` to an iOS app.

## Add `AudioburstPlayerCore` to your app

### Step 1. Add `AudioburstPlayerCore` dependency
Add `AudioburstPlayerCore` to your project. To do this, add the following dependency in your  `Podfile` file:
```swift
pod 'AudioburstSDK/AudioburstPlayerCore'
```

### Step 2. Initialize `AudioburstPlayerCore` object
You need to initialize `AudioburstPlayerCore` with an application key.

```swift
import AudioburstSDK
```

```swift
let playerCore = AudioburstPlayerCore(applicationKey: "YOUR_API_KEY_HERE")
```

### Step 3. Request Audioburst content

The `AudioburstSDK` library is built on top of the `AudioburstMobileLibrary` library - [AudioburstMobileLibrary](https://github.com/audioburst-labs/AudioburstMobileLibrary). Some data structures used in this library are also exposed by `AudioburstPlayerCore`. Documentation for these can be found here: [wiki page](https://github.com/audioburst-labs/AudioburstMobileLibrary/wiki)

## Get all available playlists

```swift
playerCore.getPlaylists() { result in
    switch result {
    case .success(let playlists):
        //display available playlists
    case .failure(let error):
        //handle error
    }
}
```

## Get playlist information
```swift
playerCore.getPlaylist(with: playlistItem){ result in
    switch result {
    case .success(let playlist):
        //load playlist to play
    case .failure(let error):
        //handle error
    }
}
```

## Pass recorded PCM file
`AudioburstPlayerCore` is able to process raw audio files that contain a recorded request of what should be played. You can record a voice command stating what you would like to listen to and then upload it to your device and use `AudioburstPlayerCore` to get bursts on this topic.

```swift
playerCore.getPlaylist(with: voiceData){ result in
    switch result {
    case .success(let playlist):
        //load playlist to play
    case .failure(let error):
        //handle error
    }
}
```

The `getPlaylist` function accepts `Data` as an argument. A request included in the PCM file will be processed and a playlist of the bursts will be returned.

## Search for a query
`AudioburstPlayerCore` exposes an ability to search for a text query. The response will either be a `Playlist` with the list of `Bursts` found OR a `noSearchResults` error.

```swift
playerCore.search(query){ result in
    switch result {
    case .success(let playlist):
        //load playlist to play
    case .failure(let error):
        //handle error
    }
}
```

## Get Personalized Playlist using async

`AudioburstPlayerCore` includes the capability to get a personalized playlist constructed according to a user’s preferences. In order to shorten the loading time of the personalized playlist, the library exposes the ability to "subscribe" to ongoing changes in the playlist. Subscribing enables executing closure every time new `Burst`s are added to the playlist and the ability to check if the playlist is ready.

```swift
playerCore.getPersonalPlaylist() { result in
            switch result {
            case .success(let pendingPlaylist):
                  if pendingPlaylist.isReady {
											// Your playlist is ready
                  } else {
                    // Your playlist is still being prepared
                  }
            case .failure(let error):
              		// Handle error
            }
}
```

Before you request PersonalPlaylist, you need to have at least one [Key](https://github.com/audioburst-labs/AudioburstMobileLibrary/blob/master/src/commonMain/kotlin/com/audioburst/library/models/UserPreferences.kt#L99) selected, otherwise `AudioburstError.noUserPreferences` will be returned. To do so you need to use `AudioburstLibrary` to which you can get reference by calling `playerCore.audioburstLibrary`

```swift
playerCore.audioburstLibrary.getUserPreferences { userPreferences in
		// Use user preferences       
} onError: { error in
    // Handle error
}
```

```swift
playerCore.audioburstLibrary.setUserPreferences(userPreferences: newUserPreferences) { userPreferences in
		// Use updated user preferences  
} onError: { error in
		// Handle error
}
```

## Use Cta Data

`Burst` class exposes nullable `CtaData`, which you can use to show a CTA (Call to action) button which prompts the user to an immediate response.
The CtaData, when available, provides the text to be shown on the button (`buttonText`) and the link (`url`) to open in the browser upon clicking the button.
When the user clicks this button, you should call the following function to inform the library about this:
```swift
playerCore.audioburstLibrary.ctaButtonClick(burstId)
```

## Filter out listened Bursts
By default, library will filter-out all Bursts that the user has already listened to. Use `filterListenedBursts` function to change this behaviour.
```swift
playerCore.audioburstLibrary.filterListenedBursts(isEnabled)
```

## Load playlist
When you already have a `Playlist` that you would like to play, you can use `load` function to prepare a playback:
```swift
 playerCore.load(playlist){ result in
    switch result{
    case .success(let playlist):
        //loaded successfully - show playback controls
    case .failure(let error):
        //handle error
    }
}
```
## Control playback
`AudioburstPlayerCore` exposes a set of simple methods that will let you control playback state:

- `play()` - starts playback if a `Playlist` is ready,
- `pause()` - pauses playback,
- `next()` - moves to the next `Burst` when possible.
- `previous()` - moves to the previous `Burst` when possible.
- `stop()` - pauses playback and removes AVPlayer and playlist from memory. To restart playback you need to load playlist once again using `load()` method (after stopping, `isLoaded` flag from `PlayerStatus` is set to false)

## Use `AudioburstPlayerCoreDelegate`
The `AudioburstPlayerCore` uses delegate to inform about playback status. It is called for example when burst changed or playback time changed.  You need to implement `AudioburstPlayerCoreDelegate` in your app and set delegate during initialization
```swift
let playerCore = AudioburstPlayerCore(applicationKey: "YOUR_APP_KEY_HERE", delegate: self)
```

or with method

```swift
playerCore.set(delegate: self)
```

The `AudioburstPlayerCore`  implements also `AudioburstPlayerCoreHandler` protocol. Using properties declared in this protocol you can get information about current burst, playback status or current playlist.

[Protocols][Protocols]  

## Privacy Policy
[Privacy Policy](https://audioburst.com/privacy)

## Terms of Service
[Terms of Service](https://audioburst.com/audioburst-publisher-terms)

[Protocols]: https://github.com/audioburst-labs/AudioburstSDK-iOS/blob/master/PlayerCore/Protocols.swift

