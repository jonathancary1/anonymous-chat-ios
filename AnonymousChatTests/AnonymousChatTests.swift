import XCTest
@testable import AnonymousChat

class AnonymousChatTests: XCTestCase {
    
    func encode(string: String) -> Data {
        let body = string.data(using: .utf8)!
        var header = UInt16(body.count).bigEndian
        var data = Data(bytes: &header, count: 2)
        data.append(body)
        return data
    }

    func testConnectionEndEncoding() throws {
        let message: Frame.Message = .connection(.end)
        let string = "{\"message\":{\"Connection\":\"End\"}}"
        XCTAssertEqual(try FrameEncoder().encode(message), encode(string: string))
    }
    
    func testSessionEndEncoding() throws {
        let message: Frame.Message = .session(.end)
        let string = "{\"message\":{\"Session\":\"End\"}}"
        XCTAssertEqual(try FrameEncoder().encode(message), encode(string: string))
    }
    
    func testSessionRequestEncoding() throws {
        let message: Frame.Message = .session(.request)
        let string = "{\"message\":{\"Session\":\"Request\"}}"
        XCTAssertEqual(try FrameEncoder().encode(message), encode(string: string))
    }
    
    func testSessionSuccessEncoding() throws {
        let message: Frame.Message = .session(.success)
        let string = "{\"message\":{\"Session\":\"Success\"}}"
        XCTAssertEqual(try FrameEncoder().encode(message), encode(string: string))
    }
    
    func testSessionValueEncoding() throws {
        let message: Frame.Message = .session(.value("👋, \"🌎\"!"))
        let string = "{\"message\":{\"Session\":{\"Value\":\"👋, \\\"🌎\\\"!\"}}}"
        XCTAssertEqual(try FrameEncoder().encode(message), encode(string: string))
    }
    
    func testConnectionEndDecoding() throws {
        let message: Frame.Message = .connection(.end)
        let string = "{\"message\":{\"Connection\":\"End\"}}"
        let decoder = FrameDecoder()
        decoder.append(encode(string: string))
        XCTAssertEqual(try decoder.decode(), message)
    }
    
    func testSessionEndDecoding() throws {
        let message: Frame.Message = .session(.end)
        let string = "{\"message\":{\"Session\":\"End\"}}"
        let decoder = FrameDecoder()
        decoder.append(encode(string: string))
        XCTAssertEqual(try decoder.decode(), message)
    }
    
    func testSessionRequestDecoding() throws {
        let message: Frame.Message = .session(.request)
        let string = "{\"message\":{\"Session\":\"Request\"}}"
        let decoder = FrameDecoder()
        decoder.append(encode(string: string))
        XCTAssertEqual(try decoder.decode(), message)
    }
    
    func testSessionSuccessDecoding() throws {
        let message: Frame.Message = .session(.success)
        let string = "{\"message\":{\"Session\":\"Success\"}}"
        let decoder = FrameDecoder()
        decoder.append(encode(string: string))
        XCTAssertEqual(try decoder.decode(), message)
    }
    
    func testSessionValueDecoding() throws {
        let message: Frame.Message = .session(.value("👋, \"🌎\"!"))
        let string = "{\"message\":{\"Session\":{\"Value\":\"👋, \\\"🌎\\\"!\"}}}"
        let decoder = FrameDecoder()
        decoder.append(encode(string: string))
        XCTAssertEqual(try decoder.decode(), message)
    }
    
    func testPartialDecoding() throws {
        let message: Frame.Message = .session(.value("👋, \"🌎\"!"))
        let string = "{\"message\":{\"Session\":{\"Value\":\"👋, \\\"🌎\\\"!\"}}}"
        let data = encode(string: string)
        let decoder = FrameDecoder()
        decoder.append(data[...1])
        XCTAssertEqual(try decoder.decode(), nil)
        decoder.append(data[2...7])
        XCTAssertEqual(try decoder.decode(), nil)
        decoder.append(data[8...])
        XCTAssertEqual(try decoder.decode(), message)
    }
}
