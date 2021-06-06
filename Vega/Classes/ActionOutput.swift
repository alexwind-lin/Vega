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
