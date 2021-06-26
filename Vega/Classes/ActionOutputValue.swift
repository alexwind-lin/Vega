//
//  ActionOutputBox.swift
//  Vega
//
//  Created by kensou on 2021/6/5.
//

import Foundation
import SweetSugar

extension JSONDecoder {
    fileprivate static var outputTypeKey: CodingUserInfoKey {
        return CodingUserInfoKey(rawValue: "ActionOutputType")!
    }
}

public extension JSONDecoder {
    func bind(actionOutput: ActionOutput) -> Self {
        self.userInfo[JSONDecoder.outputTypeKey] = actionOutput
        return self
    }
}

public extension Decoder {
    var actionOutput: ActionOutput? {
        return self.userInfo[JSONDecoder.outputTypeKey] as? ActionOutput
    }
}

public extension KeyedDecodingContainer {
  func decode<T>(_ type: ActionOutputValue<T?>.Type, forKey: Self.Key) throws -> ActionOutputValue<T?> {
    return try decodeIfPresent(type, forKey: forKey) ?? .init()
  }
}

@propertyWrapper
public struct ActionOutputValue<T> {
    private var data: T!
    
    public var wrappedValue: T {
        if T.self is Empty.Type || T.self is Optional<Empty>.Type {
            return Empty.empty as! T
        }
        return data
    }
    
    public init() {
    }
}

extension ActionOutputValue: Decodable {
    public init(from decoder: Decoder) throws {
        guard let outputType = decoder.actionOutput else {
            let errorDesc = """
            Can not find ActionOutput Key in json decoder!
            please use your json decoder like
            JSONDecoder().bind(actionOutput: myActionOutput).decode(xxx.self, from: data)
            """
            throw VegaError(code: -1, errorDescription: errorDesc)
        }
        
        if outputType.isDecodableType {
            guard let decodableType = T.self as? Decodable.Type else {
                throw VegaError(code: -1, errorDescription: "\(T.self) is not decodable")
            }
            
            let singleContainer = try decoder.singleValueContainer()
            let value = try decodableType.init(container: singleContainer)
            guard let cast = value as? T else {
                throw VegaError(code: -1, errorDescription: "\(value) is not type of \(T.self)")
            }
            data = cast
            return
        }
        
        let keyedContainer = try decoder.container(keyedBy: JSONCodingKeys.self)
        let dict: [String: Any] = try keyedContainer.decode([String: Any].self)
        switch outputType {
        case .dict:
            guard let cast = dict as? T else {
                throw VegaError(code: -1, errorDescription: "\(dict) is not type of \(T.self)")
            }
            data = cast
        case .tuple:
            data = try dict.getTupleValue()
        case .key(let key):
            guard let value = dict[key] as? T else {
                throw VegaError(code: -1, errorDescription: "the value of key [\(key)] is \(String(describing: dict[key])), it is not type \(T.self)")

            }
            data = value
        default:
            throw VegaError(code: -1, errorDescription: "should not arrived here")
        }
    }
}
