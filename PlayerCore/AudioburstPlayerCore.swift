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
    private var player: BurstPlayer
    var applicationKey: String?

    public var burstPlayer: BurstPlayerProtocol {
        player
    }

    public init(applicationKey: String, delegate: AudioburstPlayerCoreDelegate? = nil) {
        self.applicationKey = applicationKey
        self.audioburstLibrary = AudioburstLibrary(applicationKey: applicationKey)
        self.player = BurstPlayer(mobileLibrary: audioburstLibrary)
        self.player.delegate = delegate
        audioburstLibrary.setPlaybackStateListener(listener: player)
    }

    deinit {
        audioburstLibrary.stop()
        audioburstLibrary.removePlaybackStateListener(listener: player)
        self.player.delegate = nil

    }

    public func set(delegate: AudioburstPlayerCoreDelegate) {
        self.player.delegate = delegate
    }

    public func play() {
        audioburstLibrary.start()
        player.play()
    }

    public func pause() {
        audioburstLibrary.stop()
        player.pause()
    }

    public func previous() {
        player.previous()
    }

    public func next() {
        player.next()
    }

    public func stop() {
        audioburstLibrary.stop()
        player.stop()
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
        player.load(playlist) { result in
            completion(result)
        }
    }

    public func search(_ query: String, completion: @escaping (_ result: Swift.Result<Playlist, AudioburstError>) -> Void) {
        audioburstLibrary.search(query: query,
                                 onData: { playlist in
                                    completion(.success(playlist))
                                 }, onError: { (error) in
                                    completion(.failure(AudioburstError(libraryError: error)))
                                 })
    }
}

extension AudioburstPlayerCore: AudioburstPlayerCoreHandler {
    public var currentBurst: CurrentBurst? {
        guard let burst = player.getCurrentBurst(),
              let index = player.getCurrentItemIndex(),
              let playlist = player.playlist else { return nil }
        let isFirst = index == 0
        let isLast = index == (playlist.bursts.capacity - 1)
        return CurrentBurst(object: burst, index: index, isFirst: isFirst, isLast: isLast)
    }


    public var status: PlayerStatus {
        return PlayerStatus(isPlaying: player.isPlaying, isLoaded: player.isLoaded, isFullSource: player.isFullSource, progress: player.progress, duration: player.duration, passedTime: player.passedTime)
    }

    public var playlist: Playlist? {
        player.playlist
    }

}
