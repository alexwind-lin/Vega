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

    func customProperty(forKey: String) -> Any? {
        return self.property.customProperty(forKey: forKey)
    }
    
    func deleteCustomProperty(forKey: String) {
        return self.property.deleteCustomProperty(forKey: forKey)
    }
    
    @discardableResult
    func updateProperty(_ property: ActionProperty) -> ActionModel {
        self.property.update(properties: [property])
        return self
    }
    
    func retry(maxCount: Int) -> ActionModel {
        return self.updateProperty(.retry(maxCount))
    }
}
