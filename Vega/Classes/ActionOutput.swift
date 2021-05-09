//
//  RequestOutput.swift
//  TestN
//
//  Created by kensou on 2021/4/16.
//

import SweetSugar

public enum ActionOutput {
    case decodable
    case dict
    case value(_ key: String)
    case tuple
}

public extension ActionOutput {
    var isDecodableType: Bool {
        if case .decodable = self {
            return true
        }
        return false
    }
}

public extension ActionOutput {
    func transform<Output>(from object: Any) throws -> Output {
        guard (object is Output) || (object is [String: Any]) else {
            throw VegaError(code: -1, errorDescription: "Unsupported type!! \(object) is not \(Output.self) or [String: Any]")
        }
        
        var decodedObject: Any?
        if case .decodable = self {
            decodedObject = object
        } else {
            guard let dict = object as? [String: Any] else {
                throw VegaError(code: -1, errorDescription: "\(object) can not be cast to [String: Any]")
            }
            
            switch self {
            case .dict:
                decodedObject = dict
            case .tuple:
                let tuple: Output = try getTupleFromDict(dict)
                decodedObject = tuple
                break
            case .value(let key):
                let value = dict[key]
                decodedObject = value
            default:
                throw VegaError(code: -1, errorDescription: "Should not be here")
            }
        }
        
        guard let result = decodedObject as? Output else {
            throw VegaError(code: -1, errorDescription: "\(String(describing: decodedObject)) is not type \(Output.self)")
        }
        return result
    }
    
    func decode<Output>(_ data: Data) throws -> Output {
        let decodedObject: Any
        if case .decodable = self {
            guard let decodableType = Output.self as? Decodable.Type else {
                fatalError("output type is decodable, but \(Output.self) is not decodable")
            }
            
            decodedObject = try decodableType.init(jsonData: data)
        } else {
            decodedObject = try JSONSerialization.jsonObject(with: data, options: [])
        }
        
        let result: Output = try transform(from: decodedObject)
        return result
    }
    
    private func getTupleFromDict<T>(_ dict: [String: Any]) throws -> T {
        let keyList = getTupleKeyList(T.self)
        var result: [Any?] = []
        for key in keyList {
            guard let value = dict[key] else {
                throw VegaError(code: -1, errorDescription: "key [\(key)] not found in \(dict)")
            }

            if value is NSNull {
                result.append(nil)
            } else {
                result.append(value)
            }
        }
        let tuple = result.getTuple()
        guard let object = tuple as? T else {
            throw VegaError(code: -1, errorDescription: "\(tuple) can not cast to \(T.self)")
        }
        return object
    }
    
    fileprivate func getTupleKeyList(_ type: Any) -> [String] {
        let desc = String(describing: type)
        let elements = desc.split(maxSplits: 3, omittingEmptySubsequences: true) { "(,:) ".contains($0) }
        var result: [String] = []
        for i in 0..<elements.count / 2 {
            result.append(String(elements[i * 2]))
        }
        return result
    }
}

fileprivate extension Array {
    func getTuple() -> Any {
        switch self.count {
        case 2:
            return (self[0], self[1])
        case 3:
            return (self[0], self[1], self[2])
        default:
            fatalError("We don't support array with count \(self.count)")
        }
    }
}
