//
//  BurstPlayer+Status.swift
//  AudioburstSDK-ios
//
//  Created by Aleksander Kobylak on 21/05/2021.
//

import Foundation
import AudioburstMobileLibrary
import AVKit

extension BurstPlayer {

    var isPlaying: Bool {
        player?.rate != 0 && player?.error == nil
    }

    var duration: Float {
        guard let item = player?.currentItem, item.status == .readyToPlay else { return 0.0 }
        let value = Float(CMTimeGetSeconds(item.duration))
        return value.isNaN ? 0.0 : value
    }

    var progress: Float {
        guard let item = player?.currentItem, item.status == .readyToPlay else { return 0.0 }
        let durationValue = Float(CMTimeGetSeconds(item.duration))
        let currentTimeValue = Float(CMTimeGetSeconds(item.currentTime()))
        if durationValue.isNaN || currentTimeValue.isNaN { return 0.0 }
        return (durationValue > 0) ? currentTimeValue / durationValue : 0.0
    }

    var passedTime: Float {
        Float(player?.currentTime().seconds ?? 0.0)
    }


    func prepareToPlay() {
        cleanup()
        statusObservation = player?.currentItem?.observe(\.status, options: [.new]) { [weak self] observedItem, change in
           // self?.delegate?.didChangePlayerStatus()
        }

        durationObservation = player?.currentItem?.observe(\.duration, options: [.new]) { [weak self] observedItem, change in
            if observedItem.duration != .indefinite {
                self?.createPeriodicTimeObserver()
            }
        }

        timeControlStatusObservation = player?.observe(\.timeControlStatus, options: [.new, .old]) { [weak self] player, change in
            self?.delegate?.didChangePlayerStatus()
        }

        queueStatusObservation = player?.observe(\.currentItem, options: [.new, .initial]) {
            [weak self] (player, _) in

//            if let token = self?.timeObserverToken {
//                self?.player?.removeTimeObserver(token)
//                self?.timeObserverToken = nil
//            }

            self?.delegate?.didChangeCurrentBurst()
        }
    }

    func cleanup() {
        NotificationCenter.default.removeObserver(self)
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        player?.pause()
        player?.currentItem?.asset.cancelLoading()
        durationObservation = nil
        statusObservation = nil
        timeControlStatusObservation = nil
    }

    private func createPeriodicTimeObserver() {
        guard timeObserverToken == nil else { return }

        guard let currentItem = player?.currentItem else {
            return
        }

        let itemDuration: TimeInterval = CMTimeGetSeconds(currentItem.duration)
        guard itemDuration > 0.5 else { return }
        let seconds = min(max(0.1, itemDuration / 500.0), 0.5)
        let interval = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: nil) { [weak self] time in
            //let progress = Float((CMTimeGetSeconds(time) / itemDuration))
            //self?.onProgressChanged?(progress, Float(itemDuration))
            self?.delegate?.didChangePlaybackTime()
        }
    }
}


extension BurstPlayer: PlaybackStateListener {
    public func getPlaybackState() -> PlaybackState? {
        guard let asset = (player?.currentItem?.asset) as? AVURLAsset, let player = self.player else {
            return nil
        }
        let url = asset.url.absoluteString
        let contentPositionMilis = (player.currentTime().seconds)*1000
        return PlaybackState(url: url, positionMillis: Int64(contentPositionMilis))
    }
}
