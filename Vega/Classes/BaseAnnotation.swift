//
//  NetAnnotation.swift
//  TestN
//
//  Created by kensou on 2021/4/16.
//

import Foundation

public class BaseAnnotation {
    let propertyModel: ActionPropertyModel
    let inputType: ActionInput
    let outputType: ActionOutput
    
    public convenience init(_ path: String, input: ActionInput = .encodable, output: ActionOutput = .decodable) {
        self.init([.path(path)], input: input, output: output)
    }
    
    public init(_ properties: [ActionProperty], input: ActionInput = .encodable, output: ActionOutput = .decodable) {
        self.propertyModel = .init(with: properties)
        self.inputType = input
        self.outputType = output
        
        self.customize()
    }
    
    // 用于子类进行初始化定制
    public func customize() {
        
    }    
}
