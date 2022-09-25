import BuildsFeature
import SwiftUI

public struct ConnectionState: View {
    public var state: String
    public var isRunningJob: Bool

    public init(
        state: String,
        isRunningJob: Bool
    ) {
        self.state = state
        self.isRunningJob = isRunningJob
    }

    public var body: some View {
        Group {
            if isRunningJob {
                BuildState(state: "running")
            } else {
                Circle()
                    .size(width: 13, height: 13)
                    .frame(width: 13, height: 13)
                    .foregroundColor(Colors.color(for: state))
            }
        }
        .accessibility(label: Text(stateTitle))
    }

    private var stateTitle: String {
        switch state.lowercased() {
        case "connected":
            return "Connected"
        case "disconnected":
            return "Disconnected"
        case "stopped":
            return "Stopped"
        case "stopping":
            return "Stopping…"
        case "never_connected":
            return "Never Connected"
        case "lost":
            return "Lost Connection"
        default:
            return ""
        }
    }

    private enum Colors {
        static let connected = Color(red: 0.07843137255, green: 0.8, blue: 0.5019607843)
        static let disconnected = Color(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667)
        static let stopping = Color(red: 1, green: 0.7294117647, blue: 0.06666666667)

        static func color(for state: String) -> Color {
            switch state.lowercased() {
            case "connected":
                return connected
            case "disconnected", "stopped", "lost", "never_connected":
                return disconnected
            case "stopping":
                return stopping
            default:
                return disconnected
            }
        }
    }
}

struct ConnectionState_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ConnectionState(state: "connected", isRunningJob: false)
            ConnectionState(state: "connected", isRunningJob: true)
            ConnectionState(state: "disconnected", isRunningJob: false)
            ConnectionState(state: "disconnected", isRunningJob: true)
            ConnectionState(state: "stopping", isRunningJob: false)
            ConnectionState(state: "stopping", isRunningJob: true)
        }
    }
}
