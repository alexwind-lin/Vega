//
//  EndPoint.swift
//  TestN
//
//  Created by kensou on 2021/4/16.
//

import Foundation

public class RequestData {
    var baseUrl: String = ""
    var path: String = ""
    var httpMethod: String = "get"
    var httpHeaders: [String: String] = [:]
    var parameters: [String: String] = [:]
    var body: Data?
    var timeout: TimeInterval?
}

// MARK: - Add Header
public extension RequestData {
    func addHttpHeader(value: String, key: String) -> Self {
        httpHeaders[key] = value
        return self
    }
    
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
            
            self.parameters.forEach{ other.append("\($0.key)=\($0.value)") }
        }
        return URL(string: base + other)!
    }
}
