//
//  NetAnnotation.swift
//  TestN
//
//  Created by kensou on 2021/4/16.
//

import Foundation

public class BaseAnnotation {
    let actionModel: ActionProperty
    let inputType: ActionInput
    let outputType: ActionOutput
    
    public convenience init(_ path: String, input: ActionInput = .encodable, output: ActionOutput = .decodable) {
        self.init(ActionProperty(path), input: input, output: output)
    }
    
    public init(_ actionModel: ActionProperty, input: ActionInput = .encodable, output: ActionOutput = .decodable) {
        self.actionModel = actionModel
        self.inputType = input
        self.outputType = output
        
        self.customize()
    }
    
    // 用于子类进行初始化定制
    public func customize() {
        
    }    
}
