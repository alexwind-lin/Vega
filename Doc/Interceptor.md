Interceptor
======
Interceptor中可以修改RequestData和ResponseData，一般可以用于处理自定义的参数加解密的过程，以及一些HTTPHeader的处理

RequestInterceptor示例
```swift
class MyRequestInterceptor: RequestInterceptor {
    func process(_ requestData: RequestData) -> RequestData {
        // 进行通用HTTPHeader的处理
        requestData.addHttpHeader(value: "XXToken", key: "Token")
    
        let inputData = requestData.body 
        // 进行加密处理
        let encryptData = customEncrypt(inputData)
        requestData.body = encryptData
        return requestData
    }
}
```

ResponseInterceptor示例
```swift
class MyResponseInterceptor: ResponseInterceptor {
    func process(_ responseData: ResponseData) -> ResponseData {
        // 不符合条件的就不处理，直接跳过
        guard responseData.error == nil, let data = responseData.data else {
            return responseData
        }
        
        // 解密处理
        let decryptData = customDecrypt(responseData.data)
        responseData.data = decryptData
        return responseData
    }
}
```

当然，你可以在Interceptor里头做一些日志打印，或者统计处理等等
