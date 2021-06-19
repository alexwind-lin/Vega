Vega是参照Retrofit使用方式写的一个声明式网络请求描述框架

使用方式：
------
```rb
pod 'Vega'
```

如何发起请求
------
在[简单的配置](Doc/VegaProvider.md)之后，你可以两行代码就实现一个网络接口
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
如果你的ActionModel不需要输入，或者你不关心输出，那么就可以使用Empty作为他的类型
当然，只是写明ActionModel还不够，我们还要给他加上标注信息
```swift
@GET("my/book/list/path")
var myNetApi: ActionModel<Input, Output>
```
这样就完成了一个请求的描述。
实际上GET/POST，还支持另外几个参数:
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
	case key(_ keyName: String)   // 从获取的数据中，找出指定key的值作为输出
	case tuple              // 从获取的数据中，找到tuple中指定的key做为输出
}
```


更多资料
======
* [FAQ](Doc/FAQ.md)
* [如何进行配置](Doc/VegaProvider.md)
* [Interceptor使用示例（e.g. 如何进行加解密处理）](Doc/Interceptor.md)
* [如何解析自定义的返回数据格式](Doc/DataConverter.md)
