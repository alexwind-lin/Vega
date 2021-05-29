//
//  ActionModel.swift
//  TestN
//
//  Created by kensou on 2021/4/16.
//

import Foundation

public class ActionPropertyModel {
    public var baseUrl: String?
    public var path: String = ""
    public var httpMethod: String = "get"
    public var timeout: TimeInterval?
    public var httpHeaders: [String: String] = [:]
    public var provider: VegaProviderIdentifier?
    public var userInfo: [String: Any] = [:]
    
    public init(with properties: [ActionProperty]) {
        properties.forEach { (property) in
            switch property {
            case .baseUrl(let url):
                self.baseUrl = url
            case .path(let path):
                self.path = path
            case .httpMethod(let method):
                self.httpMethod = method.lowercased()
            case .timeout(let timeout):
                self.timeout = timeout
            case .httpHeaders(let dict):
                self.httpHeaders.merge(dict) { _, new in new }
            case .provider(let identifier):
                self.provider = identifier
            case .custom(let key, let value):
                self.userInfo[key] = value
            }
            
        }
    }
}
