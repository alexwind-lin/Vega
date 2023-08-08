//
//  ActionInterceptor.swift
//  Vega
//
//  Created by kensou on 2021/7/4.
//

// Interceptor执行结果
public struct RequestInterceptResult<Input, Output> {
    public enum State {
        case passthrough // 继续执行
        case error(_ error: Error) // 发生错误
    }
    let model: ActionModel<Input, Output>
    let state: State
    
    public init(model: ActionModel<Input, Output>, state: State) {
        self.model = model
        self.state = state
    }
}

public struct ResponseInterceptResult<Output> {
    public enum State {
        case passthrough
        case breakdown
    }
    
    let result: Result<Output, Error>
    let state: State
    
    public init(result: Result<Output, Error>, state: State) {
        self.result = result
        self.state = state
    }
}

public protocol ActionResponseInterceptor {
    func process<Input, Output>(action: ActionModel<Input, Output>, result: Result<Output, Error>) -> ResponseInterceptResult<Output>
}

public protocol ActionRequestInterceptor {
    /// - returns 如果返回的model为空，则该请求不会被发起，后续流程被终止
    func process<Input, Output>(action: ActionModel<Input, Output>, input: Input, completion: @escaping (RequestInterceptResult<Input, Output>) -> Void)
}
