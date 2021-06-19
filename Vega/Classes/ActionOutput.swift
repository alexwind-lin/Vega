//
//  RequestOutput.swift
//  TestN
//
//  Created by kensou on 2021/4/16.
//

public enum ActionOutput {
    case decodable          // 输出是Decodable类型
    case dict               // 输出是Dict类型
    case value(_ key: String)   // 从获取的数据中，找出指定key的值作为输出
    case tuple              // 从获取的数据中，找到tuple中指定的key做为输出
}

public extension ActionOutput {
    var isDecodableType: Bool {
        if case .decodable = self {
            return true
        }
        return false
    }
}
