//
//  DefaultHTTPClient.swift
//  TestN
//
//  Created by kensou on 2021/4/27.
//

import Foundation
#if canImport(Alamofire)
import Alamofire
#endif

public class DefaultHTTPClient: HTTPClient {
    #if canImport(Alamofire)
    let client = AlamofireHTTPClient()
    #else
    let client = SystemHTTPClient()
    #endif
    
    public func performRequest<Input, Output>(action: ActionModel<Input, Output>, requestData: RequestData, completion: @escaping (ResponseData) -> Void) {
        client.performRequest(action: action, requestData: requestData, completion: completion)
    }
}

#if canImport(Alamofire)
class AlamofireHTTPClient: HTTPClient {
    func performRequest<Input, Output>(action: ActionModel<Input, Output>, requestData: RequestData, completion: @escaping (ResponseData) -> Void) {
        let url = requestData.url
        let headers = HTTPHeaders(requestData.httpHeaders)
        let request = AF.request(url, method: .init(rawValue: requestData.httpMethod), parameters: requestData.body, encoder: RawEncoder.default, headers: headers) { (urlRequest) in
            if let timeout = requestData.timeout {
                urlRequest.timeoutInterval = timeout
            }
        }
        request.responseData { (afResponse) in
            let responseData = ResponseData()
            responseData.data = afResponse.data
            responseData.error = afResponse.error
            responseData.response = afResponse.response
            completion(responseData)
        }
    }
    
    class RawEncoder: ParameterEncoder {
        static var `default`: RawEncoder { RawEncoder() }
        
        func encode<Parameters>(_ parameters: Parameters?, into request: URLRequest) throws -> URLRequest where Parameters : Encodable {
            var request = request
            request.httpBody = parameters as? Data
            return request
        }
    }
}
#else
class SystemHTTPClient: HTTPClient {
    func performRequest<Input, Output>(action: ActionModel<Input, Output>, requestData: RequestData, completion: @escaping (ResponseData) -> Void) {
        var request = URLRequest(url: requestData.url)
        if let timeout = requestData.timeout {
            request.timeoutInterval = timeout
        }
        requestData.httpHeaders.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = requestData.body
        request.httpMethod = requestData.httpMethod
        
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            let responseData = ResponseData()
            responseData.data = data
            responseData.error = error
            responseData.response = (urlResponse as? HTTPURLResponse)
            completion(responseData)
        }
        
        task.resume()
    }
    
    
}
#endif
