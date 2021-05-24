//
//  BurstPlayer.swift
//  AudioburstSDK-ios
//
//  Created by Aleksander Kobylak on 18/05/2021.
//

import Foundation
import AVKit
import AudioburstMobileLibrary

class BurstPlayer {
    var player: AVPlayer?
    //var playerItems: [AVPlayerItem]?
    var playlist: Playlist?

    var delegate: AudioburstPlayerCoreDelegate?

    //MARK: status
    var timeObserverToken: Any?
    var durationObservation: NSKeyValueObservation?
    var statusObservation: NSKeyValueObservation?
    var timeControlStatusObservation: NSKeyValueObservation?
    var queueStatusObservation: NSKeyValueObservation?
    //var endPlayingObservation: NSKeyValueObservation?

    init() {
        //prepareToPlay()
    }

    deinit {
        cleanup()
    }
   
    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    func previous() {
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
        guard let item = player?.currentItem, item.status == .readyToPlay else { return }
        item.cancelPendingSeeks()
        let seconds: Float = max(0, min(position, duration - 0.5))
        item.seek(to: CMTime(seconds: Double(seconds), preferredTimescale: Int32(NSEC_PER_SEC)), toleranceBefore: .zero, toleranceAfter: .zero) { result in
            //empty
        }
    }

    func play(at itemIndex: Int) {
        print("-- play at item index \(itemIndex)")
        guard let player = player, let item = preparePlayerItem(at: itemIndex) else { return }
        let status = isPlaying
        player.replaceCurrentItem(with: item)
        player.seek(to: .zero)
        prepareToPlay()
        if status {
            play()
        }
    }


    func load(_ playlist: Playlist, completion: @escaping (_ result: Swift.Result<Playlist, AudioburstError>) -> Void) {
        cleanup()
        self.playlist = playlist

        guard let item = preparePlayerItem(at: 0) else {
            completion(.failure(AudioburstError.contentNotReady))
            return  }
        player = AVPlayer(playerItem: item)
        player?.automaticallyWaitsToMinimizeStalling  = true
        prepareToPlay()
        completion(.success(playlist))
    }


    func preparePlayerItem(at index: Int) -> AVPlayerItem? {
        var item: AVPlayerItem? = nil
        if let burst = playlist?.bursts[safe: index], let streamUrl = burst.streamUrl, let url = URL(string: streamUrl) {
            item = AVPlayerItem(url: url )
        }
        return item
    }

    func getCurrentItemIndex() -> Int? {
        guard let currentItem = player?.currentItem else {return nil}
        return playlist?.bursts.firstIndex(where: {$0.streamUrl == (currentItem.asset as? AVURLAsset)?.url.absoluteString })
    }

    func getCurrentBurst() -> Burst? {
        guard let currentIndex = getCurrentItemIndex() else {return nil}
        return playlist?.bursts[safe: currentIndex]
    }

    func handleAdIfNeeded() {
        
    }
}





