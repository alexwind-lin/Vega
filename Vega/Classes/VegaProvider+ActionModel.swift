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
fileprivate extension Encodable {
    static func convert<Input, Output>(action: ActionModel<Input, Output>, using converter: EncodableRequestConverter) -> RequestData {
        let transformed = action as! ActionModel<Self, Output>
        return converter.convert(action: transformed)
    }
}

fileprivate extension Decodable {
    static func convert<Input, Output>(action: ActionModel<Input, Output>, responseData: ResponseData, using converter: DecodableResponseConverter) -> Result<Output, Error> {
        let transformed = action as! ActionModel<Input, Self>
        let data = converter.convert(action: transformed, responseData: responseData)
        return data as! Result<Output, Error>
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
            
            let requestData = encodableType.convert(action: self, using: converter)
            return requestData
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
            
            return decodableType.convert(action: self, responseData: responseData, using: converter)
        case .full(let converter):
            return converter.convert(action: self, responseData: responseData)
        }
    }
}
