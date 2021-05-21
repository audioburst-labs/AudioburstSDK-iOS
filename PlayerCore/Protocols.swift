//
//  Protocols.swift
//  AudioburstSDK-ios
//
//  Created by Aleksander Kobylak on 17/05/2021.
//

import Foundation
import AudioburstMobileLibrary

public struct CurrentBurst {
    let object: Burst
    let index: Int
    let isFirst: Bool
    let isLast: Bool
}

public struct PlayerStatus {
    let isPlaying: Bool
    let isFullSource: Bool
    /// Relative: in range 0.0 - 1.0
    let progress: Float
    let duration: Float
    let start: Float
    let end: Float
}

public protocol AudioburstPlayerCoreHandler: class {
    var currentBurst: CurrentBurst? { get }
    var status: PlayerStatus { get }
    var playlist: Playlist? { get }
}

public protocol AudioburstPlayerCoreDelegate: class {
    func didUpdatePlaylist()
    func didChangeCurrentBurst()
    func didChangePlayerStatus()
    func didChangePlaybackTime()
}
