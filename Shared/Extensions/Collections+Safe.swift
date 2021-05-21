//
//  Collections+Safe.swift
//  AudioburstSDK-ios
//
//  Created by Aleksander Kobylak on 14/05/2021.
//

import Foundation

extension Collection {

    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
