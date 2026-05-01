import ComposeApp
import SwiftUI

struct SettingsView: View {
    @State private var eventId = ""
    @State private var teamNumber = ""
    @State private var isSaved = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Event Configuration")) {
                    TextField("Event ID", text: $eventId)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .font(.system(.body, design: .monospaced))
                }

                Section(header: Text("Team")) {
                    TextField("Team Number", text: $teamNumber)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .keyboardType(.numberPad)
                        .font(.system(.body, design: .monospaced))
                }

                Section {
                    Button(action: saveSettings) {
                        HStack {
                            Image(
                                systemName: isSaved
                                    ? "checkmark.circle.fill"
                                    : "square.and.arrow.down"
                            )
                            Text(isSaved ? "Saved" : "Save Settings")
                        }
                    }
                    .foregroundStyle(isSaved ? .green : .blue)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            eventId = SettingsManager.shared.settings.getEventId()
            teamNumber = SettingsManager.shared.settings.getTeamNumber()
        }
    }

    private func saveSettings() {
        SettingsManager.shared.settings.setEventId(eventId: eventId)
        SettingsManager.shared.settings.setTeamNumber(teamNumber: teamNumber)
        isSaved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isSaved = false
        }
    }
}

#Preview {
    SettingsView()
}
