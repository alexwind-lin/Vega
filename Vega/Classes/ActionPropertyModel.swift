//
//  ActionModel.swift
//  TestN
//
//  Created by alex on 2021/4/16.
//

import Foundation

internal class ActionPropertyModel {
    public private(set) var baseUrl: String = ""
    public private(set) var path: String = ""
    public private(set) var httpMethod: String = "get"
    public private(set) var timeout: TimeInterval?
    public private(set) var retry: Int = 0
    public private(set) var httpHeaders: [String: String] = [:]
    public private(set) var provider: VegaProviderIdentifier?
    public private(set) var userInfo: [String: Any] = [:]
    
    public init(with properties: [ActionProperty]) {
        self.update(properties: properties)
        
        if self.baseUrl.isEmpty {
            self.baseUrl = self.provider.provider.baseUrl ?? ""
        }
    }
    
    internal init(with source: ActionPropertyModel) {
        self.baseUrl = source.baseUrl
        self.path = source.path
        self.httpMethod = source.httpMethod
        self.timeout = source.timeout
        self.retry = source.retry
        self.httpHeaders = source.httpHeaders
        self.provider = source.provider
        self.userInfo = source.userInfo
    }
    
    func update(properties: [ActionProperty]) {
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
            case .retry(let count):
                self.retry = count
            case .custom(let key, let value):
                self.userInfo[key] = value
            }
        }
    }
    
    func customProperty(forKey: String) -> Any? {
        return self.userInfo[forKey]
    }
    
    func deleteCustomProperty(forKey: String) {
        self.userInfo.removeValue(forKey: forKey)
    }
}

extension ActionPropertyModel {
    func isGetHTTPMethod() -> Bool {
        return self.httpMethod == "get"
    }
}

extension ActionPropertyModel {
    func getRequestData() -> RequestData {
        let requestData = RequestData()
        
        requestData.baseUrl = baseUrl
        requestData.path = path
        requestData.httpMethod = httpMethod
        requestData.timeout = timeout
        requestData.httpHeaders = httpHeaders
        return requestData
    }
}
