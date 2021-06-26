//
//  DataConverter.swift
//  TestN
//
//  Created by kensou on 2021/4/26.
//

import Foundation

public protocol RequestConverter {
    func convert<Input, Output>(action: ActionModel<Input, Output>) -> RequestData
}

public protocol ResponseConverter {
    func convert<Input, Output>(action: ActionModel<Input, Output>, responseData: ResponseData) -> Result<Output, Error>
}

public typealias DataConverter = RequestConverter & ResponseConverter
