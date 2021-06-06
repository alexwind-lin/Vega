//
//  VegaError.swift
//  TestN
//
//  Created by kensou on 2021/4/26.
//

import Foundation

public struct VegaError: LocalizedError {
    public var code: Int = 0
    public var errorDescription: String?
 
    public init(code: Int, errorDescription: String?) {
        self.code = code
        self.errorDescription = errorDescription
    }
}

public enum VegaErrorType: Int {
    case noError = 0
    case unknown = -1
    case typeDismatch = -2
}

public extension VegaError {
    var errorType: VegaErrorType {
        return VegaErrorType(rawValue: self.code) ?? .unknown
    }
    
    init(code: VegaErrorType, errorDescription: String?) {
        self.init(code: code.rawValue, errorDescription: errorDescription)
    }
}

public extension VegaError {
    static func createTypeDismatchError<T>(_ value: Any, typeToMatch: T.Type) -> VegaError {
        let desc = "\(value) can not convert to type \(typeToMatch)"
        return VegaError(code: .typeDismatch, errorDescription: desc)
    }
}
