//
//  Item.swift
//  easy_baby
//
//  Created by Jessie Wang on 18/4/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
