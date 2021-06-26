//
//  ActionInput+Encode.swift
//  Vega
//
//  Created by kensou on 2021/6/6.
//

import Foundation

public extension ActionInput {
    func encodeInputToJSON(_ input: Any) throws -> Data {
        switch self {
        case .encodable:
            guard let encodable = input as? Encodable else {
                throw VegaError.createTypeDismatchError(input, typeToMatch: Encodable.self)
            }
            return try encodable.toJSONData()
        case .dict:
            guard let dict = input as? [String: Any] else {
                throw VegaError.createTypeDismatchError(input, typeToMatch: [String: Any].Type.self)
            }
            return try JSONSerialization.data(withJSONObject: dict, options: [])
        case .tuple:
            let dict = Mirror.getDict(from: input)
            return try JSONSerialization.data(withJSONObject: dict, options: [])
        case .key(let key):
            let dict: [String: Any] = [key: input]
            return try JSONSerialization.data(withJSONObject: dict, options: [])
        }
    }
    
    func encodeInputToDict(_ input: Any) throws -> [String: String] {
            switch self {
            case .encodable, .tuple:
                return Mirror.describeObjectAsKeyValue(input)
            case .key(let keyName):
                guard let convertable = input as? CustomStringConvertible else {
                    throw VegaError.createTypeDismatchError(input, typeToMatch: CustomStringConvertible.self)
                }
                return [keyName: convertable.description]
            case .dict:
                if let fit = input as? [String: String] {
                    return fit
                }
                
                guard let dict = input as? [String: Any] else {
                    throw VegaError.createTypeDismatchError(input, typeToMatch: [String: Any].self)
                }
                
                let outputDict = try dict.mapValues { value -> String in
                    guard let convertable = value as? CustomStringConvertible else {
                        throw VegaError.createTypeDismatchError(input, typeToMatch: [String: String].self)
                    }
                    return convertable.description
                }
                return outputDict
            }
        }
}
