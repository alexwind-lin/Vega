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
    var actionRequestInterceptors: [ActionRequestInterceptor] { get }
    var actionResponseInterceptors: [ActionResponseInterceptor] { get }
    var queue: DispatchQueue { get }
    
    func enqueue<Input, Output>(action: ActionModel<Input, Output>, completion: ((Result<Output, Error>) -> Void)?)
}

internal struct DefaultVegaProvider: VegaProvider {
    var baseUrl: String?
    var identifier: VegaProviderIdentifier
    var httpClient: HTTPClient
    var converter: DataConverter
    var interceptors: [DataInterceptor] = []
    var actionRequestInterceptors: [ActionRequestInterceptor] = []
    var actionResponseInterceptors: [ActionResponseInterceptor] = []
    var queue: DispatchQueue = .main
    
    init(identifier: VegaProviderIdentifier, httpClient: HTTPClient, converter: DataConverter) {
        self.identifier = identifier
        self.httpClient = httpClient
        self.converter = converter
    }
}
