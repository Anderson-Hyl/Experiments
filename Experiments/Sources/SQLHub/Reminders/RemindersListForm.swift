import SwiftUI
import SharingGRDB
import IssueReporting

public struct RemindersListForm: View {
    @Dependency(\.defaultDatabase) private var database
    @State private var remindersList: RemindersList.Draft
    @Environment(\.dismiss) var dismiss
    public init(remindersList: RemindersList.Draft) {
        self.remindersList = remindersList
    }
    public var body: some View {
        Form {
            Section {
                VStack {
                    TextField("List Name", text: $remindersList.title)
                      .font(.system(.title2, design: .rounded, weight: .bold))
                      .foregroundStyle(remindersList.color)
                      .multilineTextAlignment(.center)
                      .padding()
                      .textFieldStyle(.plain)
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(.buttonBorder)
            }
            ColorPicker("Color", selection: $remindersList.color)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Add Reminder List")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Save") {
                    withErrorReporting {
                        try database.write { db in
                            try RemindersList.upsert {
                                remindersList
                            }
                            .execute(db)
                        }
                    }
                    dismiss()
                }
                .disabled(remindersList.title.isEmpty)
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}
