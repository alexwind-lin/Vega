//
//  ActionPropertyExtension.swift
//  Vega
//
//  Created by alex on 2023/8/8.
//

import Foundation

public class ActionCustomProperty<T> {
    public let label: String
    public init(_ label: String) {
        self.label = label
    }
    
    public func callAsFunction(_ param: T) -> ActionProperty {
        return .custom(label, param)
    }
}

extension ActionCustomProperty where T == Void {
    public func callAsFunction() -> ActionProperty {
        return .custom(label, Void.self)
    }
}
