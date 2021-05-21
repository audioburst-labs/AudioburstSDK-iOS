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
    var player: AVQueuePlayer?
    var playerItems: [AVPlayerItem]?
    var playlist: Playlist?

    var delegate: AudioburstPlayerCoreDelegate?

    //MARK: status
    var timeObserverToken: Any?
    var durationObservation: NSKeyValueObservation?
    var statusObservation: NSKeyValueObservation?
    var timeControlStatusObservation: NSKeyValueObservation?
    var queueStatusObservation: NSKeyValueObservation?


    init() {
        prepareToPlay()
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
        guard let currentIndex = getCurrentItemIndex() else { return }
        play(at: (currentIndex - 1))
    }

    func next() {
        guard let currentIndex = getCurrentItemIndex(), let playerItemsCount = playerItems?.count else { return }
        if currentIndex < playerItemsCount-1 {
            player?.advanceToNextItem()
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
        player?.removeAllItems()
        guard let player = player, let playerItems = playerItems else { return }
        for index in itemIndex...playerItems.count {
            if let item = playerItems[safe: index] {
                if player.canInsert(item, after: nil) {
                    item.seek(to: .zero, completionHandler: nil)
                    player.insert(item, after: nil)
                }
            }
        }
    }

    func load(_ playlist: Playlist) -> Bool {
        cleanup()
        playerItems = preparePlayerItems(from: playlist.bursts)
        guard let playerItems = playerItems else {return false}
        self.playlist = playlist

        
        player = AVQueuePlayer(items: playerItems)
        prepareToPlay()
        return true
    }

    func preparePlayerItems(from bursts: [Burst]) -> [AVPlayerItem] {
        var items: [AVPlayerItem] = []
        for burst in bursts {
            if let streamUrl = burst.streamUrl, let url = URL(string: streamUrl) {
                items.append(AVPlayerItem(url: url ) )
            }
        }
        return items
    }

    func getCurrentItemIndex() -> Int? {
        guard let currentItem = player?.currentItem else {return nil}
        return playerItems?.firstIndex(of: currentItem)
    }

    func getCurrentBurst() -> Burst? {
        guard let currentItem = player?.currentItem,
              let index = playerItems?.firstIndex(of: currentItem) else {return nil}
        return playlist?.bursts[safe: index]
    }
}





