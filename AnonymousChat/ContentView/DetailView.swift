import SwiftUI

struct DetailView: View {
    
    let connection: Connection?
    
    @EnvironmentObject private var state: ConnectionState
    
    var body: some View {
        switch self.state.value {
        case .disconnected(nil):
            return AnyView(
                Button(action: {
                    self.connection?.connect()
                }) {
                    Text("Connect")
                }
            )
        case .disconnected(.some(let error)):
            return AnyView(
                VStack {
                    Button(action: {
                        self.connection?.connect()
                    }) {
                        Text("Try Again")
                    }
                    Text("Something went wrong")
                        .padding()
                    Text(error.localizedDescription)
                        .fontWeight(.ultraLight)
                        .multilineTextAlignment(.center)
                }
            )
        case .connecting:
            return AnyView(Text("Connecting..."))
        case .idle:
            return AnyView(
                Button(action: {
                    self.connection?.request()
                }) {
                    Text("Start Chatting")
                }
            )
        case .waiting:
            return AnyView(Text("Loading..."))
        case .session(_):
            return AnyView(Text("Loading..."))
        }
    }
}

struct DetailView_Previews: PreviewProvider {

    private struct PreviewError: Error {}
    
    static var previews: some View {
        Group {
            DetailView(connection: nil)
                .environmentObject(ConnectionState(value: .disconnected(nil)))
            DetailView(connection: nil)
                .environmentObject(ConnectionState(value: .disconnected(PreviewError())))
            DetailView(connection: nil)
                .environmentObject(ConnectionState(value: .connecting))
            DetailView(connection: nil)
                .environmentObject(ConnectionState(value: .idle))
            DetailView(connection: nil)
                .environmentObject(ConnectionState(value: .waiting))
            DetailView(connection: nil)
                .environmentObject(ConnectionState(value: .session([])))
        }
        .previewLayout(.fixed(width: 300, height: 300))
    }
}
