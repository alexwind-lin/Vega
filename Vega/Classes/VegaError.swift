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
