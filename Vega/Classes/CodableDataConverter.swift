//
//  CodableDataConverter.swift
//  TestN
//
//  Created by kensou on 2021/5/7.
//

import Foundation

public protocol EncodableRequestConverter {
    func convert<Input: Encodable, Output>(action: ActionModel<Input, Output>) -> RequestData
}

public protocol DecodableResponseConverter {
    func convert<Input, Output: Decodable>(action: ActionModel<Input, Output>, responseData: ResponseData) -> Result<Output, Error>
}

public protocol CodableDataConverter: EncodableRequestConverter & DecodableResponseConverter {
}
