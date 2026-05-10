import ComposeApp
import SwiftUI

struct SettingsView: View {
    @State private var eventId = ""
    @State private var teamNumber = ""
    @State private var savedEventId = ""
    @State private var savedTeamNumber = ""
    @State private var isSaved = false
    @State private var resetTask: Task<Void, Never>?
    @FocusState private var focusedField: Field?

    private enum Field {
        case eventId, teamNumber
    }

    private var hasChanges: Bool {
        eventId != savedEventId || teamNumber != savedTeamNumber
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
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .animation(.default, value: hasChanges)
            .animation(.default, value: isSaved)
        }
        .onAppear(perform: loadSettings)
    }

    // MARK: - Sections

    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(title: "General", icon: "gearshape")
            SettingsCard {
                SettingsRow(
                    label: "Event ID",
                    placeholder: "e.g. 2026daly",
                    text: $eventId
                )
                .focused($focusedField, equals: .eventId)

                Divider().padding(.leading, 14)

                SettingsRow(
                    label: "Team Number",
                    placeholder: "e.g. 3990",
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
        if hasChanges {
            ToolbarItem(id: "discard", placement: .cancellationAction) {
                Button(action: discard) {
                    Image(systemName: "arrow.uturn.backward")
                }
            }
        }
        if hasChanges || isSaved {
            ToolbarItem(id: "save", placement: .confirmationAction) {
                Button(action: save) {
                    saveIcon
                }
                .tint(isSaved ? .green : .accentColor)
            }
        }
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") { focusedField = nil }
                .fontWeight(.semibold)
        }
    }

    @ViewBuilder
    private var saveIcon: some View {
        let name = isSaved ? "checkmark" : "square.and.arrow.down"
        if #available(iOS 18.0, *) {
            Image(systemName: name)
                .contentTransition(.symbolEffect(.replace.byLayer.downUp))
        } else if #available(iOS 17.0, *) {
            Image(systemName: name)
                .contentTransition(.symbolEffect(.replace.byLayer.downUp))
        } else {
            Image(systemName: name)
        }
    }

    // MARK: - Actions

    private func loadSettings() {
        let settings = SettingsManager.shared.settings
        savedEventId = settings.getEventId()
        savedTeamNumber = settings.getTeamNumber()
        eventId = savedEventId
        teamNumber = savedTeamNumber
    }

    private func save() {
        guard hasChanges else { return }
        focusedField = nil

        let settings = SettingsManager.shared.settings
        settings.setEventId(eventId: eventId)
        settings.setTeamNumber(teamNumber: teamNumber)
        savedEventId = eventId
        savedTeamNumber = teamNumber
        isSaved = true

        resetTask?.cancel()
        resetTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            isSaved = false
        }
    }

    private func discard() {
        focusedField = nil
        eventId = savedEventId
        teamNumber = savedTeamNumber
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
