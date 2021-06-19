//
//  ActionInterceptor.swift
//  TestN
//
//  Created by kensou on 2021/4/19.
//

import Foundation

public protocol RequestInterceptor {
    func process(_ requestData: RequestData) -> RequestData
}

public protocol ResponseInterceptor {
    func process(_ responseData: ResponseData) -> ResponseData
}
