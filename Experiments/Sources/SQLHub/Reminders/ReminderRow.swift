import Foundation
import SwiftUI
import IssueReporting
import SharingGRDB

public struct ReminderRow: View {
    let color: Color
    let isPastDue: Bool
    let notes: String
    let reminder: Reminder
    let remindersList: RemindersList
    let showCompleted: Bool
    let tags: [String]
    let editAction: () -> Void
    let deleteAction: () -> Void
    let toggleFlagAction: () -> Void
    
    @Dependency(\.defaultDatabase) var database
    
    public init(
        color: Color,
        isPastDue: Bool,
        notes: String,
        reminder: Reminder,
        remindersList: RemindersList,
        showCompleted: Bool,
        tags: [String],
        editAction: @escaping () -> Void,
        deleteAction: @escaping () -> Void,
        toggleFlagAction: @escaping () -> Void,
    ) {
        self.color = color
        self.isPastDue = isPastDue
        self.notes = notes
        self.reminder = reminder
        self.remindersList = remindersList
        self.showCompleted = showCompleted
        self.tags = tags
        self.editAction = editAction
        self.deleteAction = deleteAction
        self.toggleFlagAction = toggleFlagAction
    }
    
    public var body: some View {
        HStack {
            HStack(alignment: .firstTextBaseline) {
                Button {
                    completeButtonTapped()
                } label: {
									Image(systemName: reminder.isCompleted ? "circle.inset.filled" : "circle")
                        .foregroundStyle(reminder.isCompleted ? Color.gray : remindersList.color)
                        .font(.title2)
                }
                VStack(alignment: .leading) {
                    title(for: reminder)
                    
                    if !notes.isEmpty {
                        Text(notes)
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .lineLimit(2)
                    }
                    subtitleText
                }
            }
            Spacer()
            if !reminder.isCompleted {
                HStack {
                    if reminder.isFlagged {
                        Image(systemName: "flag.fill")
                            .foregroundStyle(.blue.gradient)
                    }
                    Button {
                        editAction()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .tint(Color.blue.gradient)
                }
            }
        }
        .buttonStyle(.borderless)
        .swipeActions {
            Button("Delete", role: .destructive) {
                deleteAction()
            }
            Button(reminder.isFlagged ? "Unflagg" : "Flag") {
                toggleFlagAction()
            }
            .tint(.orange)
            Button("Details") {
                editAction()
            }
        }
    }
    
    private func title(for reminder: Reminder) -> some View {
        HStack {
            if let priority = reminder.priority {
                Text(String(repeating: "!", count: priority.rawValue))
								.foregroundStyle(reminder.isCompleted ? .gray : remindersList.color)
            }
            Text(reminder.title)
                .foregroundStyle(reminder.isCompleted ? .gray : .primary)
        }
        .font(.title3)
    }
    
    private func completeButtonTapped() {
			withErrorReporting {
					try database.write { db in
							try Reminder
									.find(reminder.id)
									.update { $0.toggleStatus() }
									.execute(db)
					}
			}
    }
    
    private var dueText: Text {
        if let date = reminder.dueDate {
            Text(date.formatted(date: .numeric, time: .shortened))
                .foregroundStyle(isPastDue ? .red : .gray)
        } else {
            Text("")
        }
    }
    
    private var subtitleText: Text {
        let tagsText = tags.reduce(Text(reminder.dueDate == nil ? "" : " ")) { result, tag in
            result + Text("#\(tag) ")
        }
        return (dueText + tagsText.foregroundStyle(.gray).bold()).font(.callout)
    }
}

