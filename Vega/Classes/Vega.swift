//
//  NetAnnotation.swift
//  TestN
//
//  Created by kensou on 2021/4/16.
//

import Foundation

public struct Vega {
    private static var providerList: [VegaProvider] = []
        
    static func regist(_ provider: VegaProvider) {
        providerList.append(provider)
    }
}

public extension Vega {
    static func builder(_ identifier: VegaProviderIdentifier = "") -> VegaBuilder {
        return VegaBuilder(identifier)
    }
}

// Builder
public class VegaBuilder {
    private let identifier: VegaProviderIdentifier
    public init(_ identifier: VegaProviderIdentifier = "") {
        self.identifier = identifier
    }

    private var baseUrl: String?
    private var httpClient: HTTPClient?
    private var converter: DataConverter?
    private var interceptors: [ActionInterceptor] = []
}

public extension VegaBuilder {
    func setBaseURL(_ baseUrl: String) -> Self {
        self.baseUrl = baseUrl
        return self
    }
    func setHTTPClient(_ httpClient: HTTPClient) -> Self {
        self.httpClient = httpClient
        return self
    }
    
    func setConverter(_ converter: DataConverter) -> Self {
        self.converter = converter
        return self
    }
    
    func addInterceptor(_ interceptor: ActionInterceptor) -> Self {
        self.interceptors.append(interceptor)
        return self
    }
    
    func build() {
        let provider = DefaultVegaProvider(identifier: identifier, baseUrl: baseUrl, httpClient: httpClient ?? DefaultHTTPClient(), converter: converter ?? DefaultJSONConverter(), interceptors: interceptors)
        Vega.regist(provider)
    }
}

internal extension Vega {
    static func getProvider(by identifier: VegaProviderIdentifier?) -> VegaProvider {
        if let id = identifier {
            guard let provider = providerList.first(where: {$0.identifier == id}) else {
                fatalError("can not find provider built for \(id)")
            }
            return provider
        } else {
            guard let provider = providerList.first else {
                fatalError("there is no provider built!")
            }
            return provider
        }
    }    
}

internal extension Optional where Wrapped == VegaProviderIdentifier {
    var provider: VegaProvider {
        return Vega.getProvider(by: self)
    }
}
