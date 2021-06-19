# Vega
Vega
======
Vega是参照Retrofit使用方式写的一个声明式网络请求描述框架

使用方式：
------
pod 'Vega'


如何发起请求
------
在简单的配置之后，你可以两行代码就实现一个网络接口
例如：请求Github的REST接口

```swift
@GET("https://api.github.com/orgs/apple/repos")
static var appleRepositories: ActionModel<Empty, [GHRepository]>
```
调用代码同样简单：
```swift
appleRepositories.request { (result) in
	switch result {
	case .failure(let error):
		break
	case .success(let list): // list: [GHRepository]
		break
	}
}
```

如何描述一个网络接口
------
```swift
var myNetApi: ActionModel<PageSize, BookList>
```
一个ActionModel就是一个请求，后面跟上请求参数类型和输出参数类型，上面的例子中，PageSize是请求的输入类型，BookList则是输出的类型。
当然，只是写明ActionModel还不够，我们还要给他加上标注信息
```swift
@GET("my/book/list/path")
var myNetApi: ActionModel<Input, Output>
```
这样就完成了一个请求的描述。
实际上GET/POST，还支持另外几个参数
```swift
@GET(_ path: String, _ properties: ActionModelProperty..., input: ActionInput, output: ActionOutput)
```
多种的请求描述方式
------
你还可以使用以下的方式来描述接口
```swift
@GET("my/path", input: .tuple)
static var getSuggestedBookList: ActionModel<(age: Int, category: String), [Book]>
```
使用起来像这样：
```
getSuggestedBookList.request((age: 10, category: "cartoon")) { (result) in
	print(result)
}
```

input一共支持如下种类：
```swift
public enum ActionInput {
	case encodable          // 输入类型是Encodable类型
	case dict               // 输入类型是Dict
	case key(_ keyName: String) //输入的数据以[key: value]方式上传
	case tuple              //输入的数据以[tupleKey1: tupleValue1, tupleKey2: tupleValue2, ...]方式上传
}
```

同样，如果你不想要所有的输出数据，而只关心某些键值对，一样可以有不同的描述方式
```swift
public enum ActionOutput {
	case decodable          // 输出是Decodable类型
	case dict               // 输出是Dict类型
	case value(_ key: String)   // 从获取的数据中，找出指定key的值作为输出
	case tuple              // 从获取的数据中，找到tuple中指定的key做为输出
}
```

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
