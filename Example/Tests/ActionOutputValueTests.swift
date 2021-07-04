import XCTest
import Vega

class CustomResponse<T>: Decodable {
    var code: Int?
    @ActionOutputValue
    var data: T?
}

class ActionOutputValueTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEmptyOutput() {
        let text = """
        {
        }
        """
        let data = text.data(using: .utf8)!
        
        let anotherText = """
        {
            "data": {
                "hello": "world"
            }
        }
        """
        let anotherData = anotherText.data(using: .utf8)!
        
        do {
            // Empty应该不管什么类型，都可以返回Empty
            var response = try JSONDecoder().bind(actionOutput: .raw).decode(CustomResponse<Empty>.self, from: data)
            XCTAssertNotNil(response.data)
            
            // 尽管data有值，而且不是Empty，也应该返回Empty
            response = try JSONDecoder().bind(actionOutput: .raw).decode(CustomResponse<Empty>.self, from: anotherData)
            XCTAssertNotNil(response.data)
            
            let anotherResponse = try JSONDecoder().bind(actionOutput: .raw).decode(ActionOutputValue<Empty>.self, from: data)
            XCTAssertNotNil(anotherResponse.wrappedValue)
            
        } catch let error {
            XCTAssertFalse(true, error.localizedDescription)
        }
    }
    
    func testEmptyInput() {
        let emptyData = try! JSONEncoder().encode(Empty.empty)
        do {
            let dictResult = try ActionInput.dict.encodeInputToDict(Empty.empty)
            XCTAssertTrue(dictResult.isEmpty)
            
            let dataResult = try ActionInput.encodable.encodeInputToJSON(Empty.empty)
            XCTAssertEqual(emptyData, dataResult)
        } catch let error {
            XCTAssertFalse(true, error.localizedDescription)
        }
    }
    
    private struct Greeting: Decodable {
        struct Child: Decodable {
            var name: String?
            var age: Int?
        }
        
        var hello: String?
        var extra: String?
        var childs: [Child]?
    }
    
    func testOutput() {
        let text = """
        {
            "data": {
                "hello": "world",
                "byte": "Giga",
                "childs": [
                    {
                        "age": 10,
                        "name": "A",
                    },
                    {
                        "age": 100,
                        "name": "AA",
                    }
                ]
            }
        }
        """
        let data = text.data(using: .utf8)!
        do {
            let decodableResponse = try JSONDecoder().bind(actionOutput: .decodable).decode(CustomResponse<Greeting>.self, from: data)
            XCTAssertEqual(decodableResponse.data?.hello, "world")
            XCTAssertEqual(decodableResponse.data?.extra, nil)
            XCTAssertNotNil(decodableResponse.data?.childs)
            
            let children = decodableResponse.data!.childs!
            XCTAssertEqual(children.count, 2)
            XCTAssertEqual(children[0].age, 10)
            XCTAssertEqual(children[0].name, "A")
            XCTAssertEqual(children[1].age, 100)
            XCTAssertEqual(children[1].name, "AA")

            let dictResponse = try JSONDecoder().bind(actionOutput: .raw).decode(CustomResponse<[String: Any]>.self, from: data)
            XCTAssertEqual(dictResponse.data!["hello"] as! String, "world")
            XCTAssertEqual(dictResponse.data!["byte"] as! String, "Giga")
            
            let keyResponse = try JSONDecoder().bind(actionOutput: .key("hello")).decode(CustomResponse<String>.self, from: data)
            XCTAssertEqual(keyResponse.data, "world")
            
            let tupleResponse = try JSONDecoder().bind(actionOutput: .tuple).decode(CustomResponse<(hello: String?, byte: String)>.self, from: data)
            XCTAssertEqual(tupleResponse.data!.hello, "world")
            XCTAssertEqual(tupleResponse.data!.byte, "Giga")
        } catch let error {
            XCTAssertFalse(true, error.localizedDescription)
        }
    }
    
    func testDictRawOutput() {
        let dictText = """
        {
            "data": {
                "hello": "world",
                "byte": "Giga",
                "childs": [
                    {
                        "age": 10,
                        "name": "A",
                    },
                    {
                        "age": 100,
                        "name": "AA",
                    }
                ]
            }
        }
        """
        let data = dictText.data(using: .utf8)!
        do {
            let dictResponse = try JSONDecoder().bind(actionOutput: .raw).decode(CustomResponse<[String: Any]>.self, from: data)
            let result: [String: Any] = [
                "hello": "world",
                "byte": "Giga",
                "childs": [
                    [
                        "age": 10,
                        "name": "A",
                    ],
                    [
                        "age": 100,
                        "name": "AA",
                    ]
                ]
            ]
            
            XCTAssertEqual(dictResponse.data! as NSDictionary, result as NSDictionary)
        } catch let error {
            XCTAssertFalse(true, error.localizedDescription)
        }
    }
    
    func testArrayRawOutput() {
        let arrayText = """
        {
            "data": [
                10, 8, 8,
                [8, 8],
                {
                    "hello": "world"
                },
                [
                    {
                        "age": 10,
                        "name": "A",
                        "idList": [1, 2, 3]
                    },
                    {
                        "age": 100,
                        "name": "AA",
                        "idList": [11, 22, 33]
                    },
                ]
            ]
        }
        """
        let data = arrayText.data(using: .utf8)!
        do {
            let arrayResponse = try JSONDecoder().bind(actionOutput: .raw).decode(CustomResponse<[Any]>.self, from: data)
            let result: [Any] = [
                10, 8, 8,
                [8, 8],
                ["hello": "world"],
                [
                    [
                        "age": 10,
                        "name": "A",
                        "idList": [1, 2, 3]
                    ],
                    [
                        "age": 100,
                        "name": "AA",
                        "idList": [11, 22, 33]
                    ]
                ]
            ]
            XCTAssertEqual(result as NSArray, arrayResponse.data! as NSArray)
        } catch let error {
            XCTAssertFalse(true, error.localizedDescription)
        }
    }
    
    
    func testStringRawOuput() {
        let text = """
        {
            "data": "hahaha"
        }
        """
        let data = text.data(using: .utf8)!
        do {
            let response = try JSONDecoder().bind(actionOutput: .raw).decode(CustomResponse<String>.self, from: data)
            XCTAssertEqual(response.data, "hahaha")
        } catch let error {
            XCTAssertFalse(true, error.localizedDescription)
        }
    }
}
