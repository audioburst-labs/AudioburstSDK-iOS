//
//  TimeToString.swift
//  Audioburst
//
//  Created by Aleksander Kobylak on 08/07/2020.
//  Copyright © 2020 Audioburst. All rights reserved.
//

import Foundation

public extension Float {
    func convertTimeToString() -> String {
        Int(ceil(self)).timeToString()
    }
}

public extension Int {
    func timeToString() -> String {
        let minutes: Int = self / 60
        let seconds: Int = self - (60 * minutes)
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
