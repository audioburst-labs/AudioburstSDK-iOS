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

    var audioburstLibrary: AudioburstLibrary?
    var player: AVPlayer?

    private var statusObservation: NSKeyValueObservation?

    public init() {
        audioburstLibrary = AudioburstLibrary(applicationKey: "InternalDevTest")
        audioburstLibrary?.setPlaybackStateListener(listener: self)
    }

    deinit {
        audioburstLibrary?.stop()
        audioburstLibrary?.removePlaybackStateListener(listener: self)
    }

    public func load(voiceData: Data, completion: @escaping (_ result: Bool) -> Void)
    {
        audioburstLibrary?.getPlaylist(data: voiceData, onData: { [weak self] (playlist) in
            print(playlist)
            guard let burst = playlist.bursts.first else { return }
            self?.play(burst: burst)
            completion(true)
        }, onError: { (error) in
            print(error)
            completion(false)
        })
    }

    func play(burst: Burst) {
        guard let url = URL(string: burst.audioUrl) else { return }
        let playerItem = AVPlayerItem(url: url)


        player = AVPlayer(playerItem: playerItem)

        statusObservation = player?.observe(\.timeControlStatus, options: [.new, .old], changeHandler: { [weak self]
            (playerItem, change) in
            switch (playerItem.timeControlStatus) {
            case .playing:
                self?.audioburstLibrary?.start()
            default:
                self?.audioburstLibrary?.stop()
            }
        })

        player?.play()
    }

}

extension AudioburstPlayerCore: PlaybackStateListener {
    public func getPlaybackState() -> PlaybackState? {
        guard let asset = (player?.currentItem?.asset) as? AVURLAsset, let player = self.player else {
            print("returned nil")
            return nil
        }
        let url = asset.url.absoluteString
        print(player.currentTime())
        let contentPositionMilis = (player.currentTime().seconds)*1000
        print("returned PlaybackState \(url)  \(contentPositionMilis)")
        return PlaybackState(url: url, positionMillis: Int64(contentPositionMilis))
    }
}
