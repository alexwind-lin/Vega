//
//  ActionModel.swift
//  TestN
//
//  Created by kensou on 2021/4/16.
//

import Foundation

public class ActionModel<Input, Output> {
    public let property: ActionPropertyModel
    public let inputType: ActionInput
    public let outputType: ActionOutput
    
    public var input: Input!
    public var callback: ((Result<Output, Error>) -> Void)?
    
    public init(annotation: ActionAnnotation<Input, Output>) {
        self.property = annotation.propertyModel
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
