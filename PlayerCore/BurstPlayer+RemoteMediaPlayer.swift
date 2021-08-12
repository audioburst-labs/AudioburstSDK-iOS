//
//  BurstPlayer+RemoteMediaPlayer.swift
//  AudioburstSDK-ios
//
//  Created by Aleksander Kobylak on 11/08/2021.
//

import Foundation


extension BurstPlayer {

    func handleRemoteMediaPlayerAction(_ action: RemoteMediaPlayerAction) {
        switch action {
        case .changePosition(let progress):
            let position = duration*progress
            seekTo(position: position)
        case .next:
            next()
        case .pause:
            pause()
        case .play:
            play()
        case .previous:
            previous()
        case .togglePlayPause:
            isPlaying ? pause() : play()
        }
    }


}
