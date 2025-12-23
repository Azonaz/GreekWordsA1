import SwiftUI

struct GlassSegmentedControl<Value: Hashable>: View {
    let items: [Value]
    let label: (Value) -> String
    @Binding var selection: Value

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selection = item
                    }
                } label: {
                    Text(label(item))
                        .font(.body)
                        .frame(maxWidth: .infinity, minHeight: 34)
                        .background(
                            ZStack {
                                if selection == item {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                                        )
                                        .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
                                }
                            }
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .opacity(0.8)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }
}
