//
//  TipArchiveEntry.swift
//  Duffy
//
//  Created by Patrick Rills on 6/3/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import Foundation

public struct TipArchiveEntry: Codable {
    var date: Date
    private var id: String
    
    public var tipIdentifier: TipIdentifier? {
        return TipIdentifier(rawValue: id)
    }
    
    init(date: Date, identifier: TipIdentifier) {
        self.date = date
        self.id = identifier.rawValue
    }
}
