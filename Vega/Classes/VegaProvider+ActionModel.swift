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
        let property = action.property
        property.baseUrl = property.baseUrl ?? self.baseUrl
        var requestData = action.convert(using: converter)
        requestInterceptors.forEach { (interceptor) in
            requestData = interceptor(requestData)
        }
        let responseInterceptor = responseInterceptors
        httpClient.performRequest(requestData) { (responseData) in
            var data = responseData
            responseInterceptor.forEach({ (interceptor) in
                data = interceptor(data)
            })
            let result = action.convert(data, using: converter)
            completion?(result)
        }
    }
}

// MARK: - 将泛型降级到具体Encodable/Decodable
// 利用init来做点trick
fileprivate extension Encodable {
    init?<Input, Output>(from action: ActionModel<Input, Output>, converter: EncodableRequestConverter, completion: (RequestData) -> Void) {
        let transformed = action as! ActionModel<Self, Output>
        let data = converter.convert(action: transformed)
        completion(data)
        return nil
    }
}

fileprivate extension Decodable {
    init<Input, Output>(from action: ActionModel<Input, Output>, responseData: ResponseData, converter: DecodableResponseConverter) throws {
        let transformed = action as! ActionModel<Input, Self>
        let data = converter.convert(action: transformed, responseData: responseData)
        switch data {
        case .failure(let error):
            throw error
        case .success(let result):
            self = result
        }
    }
}
// MARK: - End: 将泛型降级到具体Encodable/Decodable

fileprivate extension ActionModel {
    func convert(using factory: DataFactory) -> RequestData {
        switch factory {
        case .codable(let converter):
            guard case .encodable = self.inputType, case .decodable = self.outputType else {
                fatalError("CodableDataConverter only apply to ActionInput to be .encodable, ActionOutput to be .decodable")
            }
            
            guard let encodableType = Input.self as? Encodable.Type else {
                fatalError("\(Input.self) is not encodable!!")
            }
            
            var requestData: RequestData?
            let _ = encodableType.init(from: self, converter: converter) { data in
                requestData = data
            }
            return requestData!
        case .full(let converter):
            return converter.convert(action: self)
        }
    }
    
    func convert(_ responseData: ResponseData, using factory: DataFactory) -> Result<Output, Error> {
        switch factory {
        case .codable(let converter):
            guard case .encodable = self.inputType, case .decodable = self.outputType else {
                fatalError("CodableDataConverter only apply to input: .encodable, output: .decodable")
            }
            
            guard let decodableType = Output.self as? Decodable.Type else {
                fatalError("\(Output.self) is not decodable!!")
            }
            
            do {
                let result = try decodableType.init(from: self, responseData: responseData, converter: converter) as! Output
                return .success(result)
            } catch let error {
                return .failure(error)
            }
        case .full(let converter):
            return converter.convert(action: self, responseData: responseData)
        }
    }
}
