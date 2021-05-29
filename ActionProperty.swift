//
//  ActionProperty.swift
//  Vega
//
//  Created by kensou on 2021/5/29.
//

import Foundation

public enum ActionProperty {
    case baseUrl(String)
    case path(String)
    case httpMethod(String)
    case timeout(TimeInterval)
    case httpHeaders([String: String])
    case provider(VegaProviderIdentifier)
    case custom(_ key: String, _ value: Any)
}
