//
//  ActionInterceptor.swift
//  TestN
//
//  Created by kensou on 2021/4/19.
//

import Foundation

public protocol RequestInterceptor {
    func process(_ data: RequestData) -> RequestData
}

public protocol ResponseInterceptor {
    func process(_ data: ResponseData) -> ResponseData
}
