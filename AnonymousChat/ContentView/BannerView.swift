import SwiftUI

struct BannerView: View {
    
    @State private var animation: Bool = false
    
    var body: some View {
        Image("Banner")
            .resizable()
            .scaledToFit()
            .shadow(color: Color.black.opacity(0.3), radius: 3.0, x: 0.0, y: 0.0)
            .offset(y: animation ? -6.0 : 6.0)
            .animation(Animation.easeInOut(duration: 1.6).repeatForever(), value: self.animation)
            .onAppear(perform: { self.animation.toggle() })
    }
}

struct BannerView_Previews: PreviewProvider {
    
    static var previews: some View {
        BannerView().previewLayout(.fixed(width: 300, height: 300))
    }
}
