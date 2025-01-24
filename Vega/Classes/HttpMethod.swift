//
//  GET.swift
//  TestN
//
//  Created by alex on 2021/4/16.
//

import Foundation

open class ActionAnnotation<Input, Output>: BaseAnnotation {
    var appendingProperties: [ActionProperty] = []
    
    func createDefaultActionModel() -> ActionModel<Input, Output> {
        let action: ActionModel<Input, Output> = ActionModel<Input, Output>(annotation: self)
        return action
    }
    
    public func appending(property: ActionProperty) {
        self.appendingProperties.append(property)
    }
    
    public override func customize() {
        super.customize()
        self.propertyModel.update(properties: appendingProperties)
    }
}

@propertyWrapper
open class GET<Input, Output>: ActionAnnotation<Input, Output> {
    typealias Input = Input
    typealias Output = Output
    
    open var wrappedValue: ActionModel<Input, Output> {
        return self.createDefaultActionModel()
    }
    
    open override func customize() {
        super.customize()
        self.propertyModel.update(properties: [.httpMethod("get")])
    }
}


@propertyWrapper
open class POST<Input, Output>: ActionAnnotation<Input, Output> {
    typealias Input = Input
    typealias Output = Output
    
    open var wrappedValue: ActionModel<Input, Output> {
        return self.createDefaultActionModel()
    }
    
    open override func customize() {
        super.customize()
        self.propertyModel.update(properties: [.httpMethod("post")])
    }
}

