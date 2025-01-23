//
//  RequestOutput.swift
//  TestN
//
//  Created by alex on 2021/4/16.
//

public enum ActionOutput {
    case decodable          // 输出是Decodable类型
    case raw                // 输出原样解析的JSON对象,只支持String/[Any]/[String: Any]三种输出
    case key(_ keyName: String)   // 从获取的数据中，找出指定key的值作为输出
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
