import Foundation

// An encoded Frame consists of a header and a body.
// The header is a big endian encoded uint16 of the body length.
// The body is a utf-8 encoded string of JSON.
struct Frame: Codable, Equatable {
    
    let message: Message
    
    enum Message: Equatable {
        case connection(Connection)
        case session(Session)
    }

    enum Connection: Equatable {
        case end
    }

    enum Session: Equatable {
        case end
        case request
        case success
        case value(String)
    }
}

class FrameEncoder {
    
    enum EncodingError: Error {
        case invalidValue
    }
    
    func encode(_ message: Frame.Message) throws -> Data {
        let body = try JSONEncoder().encode(Frame(message: message))
        guard body.count <= UInt16.max else { throw EncodingError.invalidValue }
        var header = UInt16(body.count).bigEndian
        var bytes = Data(bytes: &header, count: 2)
        bytes.append(body)
        return bytes
    }
}

class FrameDecoder {
    
    private enum State { case header, body(UInt16) }
    
    private var state: State = .header
    
    private var buffer: Data = .init()
    
    func append(_ data: Data) {
        buffer.append(data)
    }
    
    func decode() throws -> Frame.Message? {
        if case .header = self.state {
            if self.buffer.count >= 2 {
                let header = self.buffer.prefix(2)
                let count = UInt16(header[header.startIndex]) << 8 | UInt16(header[header.startIndex + 1])
                self.buffer.removeFirst(2)
                self.state = .body(count)
            }
        }
        
        if case .body(let count) = self.state {
            if self.buffer.count >= count {
                let body = self.buffer.prefix(Int(count))
                let frame = try JSONDecoder().decode(Frame.self, from: body)
                self.buffer.removeFirst(Int(count))
                self.state = .header
                return frame.message
            }
        }
        
        return nil
    }
}

extension Frame.Message: Codable {

    private enum CodingKeys: String, CodingKey {
        case connection = "Connection"
        case session = "Session"
    }
    
    enum DecodingError: Error {
        case invalidValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.allKeys.count == 1 {
            if let connection = try? container.decode(Frame.Connection.self, forKey: .connection) {
                self = .connection(connection)
            } else if let session = try? container.decode(Frame.Session.self, forKey: .session) {
                self = .session(session)
            } else {
                throw DecodingError.invalidValue
            }
        } else {
            throw DecodingError.invalidValue
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .connection(let connection):
            try container.encode(connection, forKey: .connection)
        case .session(let session):
            try container.encode(session, forKey: .session)
        }
    }
}

extension Frame.Connection: Codable {

    private enum Values: String, Codable {
        case end = "End"
    }
    
    enum DecodingError: Error {
        case invalidValue
    }

    init(from decoder: Decoder) throws {
        if let value = try? decoder.singleValueContainer().decode(Values.self) {
            switch value {
            case .end:
                self = .end
            }
        } else {
            throw DecodingError.invalidValue
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .end:
            try container.encode(Values.end)
        }
    }
}

extension Frame.Session: Codable {

    private enum CodingKeys: String, CodingKey {
        case value = "Value"
    }
    
    private enum Values: String, Codable {
        case end = "End"
        case request = "Request"
        case success = "Success"
    }
    
    enum DecodingError: Error {
        case invalidValue
    }

    init(from decoder: Decoder) throws {
        if let value = try? decoder.singleValueContainer().decode(Values.self) {
            switch value {
            case .end:
                self = .end
            case .request:
                self = .request
                return
            case .success:
                self = .success
            }
        } else if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            if container.allKeys.count == 1 {
                if let value = try? container.decode(String.self, forKey: .value) {
                    self = .value(value)
                } else {
                    throw DecodingError.invalidValue
                }
            } else {
                throw DecodingError.invalidValue
            }
        } else {
            throw DecodingError.invalidValue
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .end:
            var container = encoder.singleValueContainer()
            try container.encode(Values.end)
        case .request:
            var container = encoder.singleValueContainer()
            try container.encode(Values.request)
        case .success:
            var container = encoder.singleValueContainer()
            try container.encode(Values.success)
        case .value(let value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .value)
        }
    }
}
