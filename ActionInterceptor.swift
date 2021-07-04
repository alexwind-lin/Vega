//
//  ActionInterceptor.swift
//  Vega
//
//  Created by kensou on 2021/7/4.
//

public protocol ActionRequestInterceptor {
    /// - returns 如果返回的model为空，则该请求不会被发起，后续流程被终止
    func process<Input, Output>(action: ActionModel<Input, Output>, input: Input) -> ActionModel<Input, Output>?
    
}

public protocol ActionResponseInterceptor {
    /// - returns 如果返回的model为空，则该流程被终止，后续回调不会再被调用
    func process<Input, Output>(action: ActionModel<Input, Output>, result: Result<Output, Error>) -> ActionModel<Input, Output>?
}

public typealias ActionInterceptor = ActionRequestInterceptor & ActionResponseInterceptor
