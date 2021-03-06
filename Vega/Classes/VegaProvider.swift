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
    var interceptors: [DataInterceptor] { get }
    var actionInterceptors: [ActionInterceptor] { get }
    var queue: DispatchQueue { get }
}

internal struct DefaultVegaProvider: VegaProvider {
    var baseUrl: String?
    var identifier: VegaProviderIdentifier
    var httpClient: HTTPClient
    var converter: DataConverter
    var interceptors: [DataInterceptor] = []
    var actionInterceptors: [ActionInterceptor] = []
    var queue: DispatchQueue = .main
    
    init(identifier: VegaProviderIdentifier, httpClient: HTTPClient, converter: DataConverter) {
        self.identifier = identifier
        self.httpClient = httpClient
        self.converter = converter
    }
}
