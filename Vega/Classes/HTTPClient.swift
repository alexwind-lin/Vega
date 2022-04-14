//
//  NetEngine.swift
//  TestN
//
//  Created by kensou on 2021/4/16.
//

import Foundation

public protocol HTTPClient {
    func performRequest<Input, Output>(action: ActionModel<Input, Output>, requestData: RequestData, completion: @escaping (_ response: ResponseData) -> Void)
}
