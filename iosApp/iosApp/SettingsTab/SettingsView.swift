import ComposeApp
import SwiftUI

struct SettingsView: View {
    @State private var eventId = ""
    @State private var teamNumber = ""
    @State private var isSaved = false
    @State private var hasChanges = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case eventId, teamNumber
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    generalSection
                    pitSection
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .contentShape(Rectangle())
            .onTapGesture { focusedField = nil }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
        }
        .onAppear(perform: loadSettings)
        .onChange(of: eventId) { _ in hasChanges = true }
        .onChange(of: teamNumber) { _ in hasChanges = true }
    }

    // MARK: - Sections

    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(title: "General", icon: "gearshape")
            SettingsCard {
                SettingsRow(
                    label: "Event ID",
                    placeholder: "2026daly",
                    text: $eventId
                )
                .focused($focusedField, equals: .eventId)

                Divider().padding(.leading, 14)

                SettingsRow(
                    label: "Team Number",
                    placeholder: "3990",
                    text: $teamNumber
                )
                .focused($focusedField, equals: .teamNumber)
                .keyboardType(.numberPad)
            }
            Text(
                "Event ID determines which schedule is loaded. Team number doesn't do anything yet."
            )
            .font(.footnote)
            .foregroundStyle(.tertiary)
            .padding(.horizontal, 4)
        }
    }

    private var pitSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(title: "Pit", icon: "hammer")
            SettingsCard {
                Text("Nothing here yet")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            saveButton
        }
        ToolbarItem(placement: .keyboard) {
            HStack {
                Spacer()
                Button("Done") { focusedField = nil }
                    .fontWeight(.semibold)
            }
        }
    }

    private var saveButton: some View {
        Button(action: save) {
            saveIcon
        }
        .tint(isSaved ? .green : .accentColor)
        .disabled(!hasChanges && !isSaved)
    }

    @ViewBuilder
    private var saveIcon: some View {
        if #available(iOS 18.0, *) {
            Image(systemName: isSaved ? "checkmark" : "square.and.arrow.down")
                .contentTransition(
                    .symbolEffect(
                        .replace.magic(fallback: .downUp),
                        options: .nonRepeating
                    )
                )
        } else if #available(iOS 17.0, *) {
            Image(systemName: isSaved ? "checkmark" : "square.and.arrow.down")
                .contentTransition(.symbolEffect(.replace.downUp))
        } else {
            Image(systemName: isSaved ? "checkmark" : "square.and.arrow.down")
        }
    }

    // MARK: - Actions

    private func loadSettings() {
        let settings = SettingsManager.shared.settings
        eventId = settings.getEventId()
        teamNumber = settings.getTeamNumber()
    }

    private func save() {
        guard hasChanges else { return }
        focusedField = nil

        let settings = SettingsManager.shared.settings
        settings.setEventId(eventId: eventId)
        settings.setTeamNumber(teamNumber: teamNumber)

        withAnimation {
            hasChanges = false
            isSaved = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                isSaved = false
            }
        }
    }
}

// MARK: - Subviews

private struct SettingsCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) { content }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14, style: .continuous))
    }
}

private struct SettingsRow: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
                .font(.subheadline)
            Spacer()
            TextField(placeholder, text: $text)
                .multilineTextAlignment(.trailing)
                .font(.system(.subheadline, design: .monospaced))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.done)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

#Preview {
    SettingsView()
}
