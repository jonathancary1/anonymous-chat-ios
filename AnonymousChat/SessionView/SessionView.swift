import SwiftUI

struct SessionView: View {
    
    let connection: Connection?
    
    @EnvironmentObject private var state: ConnectionState
    
    var body: some View {
        switch state.value {
        case .session(let messages):
            return AnyView(ChatView(messages: messages, connection: connection))
        default:
            return AnyView(Text("Waiting for someone..."))
        }
    }
}

struct SessionView_Previews: PreviewProvider {
    
    private static let messages: [Message] = [
        Message(id: .init(), type: .sent, value: "Hello, World!"),
        Message(id: .init(), type: .received, value: "Hello, World!")
    ]
    
    static var previews: some View {
        Group {
            SessionView(connection: nil)
                .environmentObject(ConnectionState(value: .waiting))
            SessionView(connection: nil)
                .environmentObject(ConnectionState(value: .session(SessionView_Previews.messages)))
        }
    }
}
