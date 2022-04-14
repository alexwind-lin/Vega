//
//  EndPoint.swift
//  TestN
//
//  Created by kensou on 2021/4/16.
//

import Foundation

open class RequestData {
    public var baseUrl: String = ""
    public var path: String = ""
    public var httpMethod: String = "get"
    public var httpHeaders: [String: String] = [:]
    public var parameters: [String: String] = [:]
    public var body: Data?
    public var timeout: TimeInterval?
    
    // 用于传递过程中的一些扩展
    public var extendInfo: [String: Any] = [:]
    
    public init() {
    }
}

// MARK: - Add Header
public extension RequestData {
    @discardableResult
    func setHttpHeader(value: String, forKey: String) -> Self {
        httpHeaders[forKey] = value
        return self
    }
    
    @discardableResult
    func addHttpHeaders(_ header: [String: String]) -> Self {
        header.forEach { key, value in
            httpHeaders[key] = value
        }
        return self
    }
}

public extension RequestData {
    var url: URL {
        var base = self.baseUrl
        var other = self.path
        
        if base.count != 0 && !base.hasSuffix("/") {
            base = base + "/"
        }
        
        if other.hasPrefix("/") {
            other.removeFirst()
        }
        
        if (self.parameters.count != 0) {
            if !other.hasSuffix("?") {
                other.append("?")
            }
            
            let array = self.parameters.map { key, value -> String in
                if let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                   let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    return "\(encodedKey)=\(encodedValue)"
                }
                return ""
            }
            let query = array.joined(separator: "&")
            other += query
        }
        return URL(string: base + other)!
    }
}
