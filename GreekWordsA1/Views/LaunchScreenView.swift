import SwiftUI

struct LaunchScreenView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    var sizeLogo: CGFloat {
        sizeClass == .regular ? 250 : 150
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.05)
                .ignoresSafeArea()

            VStack {
                Image(.launchLogo)
                    .resizable()
                    .frame(width: sizeLogo, height: sizeLogo)
            }
        }
    }
}
