//
//  TemplateB.swift
//  TestN
//
//  Created by kensou on 2021/4/27.
//

#if false

struct CustomResponse<T>: Decodable{
    var code: Int
    var message: String?
    var data: Any?
    
    enum CodingKeys: String, CodingKey {
        case code
        case message
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.code = try container.decode(Int.self, forKey: .code)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        
        guard self.code == 0 else {
            self.data = nil
            return
        }
        
        if let decodableType = T.self as? Decodable.Type {
            self.data = try decodableType.init(container: container, key: .data)
        } else {
            self.data = try container.decode([String: Any].self, forKey: .data)
        }
    }
    
    func format<Output>(by type: ActionOutput) -> Result<Output, Error> {
        guard self.code == 0 else {
            return .failure(VegaError(code: self.code, errorDescription: self.message))
        }
                
        do {
            let result: Output = try type.transform(from: self.data!)
            return .success(result)
        } catch let error {
            return .failure(error)
        }
    }
}

struct CustomJSONConverter: DataConverter {
    func convert<Input, Output>(action: ActionModel<Input, Output>) -> RequestData {
        return action.requestData
    }

    func convert<Input, Output>(action: ActionModel<Input, Output>, responseData: ResponseData) -> Result<Output, Error> {
        if let error = responseData.validate() {
            return .failure(error)
        }
        
        let data = responseData.data ?? Data()
        
        do {
            let type = action.outputType
            if (type.isDecodableType) {
                return try JSONDecoder().decode(CustomResponse<Output>.self, from: data).format(by: type)
            } else {
                return try JSONDecoder().decode(CustomResponse<[String: Any]>.self, from: data).format(by: type)
            }
        } catch let error {
            return .failure(error)
        }
    }
}
#endif
