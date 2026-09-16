//
//  TipCurrencySymbolPrefix.swift
//  Duffy
//
//  Created by Patrick Rills on 7/6/25.
//  Copyright © 2025 Big Blue Fly. All rights reserved.
//

public enum TipCurrencySymbolPrefix: String {
    case dollarSign = "dollarsign"
    case yenSign = "yensign"
    case hryvniaSign = "hryvniasign"
    
    public static func prefix(for locale: Locale) -> TipCurrencySymbolPrefix {        
        guard let lang = locale.language.languageCode else { return .dollarSign }
        
        switch lang {
        case .japanese:
            return .yenSign
        case .ukrainian:
            return .hryvniaSign
        default:
            return .dollarSign
        }
    }
    
    private static func prefix(for languageCode: String?) -> TipCurrencySymbolPrefix {
        guard let languageCode = languageCode else {
            return .dollarSign
        }
        
        switch languageCode {
        case "ja":
            return .yenSign
        case "uk":
            return .hryvniaSign
        default:
            return .dollarSign
        }
    }
}
