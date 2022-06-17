//
//  ActionModel+Property.swift
//  Vega
//
//  Created by kensou on 2021/8/16.
//

public extension ActionModel {
    var baseUrl: String {
        return property.baseUrl
    }
    
    var path: String {
        return property.path
    }
    
    var httpMethod: String {
        return property.httpMethod
    }
    
    var timeout: TimeInterval? {
        return property.timeout
    }
    
    var httpHeaders: [String: String] {
        return property.httpHeaders
    }
}

public extension ActionModel {
    // 返回property所代表的requestData
    // 不包含custom的property
    func getBasicRequestData() -> RequestData {
        return property.getRequestData()
    }
    
    func retry(maxCount: Int) -> ActionModel {
        return self.updateProperty(.retry(maxCount))
    }
}

// MARK: - 自定义属性辅助

public protocol ActionCustomPropertyOwner {
    static var shared: Self { get }
}

public protocol ActionCustomPropertyOperator {
    func customProperty(forKey: String) -> Any?
    @discardableResult
    func updateProperty(_ property: ActionProperty) -> Self
    func deleteCustomProperty(forKey: String)
}

extension ActionModel: ActionCustomPropertyOperator {
    public func customProperty(forKey: String) -> Any? {
        return self.property.customProperty(forKey: forKey)
    }
    
    public func deleteCustomProperty(forKey: String) {
        return self.property.deleteCustomProperty(forKey: forKey)
    }
    
    @discardableResult
    public func updateProperty(_ property: ActionProperty) -> Self {
        self.property.update(properties: [property])
        return self
    }
}

public protocol ActionModelCustomPropertyExtension {
    associatedtype PropertyOwner: ActionCustomPropertyOwner
    
    var model: ActionCustomPropertyOperator { get }
    subscript<T>(dynamicMember keyPath: KeyPath<PropertyOwner, ActionCustomProperty<T>>) -> T? { get nonmutating set }
}

public struct ActionCustomProperty<T> {
    public let label: String

    public func callAsFunction(_ param: T) -> ActionProperty {
        return .custom(label, param)
    }
}

extension ActionCustomProperty where T == Void {
    public func callAsFunction() -> ActionProperty {
        return .custom(label, Void.self)
    }
}

// 默认实现
public extension ActionModelCustomPropertyExtension {
    subscript<T>(dynamicMember keyPath: KeyPath<PropertyOwner, ActionCustomProperty<T>>) -> T? {
        get {
            let propertyName = PropertyOwner.shared[keyPath: keyPath].label
            return model.customProperty(forKey: propertyName) as? T
        }
        nonmutating set {
            let property = PropertyOwner.shared[keyPath: keyPath]
            if let v = newValue {
                model.updateProperty(.custom(property.label, v))
            } else {
                model.deleteCustomProperty(forKey: property.label)
            }
        }
    }
}
