//
//  Burst.swift
//  AudioburstSDK-ios
//
//  Created by Aleksander Kobylak on 16/06/2021.
//

import Foundation
import AudioburstMobileLibrary

public struct Burst {
    public let id: String
    public let title: String
    public let creationDate: String
    public let duration: TimeInterval
    public let sourceName: String
    public let category: String?
    public let playlistId: Int64
    public let showName: String
    public let streamUrl: URL?
    public let audioUrl: URL
    public let imageUrls: [String]
    public let shareUrl: URL
    public let keywords: [String]
    public let ctaData: CtaData?
    public let burstSource: BurstSource
    public let isAdAvailable: Bool

    init?(from libraryBurst: AudioburstMobileLibrary.Burst) {
        guard let audioUrl = URL(string: libraryBurst.audioUrl),
              let shareUrl = URL(string: libraryBurst.shareUrl) else {
            return nil
        }

        self.id = libraryBurst.id
        self.title = libraryBurst.title
        self.creationDate = libraryBurst.creationDate
        self.duration = libraryBurst.duration.seconds
        self.sourceName = libraryBurst.sourceName
        self.category = libraryBurst.category
        self.playlistId = libraryBurst.playlistId
        self.showName = libraryBurst.showName
        if let streamUrl = libraryBurst.streamUrl {
            self.streamUrl = URL(string:streamUrl)
        } else {
            self.streamUrl = nil
        }
        self.audioUrl = audioUrl
        self.imageUrls = libraryBurst.imageUrls
        self.shareUrl = shareUrl
        self.keywords = libraryBurst.keywords
        self.ctaData = CtaData(from: libraryBurst.ctaData)
        self.burstSource = BurstSource(from: libraryBurst.source)
        self.isAdAvailable = libraryBurst.isAdAvailable
    }

    //    func convert() -> AudioburstMobileLibrary.Burst {
    //        return AudioburstMobileLibrary.Burst(id: self.id,
    //                                             title: self.title,
    //                                             creationDate: self.creationDate,
    //                                             duration: Duration(value: self.duration, unit: .seconds),
    //                                             sourceName: self.sourceName,
    //                                             category: self.category,
    //                                             playlistId: self.playlistId,
    //                                             showName: self.showName,
    //                                             streamUrl: self.streamUrl?.absoluteString,
    //                                             audioUrl: self.audioUrl?.absoluteString ?? "",
    //                                             imageUrls: self.imageUrls,
    //                                             source: self.burstSource,
    //                                             shareUrl: self.shareUrl?.absoluteString ?? "",
    //                                             keywords: self.keywords,
    //                                             ctaData: self.ctaData,
    //                                             adUrl: "")
    //    }
}

extension Burst {
    public struct CtaData {
        public let buttonText: String
        public let url: URL

        init?(from libraryCtaData: AudioburstMobileLibrary.CtaData?) {
            guard let libraryCtaData = libraryCtaData,
                  let url = URL(string: libraryCtaData.url) else { return nil }
            self.buttonText = libraryCtaData.buttonText
            self.url = url
        }
    }

    public struct BurstSource {
        public let sourceName: String
        public let sourceType: String?
        public let showName: String
        public let durationFromStart: TimeInterval
        public let audioUrl: URL?

        init(from libraryBurstSource: AudioburstMobileLibrary.BurstSource) {
            self.sourceName = libraryBurstSource.sourceName
            self.sourceType = libraryBurstSource.sourceType
            self.showName = libraryBurstSource.showName
            self.durationFromStart = libraryBurstSource.durationFromStart.seconds
            if let audioUrl = libraryBurstSource.audioUrl {
                self.audioUrl = URL(string: audioUrl)
            } else {
                self.audioUrl = nil
            }
        }
    }
}
