//
//  VegaProvider+ActionModel.swift
//  TestN
//
//  Created by kensou on 2021/4/27.
//

import Foundation

extension ActionModel {
    func enqueue(_ completion: ((Result<Output, Error>) -> Void)?) {
        self.property.provider.provider.enqueue(action: self, completion: completion)
    }
}

extension VegaProvider {
    func enqueue<Input, Output>(action: ActionModel<Input, Output>, completion: ((Result<Output, Error>) -> Void)?) {
        var requestData = converter.convert(action: action)
        requestInterceptors.forEach { (interceptor) in
            requestData = interceptor(requestData)
        }
        let responseInterceptor = responseInterceptors
        httpClient.performRequest(requestData) { (responseData) in
            var data = responseData
            responseInterceptor.forEach({ (interceptor) in
                data = interceptor(data)
            })
            let result = converter.convert(action: action, responseData: data)
            completion?(result)
        }
    }
}
