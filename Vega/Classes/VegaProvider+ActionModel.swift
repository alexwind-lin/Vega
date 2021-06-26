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
        let allInterceptors = interceptors
        allInterceptors.forEach { (interceptor) in
            requestData = interceptor.process(action: action, requestData: requestData)
        }
        httpClient.performRequest(requestData) { (responseData) in
            var data = responseData
            allInterceptors.reversed().forEach({ (interceptor) in
                data = interceptor.process(action: action, responseData: data)
            })
            let result = converter.convert(action: action, responseData: data)
            completion?(result)
        }
    }
}
