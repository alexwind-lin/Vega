//
//  RequestInputType.swift
//  TestN
//
//  Created by kensou on 2021/4/16.
//

import SweetSugar

public enum ActionInput {
    case encodable
    case dict
    case value(_ key: String)
    case tuple
}
