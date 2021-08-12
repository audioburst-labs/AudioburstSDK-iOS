//
//  RemoteMediaPlayerInteractor.swift
//  AudioburstSDK-ios
//
//  Created by Aleksander Kobylak on 11/08/2021.
//

import Foundation
import MediaPlayer


enum RemoteMediaPlayerAction {
    case play
    case pause
    case previous
    case next
    case changePosition(progress: Float)
    case togglePlayPause
}

enum MediaItemProperty {
    case artwork
    case albumTitle
    case elapsedPlaybackTime
    case playbackDuration
    case playbackRate
    case title

    var rawValue: String {
        switch self {
        case .artwork             : return MPMediaItemPropertyArtwork
        case .albumTitle          : return MPMediaItemPropertyAlbumTitle
        case .elapsedPlaybackTime : return MPNowPlayingInfoPropertyElapsedPlaybackTime
        case .playbackDuration    : return MPMediaItemPropertyPlaybackDuration
        case .playbackRate        : return MPNowPlayingInfoPropertyPlaybackRate
        case .title               : return MPMediaItemPropertyTitle
        }
    }
}

protocol RemoteMediaPlayerInteractor {

    var delegate: RemoteMediaPlayerInteractorDelegate? { get set }

    func updatePlaybackTimeInfo(elapsed: Double, duration: Float)
    func updatePlaybackStatus(isPlaying: Bool)
    func updateTrackInfo(title: String, albumTitle: String, imageURL: URL?, previousTrackAvailable: Bool, nextTrackAvailable: Bool)
}

protocol RemoteMediaPlayerInteractorDelegate: AnyObject {
    func handleRemoteMediaPlayerAction(_ action: RemoteMediaPlayerAction)
}

class RemoteMediaPlayerInteractorImpl {

    enum Target {
        case play, pause, previous, next, changePosition, togglePlayPause
    }

    private let remoteCommandCenter: MPRemoteCommandCenter
    private let nowPlayingInfoCenter: MPNowPlayingInfoCenter
    private var nowPlayingInfo: [MediaItemProperty : Any] = [:]
    private var commandCenterTargets: [Target : Any] = [:]
    private var shouldShow: Bool

    weak var delegate: RemoteMediaPlayerInteractorDelegate? = nil

    init(shouldShow: Bool,
         nowPlayingInfoCenter: MPNowPlayingInfoCenter = .default(),
         remoteCommandCenter: MPRemoteCommandCenter = .shared()) {
        self.nowPlayingInfoCenter = nowPlayingInfoCenter
        self.remoteCommandCenter = remoteCommandCenter
        self.shouldShow = shouldShow
        self.setupTargets()
    }

    deinit {
        self.removeTargets()
    }

}

extension RemoteMediaPlayerInteractorImpl: RemoteMediaPlayerInteractor {

    func updatePlaybackTimeInfo(elapsed: Double, duration: Float) {
        
        nowPlayingInfo[.playbackDuration] = duration
        nowPlayingInfo[.elapsedPlaybackTime] = elapsed

        updateMediaPlayerNowPlayingInfo()
    }

    func updatePlaybackStatus(isPlaying: Bool) {
        nowPlayingInfo[.playbackRate] = isPlaying ? 1.0 : 0.0
        updateMediaPlayerNowPlayingInfo()
    }

    func updateTrackInfo(title: String, albumTitle: String, imageURL: URL?, previousTrackAvailable: Bool, nextTrackAvailable: Bool) {


        nowPlayingInfo = [
            .title: title,
            .albumTitle: albumTitle,
        ]
        updateMediaPlayerNowPlayingInfo()

        remoteCommandCenter.previousTrackCommand.isEnabled = previousTrackAvailable
        remoteCommandCenter.nextTrackCommand.isEnabled = nextTrackAvailable

    }

    private func updateMediaPlayerArtwork(image: UIImage) {
        let boundsSize = CGSize(width: 600, height: 600)
        let artwork = MPMediaItemArtwork(boundsSize: boundsSize) { _ in return image }
        nowPlayingInfo[.artwork] = artwork
        updateMediaPlayerNowPlayingInfo()
    }

    private func updateMediaPlayerNowPlayingInfo() {

        guard shouldShow else { return }

        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo.rawDictionary
    }

}

private extension RemoteMediaPlayerInteractorImpl {

    func setupTargets() {

        guard shouldShow else { return }

        let commandCenter = remoteCommandCenter

        commandCenter.togglePlayPauseCommand.isEnabled = true
        let togglePlayPauseTarget = commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.delegate?.handleRemoteMediaPlayerAction(.togglePlayPause)
            return .success
        }
        commandCenterTargets[.togglePlayPause] = togglePlayPauseTarget

        commandCenter.playCommand.isEnabled = true
        let playTarget = commandCenter.playCommand.addTarget { [weak self] _ in
            self?.delegate?.handleRemoteMediaPlayerAction(.play)
            return .success
        }
        commandCenterTargets[.play] = playTarget

        commandCenter.pauseCommand.isEnabled = true
        let pauseTarget = commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.delegate?.handleRemoteMediaPlayerAction(.pause)
            return .success
        }
        commandCenterTargets[.pause] = pauseTarget

        let previousTarget = commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.delegate?.handleRemoteMediaPlayerAction(.previous)
            return .success
        }
        commandCenterTargets[.previous] = previousTarget

        let nextTarget = commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.delegate?.handleRemoteMediaPlayerAction(.next)
            return .success
        }
        commandCenterTargets[.next] = nextTarget

        commandCenter.changePlaybackPositionCommand.isEnabled = true
        let changePositionTarget = commandCenter.changePlaybackPositionCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            guard let duration = self?.nowPlayingInfoCenter.duration, duration > 0 else { return .noSuchContent }
            let progress: Float = Float(positionEvent.positionTime) / duration
            self?.delegate?.handleRemoteMediaPlayerAction(.changePosition(progress: progress))
            return .success
        }
        commandCenterTargets[.changePosition] = changePositionTarget
    }

    func removeTargets() {
        if let playTarget = commandCenterTargets[.play] {
            remoteCommandCenter.playCommand.removeTarget(playTarget)
        }
        if let pauseTarget = commandCenterTargets[.pause] {
            remoteCommandCenter.pauseCommand.removeTarget(pauseTarget)
        }
        if let previousTarget = commandCenterTargets[.previous] {
            remoteCommandCenter.previousTrackCommand.removeTarget(previousTarget)
        }
        if let nextTarget = commandCenterTargets[.next] {
            remoteCommandCenter.nextTrackCommand.removeTarget(nextTarget)
        }
        if let changePositionTarget = commandCenterTargets[.changePosition] {
            remoteCommandCenter.changePlaybackPositionCommand.removeTarget(changePositionTarget)
        }
        if let togglePlayPauseTarget = commandCenterTargets[.togglePlayPause] {
            remoteCommandCenter.playCommand.removeTarget(togglePlayPauseTarget)
        }
    }

}

private extension Dictionary where Dictionary.Key == MediaItemProperty {
    var rawDictionary: [String : Any] {
        var rawDictionary: [String : Any] = [:]
        forEach { rawDictionary[$0.key.rawValue] = $0.value }
        return rawDictionary
    }
}

private extension MPNowPlayingInfoCenter {
    var duration: Float? {
        nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] as? Float
    }
}

