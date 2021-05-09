//
//  RequestInputType.swift
//  TestN
//
//  Created by kensou on 2021/4/16.
//

import SweetSugar

public enum ActionInput {
    case encodable
    case dict
    case value(_ key: String)
    case tuple
}

public extension ActionInput {
    func encode(_ obj: Any) -> Data? {
        switch self {
        case .encodable:
            guard let encodable = obj as? Encodable else {
                fatalError("\(obj) is not an Encodable")
            }
            return encodable.toJSONData()
        case .dict:
            guard let dict = obj as? [String: Any] else {
                fatalError("\(obj) is not an [String: Any]")
            }
            return try? JSONSerialization.data(withJSONObject: dict, options: [])
        case .tuple:
            let dict = Mirror.getDict(from: obj)
            return try? JSONSerialization.data(withJSONObject: dict, options: [])
        case .value(let key):
            let dict: [String: Any] = [key: obj]
            return try? JSONSerialization.data(withJSONObject: dict, options: [])
        }
    }
}
