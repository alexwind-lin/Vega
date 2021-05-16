//
//  ActionModel.swift
//  TestN
//
//  Created by kensou on 2021/4/16.
//

import Foundation

public class ActionModel<Input, Output> {
    public let property: ActionProperty
    public let inputType: ActionInput
    public let outputType: ActionOutput
    
    public var input: Input!
    public var callback: ((Result<Output, Error>) -> Void)?
    
    public init(annotation: ActionAnnotation<Input, Output>) {
        self.property = annotation.actionModel
        self.inputType = annotation.inputType
        self.outputType = annotation.outputType
    }
    
    public func request(_ input: Input, completion: ((Result<Output, Error>) -> Void)?) {
        self.input = input
        self.callback = completion
        self.enqueue(completion)
    }
    
    public func request(_ completion: ((Result<Output, Error>) -> Void)?) where Input == Empty {
        self.request(.empty, completion: completion)
    }    
}

// MARK: - default way to translate ActionModel to RequestData
public extension ActionModel {
    var requestData: RequestData {
        let property = self.property
        let requestData = RequestData()
        
        requestData.baseUrl = property.baseUrl ?? ""
        requestData.path = property.path
        requestData.httpMethod = (property.httpMethod ?? "get").lowercased()
        requestData.timeout = property.timeout
        requestData.httpHeaders = property.httpHeaders ?? [:]
        
        if (property.httpMethod == "get") {
            requestData.parameters = Mirror.descibeObjectAsKeyValue(self.input!)
        } else if (property.httpMethod == "post") {
            requestData.body = self.inputType.encode(self.input!)
        }
        
        return requestData
    }
}

// MARK: - default way to translate ResponseData to Result<Output, Error>
public extension ActionModel {
    func decodeResponseData(_ responseData: ResponseData) -> Result<Output, Error> {
        if let error = responseData.error {
            return .failure(error)
        }
        
        let content = responseData.data ?? Data()
        do {
            let output: Output = try self.outputType.decode(content)
            return .success(output)
        } catch let error {
            return .failure(error)
        }
    }
}
