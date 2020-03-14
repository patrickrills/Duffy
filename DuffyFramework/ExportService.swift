//
//  ExportService.swift
//  Duffy
//
//  Created by Patrick Rills on 3/14/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import Foundation

open class ExportService {

    enum Constants {
        static let DELIMITER: String = ","
        static let LINE_BREAK: String = "\r\n"
    }
    
    open class func toCSV(_ rawData: [[String]], columns: [String], saveAs fullPathToSave: String) -> Bool {
        guard rawData.count > 0 && columns.count > 0 && fullPathToSave.count > 0,
            rawData.compactMap({ return $0.count == columns.count ? "1" : nil }).count == rawData.count,
            let stream = OutputStream(toFileAtPath: fullPathToSave, append: false) else {
            return false
        }
        
        if stream.streamStatus == .notOpen {
            stream.open()
        }
        
        if stream.streamStatus != .open {
            return false
        }
        
        if !writeRow(createRow(from: columns), to: stream) {
            return false
        }
        
        let rows = rawData.map({
            return ExportService.createRow(from: $0)
        })
        
        for row in rows {
            if !writeRow(row, to: stream) {
                return false
            }
        }
        
        stream.close()
        return true
    }
    
    class func createRow(from values:[String]) -> String {
        return values.map({ return String(format:"\"%@\"", $0) }).joined(separator: Constants.DELIMITER) + Constants.LINE_BREAK
    }
    
    class func writeRow(_ row: String, to stream: OutputStream) -> Bool {
        if let data = row.data(using: .utf8) {
            let writeResult = data.withUnsafeBytes({ (rawBufferPointer: UnsafeRawBufferPointer) -> Int in
                let bufferPointer = rawBufferPointer.bindMemory(to: UInt8.self)
                return stream.write(bufferPointer.baseAddress!, maxLength: data.count)
            })
            if writeResult <= 0 { return false }
        } else {
            return false
        }
        
        return true
    }
}
