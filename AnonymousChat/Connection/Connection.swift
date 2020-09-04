import CocoaAsyncSocket
import Combine

class ConnectionState: ObservableObject {
    
    enum Value {
        case disconnected(Error?)
        case connecting
        case idle
        case waiting
        case session([Message])
    }
    
    @Published fileprivate(set) var value: Value
    
    init(value: Value) {
        self.value = value
    }
}

struct Message: Identifiable {
    let id: UUID
    let type: MessageType
    let value: String
}

enum MessageType {
    case sent
    case received
}

class Connection: TcpSocketConnectionDelegate {
    
    private static let host: String = "ec2-3-17-65-117.us-east-2.compute.amazonaws.com"
    
    private static let port: UInt16 = 3000
    
    let state: ConnectionState = .init(value: .disconnected(nil))
    
    private lazy var connection: TcpSocketConnection = .init(delegate: self)
    
    func connect() {
        self.state.value = .connecting
        self.connection.connect(to: Connection.host, port: Connection.port)
    }
    
    func disconnect() {
        self.state.value = .disconnected(nil)
        self.connection.disconnect()
    }
    
    func request() {
        self.state.value = .waiting
        self.connection.send(.session(.request))
    }
    
    func send(message: String) {
        if case .session(var messages) = self.state.value {
            messages.append(Message(id: .init(), type: .sent, value: message))
            self.state.value = .session(messages)
            self.connection.send(.session(.value(message)))
        }
    }
    
    func leave() {
        self.state.value = .idle
        self.connection.send(.session(.end))
    }
    
    func connection(_: TcpSocketConnection, connected result: Result<(), Error>) {
        switch result {
        case .success(()):
            self.state.value = .idle
        case .failure(let error):
            self.state.value = .disconnected(error)
        }
    }
    
    func connection(_: TcpSocketConnection, disconnected result: Result<(), Error>) {
        switch result {
        case .success(()):
            self.state.value = .disconnected(nil)
        case .failure(let error):
            self.state.value = .disconnected(error)
        }
    }
    
    func connection(_: TcpSocketConnection, received result: Result<Frame.Message, Error>) {
        switch result {
        case .success(let message):
            switch message {
            case .connection(.end):
                self.state.value = .disconnected(nil)
                self.connection.disconnect()
            case .session(.end):
                if case .session(_) = self.state.value {
                    self.state.value = .idle
                }
            case .session(.request):
                break
            case .session(.success):
                if case .waiting = self.state.value {
                    self.state.value = .session([])
                }
            case .session(.value(let value)):
                if case .session(var messages) = self.state.value {
                    messages.append(Message(id: .init(), type: .received, value: value))
                    self.state.value = .session(messages)
                }
            }
        case .failure(let error):
            self.state.value = .disconnected(error)
            self.connection.disconnect()
        }
    }
}

protocol TcpSocketConnectionDelegate: class {
    func connection(_: TcpSocketConnection, connected: Result<(), Error>)
    func connection(_: TcpSocketConnection, disconnected: Result<(), Error>)
    func connection(_: TcpSocketConnection, received: Result<Frame.Message, Error>)
}

// TcpSocketConnection wraps a GCDAsyncSocket, framing both requests and responses.
class TcpSocketConnection: NSObject {

    weak var delegate: TcpSocketConnectionDelegate?

    private lazy var socket: GCDAsyncSocket = {
        GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
    }()

    private let encoder: FrameEncoder = .init()
    private let decoder: FrameDecoder = .init()

    init(delegate: TcpSocketConnectionDelegate?) {
        self.delegate = delegate
        super.init()
    }
    
    func connect(to host: String, port: UInt16) {
        do {
            try socket.connect(toHost: host, onPort: port, withTimeout: 8.0)
        } catch let error {
            delegate?.connection(self, connected: .failure(error))
        }
    }
    
    func disconnect() {
        self.socket.disconnect()
    }
    
    func send(_ message: Frame.Message) {
        if let data = try? encoder.encode(message) {
            socket.write(data, withTimeout: -1.0, tag: 0)
        }
    }
}

extension TcpSocketConnection: GCDAsyncSocketDelegate {
    
    func socket(_ socket: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        delegate?.connection(self, connected: .success(()))
        socket.readData(withTimeout: -1.0, tag: 0)
    }

    func socket(_ socket: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        do {
            decoder.append(data)
            while let message = try decoder.decode() {
                delegate?.connection(self, received: .success(message))
            }
            socket.readData(withTimeout: -1.0, tag: 0)
        } catch let error {
            delegate?.connection(self, received: .failure(error))
        }
    }
    
    func socketDidDisconnect(_ socket: GCDAsyncSocket, withError error: Error?) {
        if let error = error {
            delegate?.connection(self, disconnected: .failure(error))
        } else {
            delegate?.connection(self, disconnected: .success(()))
        }
    }
}
