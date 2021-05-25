//
//  AudioburstPlayerCore.swift
//  AudioburstSDK-ios
//
//  Created by Aleksander Kobylak on 10/05/2021.
//

import Foundation
import AudioburstMobileLibrary
import AVKit

public class AudioburstPlayerCore {

    private (set) public var audioburstLibrary: AudioburstLibrary
    private (set) public var burstPlayer: BurstPlayer
    var applicationKey: String?

    public init(applicationKey: String, delegate: AudioburstPlayerCoreDelegate? = nil) {
        self.applicationKey = applicationKey
        self.audioburstLibrary = AudioburstLibrary(applicationKey: applicationKey)
        self.burstPlayer = BurstPlayer(mobileLibrary: audioburstLibrary)
        self.burstPlayer.delegate = delegate
        audioburstLibrary.setPlaybackStateListener(listener: burstPlayer)
    }

    deinit {
        audioburstLibrary.stop()
        audioburstLibrary.removePlaybackStateListener(listener: burstPlayer)
        self.burstPlayer.delegate = nil

    }

    public func set(delegate: AudioburstPlayerCoreDelegate) {
        self.burstPlayer.delegate = delegate
    }

    public func play() {
        audioburstLibrary.start()
        burstPlayer.play()
    }

    public func pause() {
        audioburstLibrary.stop()
        burstPlayer.pause()
    }

    public func previous() {
        burstPlayer.previous()
    }

    public func next() {
        burstPlayer.next()
    }

    public func getPlaylist(with voiceData: Data, completion: @escaping (_ result: Swift.Result<Playlist, AudioburstError>) -> Void)
    {
        audioburstLibrary.getPlaylist(data: voiceData, onData: { playlist in
            completion(.success(playlist))
        }, onError: { (error) in
            completion(.failure(AudioburstError(libraryError: error)))
        })
    }

    public func getPlaylist(with playlistInfo: PlaylistInfo, completion: @escaping (_ result: Swift.Result<Playlist, Error>) -> Void) {
        audioburstLibrary.getPlaylist(playlistInfo: playlistInfo, onData: { playlist in
            completion(.success(playlist))
        }, onError: { (error) in
            completion(.failure(AudioburstError(libraryError: error)))
        })
    }

    public func getPlaylists(completion: @escaping (_ result: Swift.Result<[PlaylistInfo], Error>) -> Void) {
        audioburstLibrary.getPlaylists(
            onData: { playlists in
                completion(.success(playlists))
            },
            onError: { error in
                completion(.failure(AudioburstError(libraryError: error)))
            })
    }

    //public func getPersonalPlaylist(completion: @escaping (_ result: Swift.Result<Playlist, Error>) -> Void) {}

    public func load(_ playlist: Playlist, completion: @escaping (_ result: Swift.Result<Playlist, AudioburstError>) -> Void) {
        burstPlayer.load(playlist) { result in
            completion(result)
        }
    }
}

extension AudioburstPlayerCore: AudioburstPlayerCoreHandler {
    public var currentBurst: CurrentBurst? {
        guard let burst = burstPlayer.getCurrentBurst(),
              let index = burstPlayer.getCurrentItemIndex(),
              let playlist = burstPlayer.playlist else { return nil }
        let isFirst = index == 0
        let isLast = index == (playlist.bursts.capacity - 1)
        return CurrentBurst(object: burst, index: index, isFirst: isFirst, isLast: isLast)
    }


    public var status: PlayerStatus {
        return PlayerStatus(isPlaying: burstPlayer.isPlaying, isFullSource: burstPlayer.isFullSource, progress: burstPlayer.progress, duration: burstPlayer.duration, passedTime: burstPlayer.passedTime)
    }

    public var playlist: Playlist? {
        burstPlayer.playlist
    }

}
