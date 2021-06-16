//
//  PendingPlaylist.swift
//  AudioburstSDK-ios
//
//  Created by Aleksander Kobylak on 16/06/2021.
//

import Foundation
import AudioburstMobileLibrary

public struct PendingPlaylist {
    public let isReady: Bool
    public let playlist: Playlist

    init(from libraryPendingPlaylist: AudioburstMobileLibrary.PendingPlaylist) {
        self.isReady = libraryPendingPlaylist.isReady
        self.playlist = Playlist(from: libraryPendingPlaylist.playlist)
    }
}
