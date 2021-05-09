//
//  DataFactory.swift
//  TestN
//
//  Created by kensou on 2021/5/7.
//

enum DataFactory {
    case codable(_ converter: CodableDataConverter)
    case full(_ converter: DataConverter)
}
