//
//  VegaProvider+ActionModel.swift
//  TestN
//
//  Created by alex on 2021/4/27.
//

import Foundation

extension ActionModel {
    typealias Callback = (Result<Output, Error>) -> Void
    func enqueue(_ completion: ((Result<Output, Error>) -> Void)?) {
        let provider = self.property.provider.provider
        provider.queue.async {
            provider.enqueue(action: self, completion: completion)
        }
    }
}

extension DefaultVegaProvider {
    func enqueue<Input, Output>(action: ActionModel<Input, Output>, completion: ((Result<Output, Error>) -> Void)?) {
        var allActionInterceptors: [ActionRequestInterceptor] = action.requestInterceptorList
        allActionInterceptors.append(contentsOf: actionRequestInterceptors)
        
        // 检查ActionInterceptor，如果被中断，则不继续执行
        performActionRequestInterceptor(action: action, with: allActionInterceptors) { result in
            performHTTPRequest(result, completion: completion)
        }
    }
    
    private func performHTTPRequest<Input, Output>(_ interceptResult: RequestInterceptResult<Input, Output>, completion: ((Result<Output, Error>) -> Void)?) {
        switch interceptResult.state {
        case .error(let error):
            let response: ResponseData = .init()
            response.error = error
            // 这种情况暂时忽略重试次数
            onHTTPResponse(action: interceptResult.model, responseData: response, retryCount: 0, completion: completion)
            break
        case .passthrough:
            let action = interceptResult.model
            
            performHTTPRequest(action: action, retryCount: action.property.retry) { result in
                performActionResponseInterceptor(action: action, result: result, completion: completion)
            }
        }
    }
    
    private func performActionResponseInterceptor<Input, Output>(action: ActionModel<Input, Output>, result: Result<Output, Error>, completion: ((Result<Output, Error>) -> Void)?) {
        var allActionInterceptors: [ActionResponseInterceptor] = self.actionResponseInterceptors
        allActionInterceptors.append(contentsOf: action.responseInterceptorList)

        // 检查ActionInterceptor
        let lastResult = perfromActionResponseInterceptor(action: action, result: result, with: allActionInterceptors)
        completion?(lastResult)
    }
    
    private func performHTTPRequest<Input, Output>(action: ActionModel<Input, Output>, retryCount: Int, completion: ((Result<Output, Error>) -> Void)?) {
        var requestData = converter.convert(action: action)
        let allInterceptors = interceptors
        allInterceptors.forEach { (interceptor) in
            requestData = interceptor.process(action: action, requestData: requestData)
        }
        
        
        httpClient.performRequest(action: action, requestData: requestData) { (responseData) in
            onHTTPResponse(action: action, responseData: responseData, retryCount: retryCount, completion: completion)
        }
    }
    
    private func onHTTPResponse<Input, Output>(action: ActionModel<Input, Output>, responseData: ResponseData, retryCount: Int, completion: ((Result<Output, Error>) -> Void)?) {
        var data = performDataResponseInterceptor(action: action, responseData: responseData)
        let result = converter.convert(action: action, responseData: data)
        if case .failure = result, retryCount > 0 {
            performHTTPRequest(action: action, retryCount: retryCount - 1, completion: completion)
            return
        }
        
        completion?(result)
    }
    
    private func performDataResponseInterceptor<Input, Output>(action: ActionModel<Input, Output>, responseData: ResponseData) -> ResponseData {
        let allInterceptors = interceptors

        var data = responseData
        allInterceptors.reversed().forEach({ (interceptor) in
            data = interceptor.process(action: action, responseData: data)
        })
        return data
    }
        
    private func performActionRequestInterceptor<Input, Output>(action: ActionModel<Input, Output>, with allInterceptors: [ActionRequestInterceptor], completion: @escaping (RequestInterceptResult<Input, Output>) -> Void) {
        var list = allInterceptors
        
        guard list.isEmpty == false else {
            completion(.init(model: action, state: .passthrough))
            return
        }
        
        let interceptor = list.removeFirst()
        interceptor.process(action: action, input: action.input) { result in
            switch result.state {
            case .passthrough:
                performActionRequestInterceptor(action: result.model, with: list, completion: completion)
            case .error:
                completion(result)
            }
        }
    }
    
    private func perfromActionResponseInterceptor<Input, Output>(action: ActionModel<Input, Output>, result: Result<Output, Error>, with allInterceptors: [ActionResponseInterceptor]) -> Result<Output, Error> {
        var interceptResult: ResponseInterceptResult<Output> = .init(result: result, state: .passthrough)
        for interceptor in allInterceptors {
            interceptResult = interceptor.process(action: action, result: result)
            if case .breakdown = interceptResult.state {
                break
            }
        }
        
        return interceptResult.result
    }
}
