//
//  ActionOutputBox.swift
//  Vega
//
//  Created by alex on 2021/6/5.
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
    // 如果返回返回的数据节点没有对应字段，则直接返回一个ActionOutputValue
    // 非Empty的返回值在获取data时会抛出异常
    return try decodeIfPresent(type, forKey: forKey) ?? .init()
  }
}

@propertyWrapper
public struct ActionOutputValue<T> {
    private var data: T!
    
    public var wrappedValue: T {
        if isEmptyWrapper() {
            return Empty.empty as! T
        }
        return data
    }
    
    fileprivate func isEmptyWrapper() -> Bool {
        if T.self is Empty.Type || T.self is Optional<Empty>.Type {
            return true
        }
        return false
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

        if isEmptyWrapper() {
            data = Empty.empty as? T
            return
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
        
        if isDictConvertable(outputType)  {
            data = try decodeKeyedValues(decoder, outputType: outputType)
        }
        
        if case .raw = outputType {
            data = try decodeRawType(decoder)
        }
    }
    
    private func getNonOptionalType() -> Any {
        var rawType: Any = T.self
        if let type = T.self as? AnyOptional.Type {
            rawType = type.wrappedNonOptionalType
        }
        return rawType
    }
    
    private func isDictConvertable(_ outputType: ActionOutput) -> Bool {
        switch outputType {
        case .tuple, .key:
            return true
        case .decodable, .raw:
            return false
        }
    }
    
    private func decodeKeyedValues(_ decoder: Decoder, outputType: ActionOutput) throws -> T {
        let keyedContainer = try decoder.container(keyedBy: JSONCodingKeys.self)
        let dict: [String: Any] = try keyedContainer.decode([String: Any].self)
        switch outputType {
        case .raw:
            guard let cast = dict as? T else {
                throw VegaError(code: -1, errorDescription: "\(dict) is not type of \(T.self)")
            }
            return cast
        case .tuple:
            return try dict.getTupleValue()
        case .key(let key):
            guard let value = dict[key] as? T else {
                throw VegaError(code: -1, errorDescription: "the value of key [\(key)] is \(String(describing: dict[key])), it is not type \(T.self)")

            }
            return value
        case .decodable:
            throw VegaError(code: -1, errorDescription: "should not arrived here")
        }
    }
    
    private func decodeRawType(_ decoder: Decoder) throws -> T {
        let rawType = getNonOptionalType()
        if rawType is String.Type {
            let singleContainer = try decoder.singleValueContainer()
            return try singleContainer.decode(String.self) as! T
        } else if rawType is [Any].Type {
            var container = try decoder.unkeyedContainer()
            return try container.decode([Any].self) as! T
        } else if rawType is [String: Any].Type {
            return try decodeKeyedValues(decoder, outputType: .raw)
        } else {
            throw VegaError(code: VegaErrorType.typeDismatch.rawValue, errorDescription: "output type .raw only support String/[Any]/[String: Any], or do you want to use .decodable?")
        }
    }
    
    private func decodeArrayValues(_ decoder: Decoder) throws -> T {
        fatalError()
    }
}
