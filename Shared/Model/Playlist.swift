//
//  Playlist.swift
//  AudioburstSDK-ios
//
//  Created by Aleksander Kobylak on 16/06/2021.
//

import Foundation
import AudioburstMobileLibrary

public struct Playlist {
    public let id: String
    public let name: String
    public let query: String
    public let bursts: [Burst]

    init(from libraryPlaylist: AudioburstMobileLibrary.Playlist) {
        self.id = libraryPlaylist.id
        self.name = libraryPlaylist.name
        self.query = libraryPlaylist.query
        self.bursts = libraryPlaylist.bursts.compactMap{ Burst(from: $0) }
    }

}
