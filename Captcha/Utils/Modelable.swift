//
//  Modelable.swift
//  MCGraphics
//
//  Created by zwh on 2020/12/17.
//

import Foundation

fileprivate extension String {
    var number: NSNumber? {
        let trimed = trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimed.isEmpty { return nil }
        
        if trimed == "nil" || trimed == "null" || trimed == "<null>" {
            return nil
        }
        if trimed == "true" || trimed == "yes" {
            return NSNumber(true)
        }
        if trimed == "false" || trimed == "no" {
            return NSNumber(false)
        }
        
        // hex number
        var sign: Int64 = 0
        var hex = trimed
        if trimed.hasPrefix("0x") {
            sign = 1
            hex = trimed.suffix(trimed.lengthOfBytes(using: .utf8) - 2).lowercased()
        } else if trimed.hasPrefix("-0x") {
            sign = -1
            hex = trimed.suffix(trimed.lengthOfBytes(using: .utf8) - 3).lowercased()
        }
        if sign != 0 {
            var num: UInt64 = 0
            let scan = Scanner.init(string: hex)
            if scan.scanHexInt64(&num) {
                return NSNumber.init(value: Int64(num) * sign)
            } else {
                return nil
            }
        }
        
        // normal number
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: trimed)
    }
}

extension NSNumber {
    func cast<T>() -> T? {
        if let cast = int8Value as? T { return cast }
        if let cast = uint8Value as? T { return cast }
        
        if let cast = int16Value as? T { return cast }
        if let cast = uint16Value as? T { return cast }
        
        if let cast = int32Value as? T { return cast }
        if let cast = uint32Value as? T { return cast }
        
        if let cast = int64Value as? T { return cast }
        if let cast = uint64Value as? T { return cast }
        
        if let cast = floatValue as? T { return cast }
        if let cast = doubleValue as? T { return cast }
        if let cast = boolValue as? T { return cast }
        
        if let cast = intValue as? T { return cast }
        if let cast = uintValue as? T { return cast }
        
        if let cast = stringValue as? T { return cast }
        
        return nil
    }
}

func cast<T>(_ any: Any?) -> T? {
    if let cast = any as? T { return cast }
    
    if let str = any as? String {
        let number = str.number
        if let cast: T = number?.cast() { return cast }
    }
    
    if let number = any as? NSNumber {
        if let cast: T = number.cast() { return cast }
    }
    
    return nil
}
