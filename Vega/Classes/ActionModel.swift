//
//  ActionModel.swift
//  TestN
//
//  Created by kensou on 2021/4/16.
//

import Foundation

public protocol ActionModelDelegate: AnyObject {
    func actionDidStart<Input, Output>(_ action: ActionModel<Input, Output>)
    func actionDidFinish<Input, Output>(_ action: ActionModel<Input, Output>, result: Result<Output, Error>)
}

public class ActionModel<Input, Output> {
    public let property: ActionPropertyModel
    public let inputType: ActionInput
    public let outputType: ActionOutput
    public weak var delegate: ActionModelDelegate?
    
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
        
        self.delegate?.actionDidStart(self)
        self.enqueue {[weak self] result in
            guard let self = self else {
                return
            }
            self.delegate?.actionDidFinish(self, result: result)
        }
        self.enqueue(completion)
    }
    
    public func request(_ completion: ((Result<Output, Error>) -> Void)?) where Input == Empty {
        self.request(.empty, completion: completion)
    }    
}
