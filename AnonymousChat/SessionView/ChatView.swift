import SwiftUI

struct ChatView: View {
    
    let messages: [Message]
    
    let connection: Connection?
    
    @ObservedObject private var keyboard = KeyboardResponder()
    
    @State private var message: String = ""
    
    var body: some View {
        ZStack {
            Group {
                if messages.isEmpty {
                    EmptyView()
                } else {
                    ScrollView {
                        VStack {
                            ForEach(messages) { message in
                                MessageView(message: message)
                                    .padding()
                            }
                        }
                        Spacer(minLength: 96.0)
                    }
                }
            }
            .onTapGesture {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            VStack {
                Spacer()
                TextField("Send a message", text: self.$message, onCommit: {
                    guard !self.message.isEmpty else { return }
                    self.connection?.send(message: self.message)
                    self.message = ""
                })
                .padding()
                .background(Color.white)
                .cornerRadius(16.0)
                .shadow(color: Color.black.opacity(0.3), radius: 2.0, x: 0.0, y: 0.0)
            }
            .padding()
            .padding(.bottom, keyboard.currentHeight)
            .edgesIgnoringSafeArea(.bottom)
            .animation(.easeOut(duration: 0.16))
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    
    private static let messages = [
        Message(id: .init(), type: .sent, value: "Hello, World!"),
        Message(id: .init(), type: .received, value: "Hello, World!")
    ]
    
    static var previews: some View {
        Group {
            ChatView(messages: [], connection: nil)
            ChatView(messages: ChatView_Previews.messages, connection: nil)
        }
    }
}
