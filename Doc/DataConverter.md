DataConverter
====
下面介绍一下最基本的DataConverter写法

RequestConverter
----
通常我们的输入数据都是基本的JSON化，所以可以简单这么写
```swift
func convert<Input, Output>(action: ActionModel<Input, Output>) -> RequestData {
    // 默认的是如果是GET，input会被以[String: String]的方式变为RequestData的Parameter
    // 如果是POST，input会被json化，成为RequestData的body
    let requestData = action.getRequestData()
    return requestData
}
```

通常，我们会将HTTPHeader的进一步处理，加密等工作放在[Interceptor](Interceptor.md)处理，但是如果你喜欢在DataConverter里头进行处理也是可以的

```swift
func convert<Input, Output>(action: ActionModel<Input, Output>) -> RequestData {
    // 生成最基础的RequestData，不包括input的数据处理
    let requestData = action.property.getRequestData()
    // 进行你想要的数据处理
    // 然后将它设置到requestData.body或者requestData.parameters
    return requestData
}
```

ResponseConverter
----
如果返回的ResponseData中的data是标准的json结构，你可以参照Demo中的[DefaultJSONConverter](../Vega/Classes/DefaultJSONConverter.swift)来处理

但是，我们现实中更常见的结构是这种类型：
```json
{
    "code": 0,
    "message": "success",
    "data": {
        "xx": "yy"
    }
}
```
实际上，我们上层只关心返回的数据，以及是否有错误，所以这个结构我们可以通过Converter将它屏蔽掉。
对于这种结构的Converter写起来也很简单：
```swift
class CustomResponse<T>: Decodable {
    var code: Int?
    var message: String?
    @ActionOutputValue
    var data: T?
}

class CustomDataConverter: DataConverter {
    func convert<Input, Output>(action: ActionModel<Input, Output>) -> RequestData {
        
        let requestData = action.getRequestData()
        return requestData

    }
    
    func convert<Input, Output>(action: ActionModel<Input, Output>, responseData: ResponseData) -> Result<Output, Error> {
        if let error = responseData.validate() {
            return .failure(error)
        }
        
        do {
            let response = try JSONDecoder().bind(actionOutput: action.outputType).decode(CustomResponse<Output>.self, from: responseData.data ?? Data())
            
            if let code = response.code, code == 0, let value = response.data {
                return .success(value)
            } else {
                let error = NSError(domain: "", code: response.code ?? -1, userInfo: [
                    NSLocalizedDescriptionKey: response.message ?? "error"
                ])
                return .failure(error)
            }
            
        } catch let decodeError {
            return .failure(decodeError)
        }
    }
    
    
}
```

总的来说，你需要处理的事情有这么几个部分：
* 定义自己的原始返回数据结构
* 用@ActionOutputValue将真正的Output字段给标注起来
* 进行JSONDecoder的时候，在decode之前，需要调用
```swift
JSONDecoder().bind(actionOutput: action.outputType)
```
将outputType传递进去，方便ActionOutputValue能够正确地解析出数据
