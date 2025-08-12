import Foundation
import SwiftUI

public struct ReminderRow: View {
    let color: Color
    let isPastDue: Bool
    let notes: String
    let reminder: Reminder
    let remindersList: RemindersList
    let showCompleted: Bool
    let tags: [String]
    
    @State var isCompleted: Bool
    
    public init(
        color: Color,
        isPastDue: Bool,
        notes: String,
        reminder: Reminder,
        remindersList: RemindersList,
        showCompleted: Bool,
        tags: [String]
    ) {
        self.color = color
        self.isPastDue = isPastDue
        self.notes = notes
        self.reminder = reminder
        self.remindersList = remindersList
        self.showCompleted = showCompleted
        self.tags = tags
        self.isCompleted = reminder.isCompleted
    }
    
    public var body: some View {
        HStack {
            HStack(alignment: .firstTextBaseline) {
                Button {
                    
                } label: {
                    Image(systemName: isCompleted ? "circle.inset.filled" : "circle")
                        .foregroundStyle(isCompleted ? Color.gray : remindersList.color)
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
                        
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .tint(Color.blue.gradient)
                }
            }
        }
    }
    
    private func title(for reminder: Reminder) -> some View {
        HStack {
            if let priority = reminder.priority {
                Text(String(repeating: "!", count: priority.rawValue))
                    .foregroundStyle(isCompleted ? .gray : remindersList.color)
            }
            Text(reminder.title)
                .foregroundStyle(isCompleted ? .gray : .primary)
        }
        .font(.title3)
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


#Preview {
    VStack {
        ReminderRow(
            color: .blue,
            isPastDue: true,
            notes: "",
            reminder: Reminder(
                id: UUID(0),
                dueDate: Date(),
                isFlagged: true,
                notes: "Ask about diet",
                priority: .high,
                remindersListID: UUID(10),
                title: "Doctor appointment"
            ),
            remindersList: RemindersList(
                id: UUID(10),
                color: .blue,
                position: 0,
                title: "Personal"
            ),
            showCompleted: false,
            tags: ["Good", "Milk"]
        )
        
        ReminderRow(
            color: .orange,
            isPastDue: false,
            notes: "",
            reminder: Reminder(
                id: UUID(1),
                dueDate: Date(),
                isCompleted: true,
                isFlagged: true,
                notes: "Ask about diet",
                priority: .high,
                remindersListID: UUID(10),
                title: "Doctor appointment"
            ),
            remindersList: RemindersList(
                id: UUID(10),
                color: .blue,
                position: 0,
                title: "Personal"
            ),
            showCompleted: true,
            tags: ["Good", "Milk"]
        )
    }
}
