//
//  NetAPI.swift
//  Vega_Example
//
//  Created by kensou on 2021/6/19.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Vega

struct GitHubAPI {
    @GET("https://api.github.com/orgs/apple/repos")
    static var appleRepositories: ActionModel<Empty, [GHRepository]>    
}


struct HitokotoAPI {
    @GET("https://v1.hitokoto.cn", input: .key("c"))
    static var hitokoto: ActionModel<String, HitoKoto>
}

struct FakeHitoKotoAPI {
    @POST("happy/to/path", .timeout(10.0), .provider("FakeOne"), input: .dict)
    static var fakeHitoKoto: ActionModel<[String: String], HitoKoto>
}
