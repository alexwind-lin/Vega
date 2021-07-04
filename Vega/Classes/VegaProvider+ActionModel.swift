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
        let allActionInterceptors = actionInterceptors
        
        // 检查ActionInterceptor，如果被中断，则不继续执行
        guard let action = performActionRequestInterceptor(action: action, with: allActionInterceptors) else {
            return
        }
        
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
            
            // 检查ActionInterceptor，如果被中断，则不调用completion
            guard let _ = perfromActionResponseInterceptor(action: action, result: result, with: allActionInterceptors.reversed()) else {
                return
            }
            completion?(result)
        }
    }
    
    private func performActionRequestInterceptor<Input, Output>(action: ActionModel<Input, Output>, with allInterceptors: [ActionInterceptor]) -> ActionModel<Input, Output>? {
        var transformedAction: ActionModel<Input, Output> = action
        for interceptor in allInterceptors {
            guard let act = interceptor.process(action: transformedAction, input: action.input) else {
                return nil
            }
            transformedAction = act
        }
        return transformedAction
    }
    
    private func perfromActionResponseInterceptor<Input, Output>(action: ActionModel<Input, Output>, result: Result<Output, Error>, with allInterceptors: [ActionInterceptor]) -> ActionModel<Input, Output>? {
        var transformedAction: ActionModel<Input, Output> = action
        for interceptor in allInterceptors {
            guard let act = interceptor.process(action: transformedAction, result: result) else {
                return nil
            }
            transformedAction = act
        }
        return transformedAction
    }
}
