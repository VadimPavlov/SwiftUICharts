import SwiftUI

struct DelayTouches: ViewModifier {
    let delay: TimeInterval
    
    @State var disabled = false
    @State var touchDate: Date?
    
    func body(content: Content) -> some View {
        Button(action: {}) { content }
            .buttonStyle(DelayTouchesButtonStyle(delay: delay, disabled: $disabled, touchDate: $touchDate))
            .disabled(disabled)
    }
}

extension View {
    func delayTouches(delay: TimeInterval = 0) -> some View {
        modifier(DelayTouches(delay: delay))
    }
}

struct DelayTouchesButtonStyle: ButtonStyle {
    let delay: TimeInterval
    
    @Binding var disabled: Bool
    @Binding var touchDate: Date?
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.onChange(of: configuration.isPressed, perform: handle)
    }
    
    func handle(isPressed: Bool) {
        if isPressed {
            let date = Date()
            touchDate = date
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if date == touchDate {
                    disabled = true
                    DispatchQueue.main.async {
                        disabled = false
                    }
                }
            }
        } else {
            touchDate = nil
            disabled = false
        }
    }
}
