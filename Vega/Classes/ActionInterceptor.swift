//
//  ActionInterceptor.swift
//  TestN
//
//  Created by kensou on 2021/4/19.
//

import Foundation

public typealias RequestInterceptor = (_ data: RequestData) -> RequestData
public typealias ResponseInterceptor = (_ data: ResponseData) -> ResponseData
