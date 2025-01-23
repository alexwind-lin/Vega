//
//  FakeHTTPClient.swift
//  Vega_Example
//
//  Created by alex on 2021/6/19.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Vega

class FakeHTTPClient: HTTPClient {
    func performRequest<Input, Output>(action: ActionModel<Input, Output>, requestData: RequestData, completion: @escaping (ResponseData) -> Void) {
        let responseData = ResponseData()
        let httpResponse = HTTPURLResponse(url: URL(fileURLWithPath: "/"), statusCode: 200, httpVersion: nil, headerFields: nil)
        responseData.response = httpResponse
        if let body = requestData.body {
            responseData.data = body
        } else {
            responseData.data = try? JSONSerialization.data(withJSONObject: requestData.parameters, options: [])
        }
        
        completion(responseData)
    }
}
