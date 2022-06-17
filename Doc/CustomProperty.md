CustomProperty
====
ActionModel在使用时，可以增加自定义的属性。不同的Interceptor/HTTPClient/DataConverter在工作的时候，可以从入参获得ActionModel对象，并根据它所包含的各种属性进行相应的处理。
Vega中如何使用自定义属性呢？

我们来看看几个常见的自定义属性使用场景。

不同的API使用不同的baseUrl
-------------------
一个VegaProvider只能对应一个baseUrl，而我们业务中长长需要用到多个baseUrl，例如：主业务、支付业务、好友业务、文件处理业务等都是使用不同的baseUrl，那么如何简便的定义这些API呢？
参考方案如下：

```
extension ActionProperty {
	static var payAPI: ActionProperty {
		return .baseUrl(Environment.payUrl)
	}
}

struct NetAPI {
	@POST("/user/login")
	static var login: <LoginRequest, UserProfile>

	// 支付相关API，标记.payAPI, 使用的支付的baseUrl
	@POST("/vip/subscription", .payAPI)
	static var subscribe: <SubscribeRequest, SubscribeResult>
}

```

更复杂的自定义属性
----------
上面提到的自定义属性，只是利用现有几个属性，进行包装；然而我们可能实际上需要一些更复杂的自定义数据。我们现在来看看如何实现带有自定义数据的属性。
ActionProperty中提供了一个.custom(key, value)的属性，我们所有的自定义数据的属性都是通过它来实现的。

现在假设我们有一个加密的Interceptor（也可能是DataConverter），在接口请求发出前，要对请求数据进行加密。可是有些接口是要求不加密的，那么Interceptor需要从对应ActionModel中获得是否加密的设置。

我们来看一下最基础，但是也最复杂的做法。

方法一：
直接使用
```.custom("useEncrypt", true)```
来使用，然后用
```
let shouldEncrypt = actionModel.customProperty(forKey: "useEncrypt") as? Bool
```
进行获取和判断。如果需要动态修改Model的该属性值，那么就需要
```
actionModel.updateProperty(forKey: "useEncrypt", true)
```
但这个方法使用起来略微繁琐。
第一，定义的时候，.custom("useEncrypt")的useEncrypt这个字符串需要被频繁使用到，即使定义了常量代替，依然写起来比较麻烦。
第二，updateProperty和customProperty的调用较为繁琐。
第三，类型不安全，调用者需要事先知道每个自定义属性对应的数据的类型，如果写错了，或者程序重构过程中类型变化了，编译器也不会给出警告

可以参考第二种方法，方法二稍微需要自定写几个函数

方法二：
```
// 定义一个类型，统一存放自定义属性。该类型需要实现ActionCustomPropertyOwner协议
struct ProjectCustomProperties: ActionCustomPropertyOwner {
    static let shared: HNVegaCustomProperties = .init()
    
    // 是否加密，布尔型
    let shouldEncrypt: ActionCustomProperty<Bool> = .init("useEncrypt")
    // 加密算法，枚举
    let encryptAlgorithm: ActionCustomProperty<EncryptAlgorithm> = .init("encryptAlgorithm")
}

// 注意，这个要dynamicMemberLookup
@dynamicMemberLookup
struct ProjectActionModelExtension: ActionModelCustomPropertyExtension {
    typealias PropertyOwner = ProjectCustomProperties
    
    let model: ActionCustomPropertyOperator
    
    init(model: ActionCustomPropertyOperator) {
        self.model = model
    }
}

extension ActionProperty {
    static var extend: ProjectCustomProperties {
        return .shared
    }
}

extension ActionModel {
    var extend: ProjectActionModelExtension {
        return .init(model: self)
    }
}
```

自定义的部分比方法一多了点，但是使用和可维护性都比方法一好很多。
使用的时候可以这样
```
// 声明接口时的使用
@POST("/path", .extend.shouldEncrypt(true))
var queryName: ActionModel<Empty, String>

// 在model上动态设置时的使用
actionModel.extend.shouldEncrypt = true

// 获取数据时的使用
if let shouldEncrypt = actionModel.extend.shouldEncrypt {
    // perform encrypt code
}
```
使用的时候，因为用了KeyPath和dynamicMemberLookup，所以不需要手动敲那些字符串，编译器能对这些自定义属性进行提示和检测。
而且在赋值和取值的时候，编译器也是会进行类型判断检测的，即使后来程序重构修改了这个键值对应的类型，编译器也会马上报错，避免发生未知的问题。

使用方法二，后续增加新的自定义类型，只要在ProjectCustomProperties增加一个变量即可，维护方便。
如果需要一个没有参数的自定义类型，可以直接定义成ActionCustomProperty(Void)即可。
