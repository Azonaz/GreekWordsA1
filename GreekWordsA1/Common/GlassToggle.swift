import SwiftUI

struct GlassToggle: View {
    @Binding var isOn: Bool
    var label: String
    var systemImage: String = "eyes"

    var body: some View {
        Toggle(isOn: $isOn) {
            Label {
                Text(label)
                    .font(.body)
                    .foregroundColor(.primary)
            } icon: {
                Image(systemName: systemImage)
                    .font(.body)
                    .imageScale(.large)
                    .foregroundColor(.primary)
            }
        }
        .toggleStyle(GlassToggleStyle())
    }
}

struct GlassToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            ZStack {
                GlassToggleBackground(isOn: configuration.isOn)
                GlassToggleKnob(isOn: configuration.isOn)
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.25)) {
                    configuration.isOn.toggle()
                }
            }
        }
        .padding(.vertical, 8)
    }
}

private struct GlassToggleBackground: View {
    var isOn: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    colors: isOn
                        ? [
                            Color(red: 162/255, green: 24/255, blue: 29/255, opacity: 0.4),
                            Color(red: 162/255, green: 24/255, blue: 29/255, opacity: 0.25),
                            Color(white: 0.9, opacity: 0.3)
                          ]
                        : [
                            Color(white: 0.25, opacity: 0.25),
                            Color(white: 0.15, opacity: 0.2)
                          ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
            .frame(width: 54, height: 30)
            .shadow(
                color: isOn
                    ? Color(red: 162/255, green: 24/255, blue: 29/255, opacity: 0.45)
                    : .black.opacity(0.3),
                radius: isOn ? 6 : 3,
                x: 0,
                y: isOn ? 0 : 1
            )
    }
}

private struct GlassToggleKnob: View {
    var isOn: Bool

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.95),
                        Color(white: 0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
            )
            .frame(width: 26, height: 26)
            .offset(x: isOn ? 11 : -11)
            .shadow(color: .black.opacity(0.25), radius: 1, x: 0, y: 1)
            .animation(.easeInOut(duration: 0.25), value: isOn)
    }
}
