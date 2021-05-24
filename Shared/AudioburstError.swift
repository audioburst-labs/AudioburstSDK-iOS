//
//  AudioburstError.swift
//  AudioburstPlayer
//
//  Created by Aleksander Kobylak on 15/06/2020.
//  Copyright © 2020 Audioburst. All rights reserved.
//

import Foundation
import AudioburstMobileLibrary

public enum AudioburstError: LocalizedError {
    case wrongAppKey
    case wrongExperienceId
    case contentNotReady
    case networkError
    case configurationError
    case other(Error?)

    public var errorDescription: String? {
        switch self {
        case .wrongAppKey:
            return "Wrong Application Key provided"
        case .wrongExperienceId:
            return "Wrong Experience Id provided"
        case .contentNotReady:
            return "Content not ready"
        case .networkError:
            return "Network error"
        case .configurationError:
            return "Error in configuration"
        case .other:
            return "Player error"
        }
    }

    public init(libraryError: LibraryError) {
        switch libraryError {
        case .wrongapplicationkey:
            self = .wrongAppKey
        case .network:
            self = .networkError
        case .server:
            self = .contentNotReady
        default:
            self = .other(libraryError as? Error)
        }
    }
}
