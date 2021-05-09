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

    // Builder
    public class Builder {
        private let identifier: VegaProviderIdentifier
        private let baseUrl: String?
        public init(_ identifier: VegaProviderIdentifier, baseUrl: String? = nil) {
            self.identifier = identifier
            self.baseUrl = baseUrl
        }
        
        private var httpClient: HTTPClient?
        private var converter: DataFactory?
        private var requestInterceptors: [RequestInterceptor] = []
        private var responseInterceptors: [ResponseInterceptor] = []
    }
}

public extension Vega.Builder {
    func setHTTPClient(_ httpClient: HTTPClient) -> Self {
        self.httpClient = httpClient
        return self
    }
    
    func setConverter(_ converter: DataConverter) -> Self {
        self.converter = .full(converter)
        return self
    }
    
    func setConverter(_ converter: CodableDataConverter) -> Self {
        self.converter = .codable(converter)
        return self
    }
    
    func addRequestInterceptor(_ interceptor: @escaping RequestInterceptor) -> Self {
        self.requestInterceptors.append(interceptor)
        return self
    }
    
    func addResponseInterceptor(_ interceptor: @escaping ResponseInterceptor) -> Self {
        self.responseInterceptors.append(interceptor)
        return self
    }
    
    func build() {
        let provider = DefaultVegaProvider(identifier: identifier, baseUrl: baseUrl, httpClient: httpClient ?? DefaultHTTPClient(), converter: converter ?? .full(DefaultJSONConverter()), requestInterceptors: requestInterceptors, responseInterceptors: responseInterceptors)
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
