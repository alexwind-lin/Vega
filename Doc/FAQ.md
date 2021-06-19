FAQ
====
* 请求时候崩溃了，日志/崩溃栈卡在
```swift
fatalError("there is no provider built!")
```
使用Vega的请求前，请记得先进行设置，例如：
```
Vega.builder().build()
```
具体的设置方式，请参考[这里](VegaProvider.md)
