//
//  JSONConverter.swift
//  TestN
//
//  Created by kensou on 2021/4/26.
//

import Foundation

public class DefaultJSONConverter: DataConverter {
    public func convert<Input, Output>(action: ActionModel<Input, Output>) -> RequestData {
        return action.requestData
    }
    
    public func convert<Input, Output>(action: ActionModel<Input, Output>, responseData: ResponseData) -> Result<Output, Error> {
        if let error = responseData.validate() {
            return .failure(error)
        }
        return action.decodeResponseData(responseData)
    }
}
