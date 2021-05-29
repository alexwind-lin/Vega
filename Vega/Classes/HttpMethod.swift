//
//  GET.swift
//  TestN
//
//  Created by kensou on 2021/4/16.
//

import Foundation

public class ActionAnnotation<Input, Output>: BaseAnnotation {
    func createDefaultActionModel() -> ActionModel<Input, Output> {
        let action: ActionModel<Input, Output> = ActionModel<Input, Output>(annotation: self)
        return action
    }
}

@propertyWrapper
public class GET<Input, Output>: ActionAnnotation<Input, Output> {
    typealias Input = Input
    typealias Output = Output
    
    public var wrappedValue: ActionModel<Input, Output> {
        return self.createDefaultActionModel()
    }
    
    public override func customize() {
        self.propertyModel.httpMethod = "get"
    }
}


@propertyWrapper
public class POST<Input, Output>: ActionAnnotation<Input, Output> {
    typealias Input = Input
    typealias Output = Output
    
    public var wrappedValue: ActionModel<Input, Output> {
        return self.createDefaultActionModel()
    }
    
    public override func customize() {
        self.propertyModel.httpMethod = "post"
    }
}

