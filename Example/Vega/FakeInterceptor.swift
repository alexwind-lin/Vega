//
//  FakeReusltInterceptor.swift
//  Vega_Example
//
//  Created by alex on 2021/6/19.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Vega

class FakeInterceptor: DataInterceptor {
    func process<Input, Output>(action: ActionModel<Input, Output>, requestData: RequestData) -> RequestData {
        let inputData = requestData.body ?? Data()
        let text = String(data: inputData, encoding: .utf8) ?? ""
        let fake = HitoKoto(id: 10001, hitokoto: text, from_who: "Faker Hackin")
        requestData.body = try? JSONEncoder().encode(fake)
        return requestData
    }
    
    func process<Input, Output>(action: ActionModel<Input, Output>, responseData: ResponseData) -> ResponseData {
        guard responseData.error == nil, let data = responseData.data else {
            return responseData
        }

        guard let dict = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return responseData
        }
        
        var result: [String: Any] = [:]
        result["code"] = 0
        result["message"] = "success"
        result["data"] = dict
        guard let outputData = try? JSONSerialization.data(withJSONObject: result, options: []) else {
            return responseData
        }
        
        responseData.data = outputData
        return responseData
    }
    
    
}
