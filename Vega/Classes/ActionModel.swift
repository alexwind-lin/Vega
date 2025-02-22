//
//  ActionModel.swift
//  TestN
//
//  Created by alex on 2021/4/16.
//

import Foundation

public class ActionModel<Input, Output> {
    internal let property: ActionPropertyModel
    public let inputType: ActionInput
    public let outputType: ActionOutput
    
    internal var requestInterceptorList: [ActionRequestInterceptor] = []
    internal var responseInterceptorList: [ActionResponseInterceptor] = []

    internal var progressHandler: ((_ completeCount: Int64, _ totalCount: Int64) -> Void)?
    
    private var _input: Input!
    public var input: Input {
        return _input
    }
        
    public init(annotation: ActionAnnotation<Input, Output>) {
        self.property = .init(with: annotation.propertyModel)
        self.inputType = annotation.inputType
        self.outputType = annotation.outputType
    }
    
    public func addRequestInterceptor(_ interceptor: ActionRequestInterceptor, insertAtHead: Bool = false) {
        if insertAtHead {
            self.requestInterceptorList.insert(interceptor, at: 0)
        } else {
            self.requestInterceptorList.append(interceptor)
        }
    }
    
    public func addResponseInterceptor(_ interceptor: ActionResponseInterceptor, insertAtHeader: Bool = false) {
        if insertAtHeader {
            self.responseInterceptorList.insert(interceptor, at: 0)
        } else {
            self.responseInterceptorList.append(interceptor)
        }
    }
    
    
    public dynamic func request(_ input: Input, completion: ((Result<Output, Error>) -> Void)?) {
        self._input = input
        self.enqueue(completion)
    }
    
    public func request(_ completion: ((Result<Output, Error>) -> Void)?) where Input == Empty {
        self.request(.empty, completion: completion)
    }
    
    // 用于设置进度回调函数
    public func progress(_ handler: @escaping ((_ completeCount: Int64, _ totalCount: Int64) -> Void)) {
        self.progressHandler = handler
    }
    
    // HTTPClient可以调用这个函数进行进度更新
    public func updateProgress(completeCount: Int64, totalCount: Int64) {
        self.progressHandler?(completeCount, totalCount)
    }
}
