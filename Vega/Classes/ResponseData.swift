//
//  ResponseData.swift
//  TestN
//
//  Created by kensou on 2021/4/19.
//

import Foundation

public class ResponseData {
    public var response: HTTPURLResponse?
    public var data: Data?
    public var error: Error?
    
    public init() {
    }
}

public extension ResponseData {
    func validate() -> Error? {
        guard let response = self.response else {
            return VegaError(code: -1, errorDescription: "no http resonse returned")
        }
        
        let statusCode = response.statusCode
        guard statusCode >= 200, statusCode < 300 else {
            var desc = "Invalid Status Code \(statusCode)"
            if let data = self.data, let extraMessage = String(data: data, encoding: .utf8) {
                desc += "[\(extraMessage)]"
            }
            return VegaError(code: statusCode, errorDescription: desc)
        }

        return nil
    }
}
