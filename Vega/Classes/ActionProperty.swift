//
//  ActionProperty.swift
//  Vega
//
//  Created by alex on 2021/5/29.
//

import Foundation

public enum ActionProperty {
    case baseUrl(String)        // BaseURL 这个字段会覆盖Provider的baseUrl字段
    case path(String)
    case httpMethod(String)
    case timeout(TimeInterval)
    case httpHeaders([String: String])
    case provider(VegaProviderIdentifier)   // 指定这个请求使用哪个VegaProvider
    case retry(Int) // 指定重试次数
    case custom(_ key: String, _ value: Any)    // 留待自定义扩展使用
}


// MARK: - 扩展自定义属性
/// e.g:
///     extension ActionProperty {
///         static var useEncrypt: ActionCustomProperty<Bool> = .init("useEncrypt")
///     }
/// 可以通过类似@POST("", .useEncrypt(true))来设置
