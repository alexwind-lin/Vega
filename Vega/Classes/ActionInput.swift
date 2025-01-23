//
//  RequestInputType.swift
//  TestN
//
//  Created by alex on 2021/4/16.
//

public enum ActionInput {
    case encodable          // 输入类型是Encodable类型
    case dict               // 输入类型是Dict
    case key(_ keyName: String) //输入的数据以[key: value]方式上传
    case tuple              //输入的数据以[tupleKey1: tupleValue1, tupleKey2: tupleValue2, ...]方式上传
}
