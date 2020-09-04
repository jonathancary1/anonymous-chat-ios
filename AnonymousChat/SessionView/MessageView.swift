import SwiftUI

struct MessageView: View {
    
    let message: Message
    
    var body: some View {
        switch message.type {
        case .sent:
            return AnyView(
                HStack {
                    Spacer()
                    Text(message.value)
                        .padding()
                        .background(Color.init(hue: 0.55, saturation: 0.25, brightness: 0.95))
                        .foregroundColor(Color.init(hue: 0.55, saturation: 0.55, brightness: 0.35))
                        .cornerRadius(16.0)
                }
            )
        case .received:
            return AnyView(
                HStack {
                    Text(message.value)
                        .padding()
                        .background(Color.init(hue: 0.55, saturation: 0.0, brightness: 0.95))
                        .foregroundColor(Color.init(hue: 0.55, saturation: 0.0, brightness: 0.35))
                        .cornerRadius(16.0)
                    Spacer()
                }
            )
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            MessageView(message: Message(id: .init(), type: .sent, value: "Hello, World!"))
            MessageView(message: Message(id: .init(), type: .received, value: "Hello, World!"))
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
