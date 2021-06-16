//
//  BurstPlayer.swift
//  AudioburstSDK-ios
//
//  Created by Aleksander Kobylak on 18/05/2021.
//

import Foundation
import AVKit
import AudioburstMobileLibrary


class BurstPlayer: BurstPlayerProtocol {
    var avPlayer: AVPlayer?
    var playlist: Playlist?
    var delegate: AudioburstPlayerCoreDelegate?
    let mobileLibrary: AudioburstLibrary
    
    //MARK: status
    var timeObserverToken: Any?
    var durationObservation: NSKeyValueObservation?
    var timeControlStatusObservation: NSKeyValueObservation?
    var queueStatusObservation: NSKeyValueObservation?
    
    init(mobileLibrary: AudioburstLibrary) {
        self.mobileLibrary = mobileLibrary
    }
    
    deinit {
        cleanup()
        avPlayer = nil
    }
    
    func play() {
        avPlayer?.play()
    }
    
    func pause() {
        avPlayer?.pause()
    }

    func stop() {
        avPlayer?.pause()
        avPlayer = nil
        playlist = nil
        delegate?.didChangeCurrentBurst()
        delegate?.didChangePlaybackTime()
        delegate?.didChangePlayerStatus()
        delegate?.didUpdatePlaylist()
    }
    
    public func previous() {
        guard let currentIndex = getCurrentItemIndex(), currentIndex != 0 else { return }
        play(at: (currentIndex - 1))
    }
    
    func next() {
        guard let currentIndex = getCurrentItemIndex(), let burstsCount = playlist?.bursts.count else { return }
        if currentIndex < burstsCount-1 {
            play(at: (currentIndex + 1))
        }
    }
    
    func seekTo(position: Float) {
        guard let item = avPlayer?.currentItem, item.status == .readyToPlay else { return }
        item.cancelPendingSeeks()
        let seconds: Float = max(0, min(position, duration - 0.5))
        item.seek(to: CMTime(seconds: Double(seconds), preferredTimescale: Int32(NSEC_PER_SEC)), toleranceBefore: .zero, toleranceAfter: .zero) { result in
            //empty
        }
    }
    
    func toggleSource() {
        guard let currentIndex = getCurrentItemIndex(), let currentBurst = getCurrentBurst() else { return }
        let status = isPlaying
        if isFullSource {
            //load burst
            play(at: currentIndex)
        } else {
            //load full source
            guard let url = currentBurst.burstSource.audioUrl else { return }
            let item  = AVPlayerItem(url: url)
            avPlayer?.replaceCurrentItem(with: item)
            avPlayer?.seek(to: .zero)
            prepareToPlay()
            if status {
                play()
            }
        }
    }
    
    func play(at itemIndex: Int) {
        guard let player = avPlayer else { return }
        let status = isPlaying
        preparePlayerItem(at: itemIndex) {[weak self] item in
            guard let item = item else { return }
            player.replaceCurrentItem(with: item)
            player.seek(to: .zero)
            self?.prepareToPlay()
            if status {
                self?.play()
            }
        }
    }
    
    func load(_ playlist: Playlist, completion: @escaping (_ result: Swift.Result<Playlist, AudioburstError>) -> Void) {

        guard !playlist.bursts.isEmpty else {
            completion(.failure(AudioburstError.contentNotReady))
            return
        }

        if let loadedPlaylist = self.playlist,  playlist.id == loadedPlaylist.id {
            //if loading already loaded playlist update playlist (bursts), but do not reload
            self.playlist = updatePlaylist(from: playlist, to: loadedPlaylist)
            guard let playlist = self.playlist else {
                completion(.failure(AudioburstError.contentNotReady))
                return
            }
            completion(.success(playlist))
        } else {
            //load new playlist
            cleanup()

            self.playlist = playlist
            preparePlayerItem(at: 0) {[weak self] item in
                guard let item = item else {
                    completion(.failure(AudioburstError.contentNotReady))
                    return
                }
                self?.avPlayer = AVPlayer(playerItem: item)
                self?.avPlayer?.automaticallyWaitsToMinimizeStalling  = true

                guard let _ = self?.avPlayer else {
                    self?.playlist = nil
                    completion(.failure(AudioburstError.contentNotReady))
                    return
                }
                self?.prepareToPlay()
                self?.delegate?.didUpdatePlaylist()
                self?.delegate?.didChangePlaybackTime()
                completion(.success(playlist))
            }
        }
    }

    private func updatePlaylist(from newPlaylist: Playlist, to loadedPlaylist: Playlist) -> Playlist {
        guard newPlaylist.id == loadedPlaylist.id else {
            return loadedPlaylist
        }
        return newPlaylist
    }

    private func preparePlayerItem(at index: Int, completion: @escaping (_ result: AVPlayerItem?) -> Void) {
        var item: AVPlayerItem? = nil
        var url: URL? = nil
        guard let burst = playlist?.bursts[safe: index] else {
            completion(nil)
            return
        }
        url = burst.streamUrl != nil ? burst.streamUrl : burst.audioUrl
        
        guard let regularUrl = url else {
            completion(nil)
            return
        }

//        if burst.isAdAvailable {
//            avPlayer?.pause()
//            mobileLibrary.getAdUrl(burst: burst,
//                                   onData: {adUrl in
//                                    debugPrint("Ad url received: \(adUrl)")
//                                    if let adUrl = URL(string: adUrl), !adUrl.isHTTPScheme {
//                                        item = AVPlayerItem(url: adUrl )
//                                    }
//                                    else {
//                                        item = AVPlayerItem(url: regularUrl )
//                                    }
//                                    completion(item)
//                                   },
//                                   onError: { error in
//                                    item = AVPlayerItem(url: regularUrl )
//                                    completion(item)
//                                   })
//        }
//        else {
            item = AVPlayerItem(url: regularUrl )
            completion(item)
      //  }
    }
    
    func getCurrentItemIndex() -> Int? {
        guard let currentItem = avPlayer?.currentItem else {return nil}
        let currentURLString = (currentItem.asset as? AVURLAsset)?.url
        return playlist?.bursts.firstIndex(where: {$0.streamUrl == currentURLString  || $0.audioUrl == currentURLString })
    }
    
    func getCurrentBurst() -> Burst? {
        guard let currentIndex = getCurrentItemIndex() else {return nil}
        return playlist?.bursts[safe: currentIndex]
    }
    
}
