//
//  ActionProperty.swift
//  Vega
//
//  Created by kensou on 2021/5/29.
//

import Foundation

public enum ActionProperty {
    case baseUrl(String)        // BaseURL 这个字段会覆盖Provider的baseUrl字段
    case path(String)
    case httpMethod(String)
    case timeout(TimeInterval)
    case httpHeaders([String: String])
    case provider(VegaProviderIdentifier)   // 指定这个请求使用哪个VegaProvider
    case custom(_ key: String, _ value: Any)    // 留待自定义扩展使用
}
