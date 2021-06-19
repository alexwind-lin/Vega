//
//  CustomDataConverter.swift
//  Vega_Example
//
//  Created by kensou on 2021/6/19.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Vega

class CustomResponse<T>: Decodable {
    var code: Int?
    var message: String?
    @ActionOutputValue
    var data: T?
}

class CustomDataConverter: DataConverter {
    func convert<Input, Output>(action: ActionModel<Input, Output>) -> RequestData {
        let requestData = action.getRequestData()
        return requestData

    }
    
    func convert<Input, Output>(action: ActionModel<Input, Output>, responseData: ResponseData) -> Result<Output, Error> {
        if let error = responseData.validate() {
            return .failure(error)
        }
        
        do {
            let response = try JSONDecoder().bind(actionOutput: action.outputType).decode(CustomResponse<Output>.self, from: responseData.data ?? Data())
            
            if let code = response.code, code == 0, let value = response.data {
                return .success(value)
            } else {
                let error = NSError(domain: "", code: response.code ?? -1, userInfo: [
                    NSLocalizedDescriptionKey: response.message ?? "error"
                ])
                return .failure(error)
            }
            
        } catch let decodeError {
            return .failure(decodeError)
        }
    }
    
    
}

