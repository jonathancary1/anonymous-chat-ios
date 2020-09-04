import Combine
import SwiftUI

struct ContentView: View {
    
    let connection: Connection?
    
    @EnvironmentObject private var state: ConnectionState
    
    @State private var isPresented: Bool = false
    
    var body: some View {
        VStack {
            BannerView()
                .frame(maxHeight: .infinity)
            DetailView(connection: self.connection)
                .frame(maxHeight: .infinity)
        }
        .padding(64.0)
        .sheet(isPresented: self.$isPresented, onDismiss: {
            switch self.state.value {
            case .waiting, .session(_):
                self.connection?.leave()
            default:
                break
            }
        }) {
            SessionView(connection: self.connection)
                .environmentObject(self.state)
        }
        .onReceive(self.state.objectWillChange) {
            DispatchQueue.main.async {
                switch self.state.value {
                case .waiting, .session(_):
                    self.isPresented = true
                default:
                    self.isPresented = false
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {

    private struct PreviewError: Error {}
    
    static var previews: some View {
        Group {
            ContentView(connection: nil)
                .environmentObject(ConnectionState(value: .disconnected(nil)))
            ContentView(connection: nil)
                .environmentObject(ConnectionState(value: .disconnected(PreviewError())))
            ContentView(connection: nil)
                .environmentObject(ConnectionState(value: .connecting))
            ContentView(connection: nil)
                .environmentObject(ConnectionState(value: .idle))
            ContentView(connection: nil)
                .environmentObject(ConnectionState(value: .waiting))
            ContentView(connection: nil)
                .environmentObject(ConnectionState(value: .session([])))
        }
    }
}
