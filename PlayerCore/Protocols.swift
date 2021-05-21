//
//  Protocols.swift
//  AudioburstSDK-ios
//
//  Created by Aleksander Kobylak on 17/05/2021.
//

import Foundation
import AudioburstMobileLibrary

public struct CurrentBurst {
    public let object: Burst
    public let index: Int
    public let isFirst: Bool
    public let isLast: Bool
}

public struct PlayerStatus {
    public let isPlaying: Bool
    public let isFullSource: Bool
    /// Relative: in range 0.0 - 1.0
    public let progress: Float
    public let duration: Float
    public let start: Float
    public let end: Float
    public let passedTime: Float
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
