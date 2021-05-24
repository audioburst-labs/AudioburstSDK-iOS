//
//  URL+http.swift
//  AudioburstSDK-ios
//
//  Created by Aleksander Kobylak on 24/05/2021.
//

import Foundation

extension URL {
    var isHTTPScheme: Bool {
        return scheme?.lowercased().contains("http") == true // or hasPrefix
    }
}
