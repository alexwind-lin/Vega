//
//  ActionModel.swift
//  TestN
//
//  Created by kensou on 2021/4/16.
//

import Foundation

public class ActionProperty {
    public var baseUrl: String?
    public var path: String
    public var httpMethod: String?
    public var timeout: TimeInterval?
    public var httpHeaders: [String: String]?
    public var provider: VegaProviderIdentifier?
    
    public init(_ path: String,
         baseUrl: String? = nil,
         httpMethod: String? = nil,
         timeout: TimeInterval? = nil,
         httpHeaders: [String: String]? = nil,
         provider: VegaProviderIdentifier? = nil
         ) {
        
        self.path = path
        self.timeout = timeout
        self.baseUrl = nil
        self.httpMethod = httpMethod
        self.httpHeaders = httpHeaders
        self.provider = provider
    }
}
