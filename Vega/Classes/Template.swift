//
//  Template.swift
//  TestN
//
//  Created by kensou on 2021/5/7.
//

#if false
import Foundation

struct CustomResponse<T: Decodable>: Decodable{
    var code: Int
    var message: String?
    var data: T?
}

struct CustomJSONConverter: CodableDataConverter {
    func convert<Input, Output>(action: ActionModel<Input, Output>) -> RequestData where Input : Encodable {
        return action.requestData
    }
    
    func convert<Input, Output>(action: ActionModel<Input, Output>, responseData: ResponseData) -> Result<Output, Error> where Output : Decodable {
        if let error = responseData.validate() {
            return .failure(error)
        }

        let data = responseData.data ?? Data()
        
        do {
            let response = try JSONDecoder().decode(CustomResponse<Output>.self, from: data)
            if (response.code == 0) {
                guard let data = response.data else {
                    return .failure(VegaError(code: -1, errorDescription: "The data is nil"))
                }
                
                return .success(data)
            } else {
                return .failure(VegaError(code: response.code, errorDescription: response.message))
            }
        } catch let error {
            return .failure(error)
        }
    }
}
#endif
