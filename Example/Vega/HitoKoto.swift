//
//  HitoKoto.swift
//  Vega_Example
//
//  Created by kensou on 2021/6/19.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

struct HitoKoto: Codable {
    var id: Int
    var hitokoto: String
    var from_who: String?
}
