//
//  JSONConverter.swift
//  TestN
//
//  Created by kensou on 2021/4/26.
//

import Foundation

public extension ActionModel {
    func getRequestData() -> RequestData {
        let requestData = property.getRequestData()
        if property.isGetHTTPMethod() {
            requestData.parameters = inputType.encodeInputToDict(input)
        } else {
            requestData.body = try? inputType.encodeInputToJSON(input)
        }
        return requestData
    }
}

public class DefaultJSONConverter: DataConverter {
    public func convert<Input, Output>(action: ActionModel<Input, Output>) -> RequestData {
        return action.getRequestData()
    }
    
    public func convert<Input, Output>(action: ActionModel<Input, Output>, responseData: ResponseData) -> Result<Output, Error> {
        if let error = responseData.validate() {
            return .failure(error)
        }
        
        do {
            let value = try JSONDecoder().bind(actionOutput: action.outputType).decode(ActionOutputValue<Output>.self, from: responseData.data ?? Data())
            return .success(value.wrappedValue)
        } catch let decodeError {
            return .failure(decodeError)
        }
    }
}
