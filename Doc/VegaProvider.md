VegaProvider
====

如何配置Vega(配置你的VegaProvider)
------
如果你是简单的请求，返回的数据是标准的json结构，你可以这样一句话配置
```
Vega.builder().build()
```

当然，实际项目中不可能是这么简单的。
Vega的实际功能由VegaProvider实现，支持同时存在多个Provider。
VegaProvider提供了以下自定义的功能：
- identifier: 每个VegaProvider的名字，需要唯一
- baseUrl
- HTTPClient：网络请求的发出，输入为RequestData，输出为ResponseData，使用你喜欢的网络框架执行这个动作。
    Vega默认包含了一个简单的HTTPClient，使用的是Alamofire（可用的情况下），或者是系统网络请求（Alamofire不可用时）
- DataConverter：
    - 将ActionModel的ActionProperties和Input转换为RequestData
    - 将ResponseData转换为Result<Output, Error>输出
- RequestInterceptor
    可以对RequestData进行加工，输出依然为RequestData，一般用于做Header的统一处理等工作。按照被添加进去的方式进行顺序处理
- ResponseInterceptor
    可以对HTTPClient返回的ResponseData进行加工，按照添加进去的顺序进行顺序处理

结合起来就像这样：
```swift
Vega.builder("MySpecial")
        .setBaseURL("https://hahahahahaha.com")
        .setHTTPClient(FakeHTTPClient())
        .setConverter(CustomDataConverter())
        .addRequestInterceptor(FakeRequestInterceptor())
        .addResponseInterceptor(FakeResponseInterceptor())        
        .build()  
```
    
如何指定VegaProvider
------
指定VegaProvider需要在GET/POST标注中指定，如：
```swift
@GET("my/path", .provider("MySpecial"), input: .tuple)
static var getSuggestedBookList: ActionModel<(age: Int, category: String), [Book]>
```
这样他就会使用MySpecial的VegaProvider的配置了
