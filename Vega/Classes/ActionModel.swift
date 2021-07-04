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
    
    private var _input: Input!
    public var input: Input {
        return _input
    }
        
    public init(annotation: ActionAnnotation<Input, Output>) {
        self.property = annotation.propertyModel
        self.inputType = annotation.inputType
        self.outputType = annotation.outputType
    }
    
    public dynamic func request(_ input: Input, completion: ((Result<Output, Error>) -> Void)?) {
        self._input = input
        self.enqueue(completion)
    }
    
    public func request(_ completion: ((Result<Output, Error>) -> Void)?) where Input == Empty {
        self.request(.empty, completion: completion)
    }    
}
