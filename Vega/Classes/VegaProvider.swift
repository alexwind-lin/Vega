//
//  ScapeGoatProvider.swift
//  TestN
//
//  Created by kensou on 2021/4/26.
//

import Foundation

public typealias VegaProviderIdentifier = String

internal protocol VegaProvider {
    var identifier: VegaProviderIdentifier { get }
    var baseUrl: String? { get }
    var httpClient: HTTPClient { get }
    var converter: DataConverter { get }
    var interceptors: [ActionInterceptor] { get }
}

internal struct DefaultVegaProvider: VegaProvider {
    var identifier: VegaProviderIdentifier
    var baseUrl: String?
    var httpClient: HTTPClient
    var converter: DataConverter
    var interceptors: [ActionInterceptor] = []
}
