import Foundation

enum ReminderPriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var color: String {
        switch self {
        case .low:
            return "systemGreen"
        case .medium:
            return "systemOrange"
        case .high:
            return "systemRed"
        }
    }
}

enum ReminderStatus: String, Codable, CaseIterable {
    case pending = "Pending"
    case completed = "Completed"
    case missed = "Missed"
    
    var systemImageName: String {
        switch self {
        case .pending:
            return "clock"
        case .completed:
            return "checkmark.circle"
        case .missed:
            return "exclamationmark.circle"
        }
    }
}

enum ReminderFrequency: String, Codable, CaseIterable {
    case once = "Once"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

struct HealthReminder: Codable, Identifiable {
    var id: String
    var title: String
    var notes: String?
    var dueDate: Date
    var priority: ReminderPriority
    var status: ReminderStatus
    var category: String
    var frequency: ReminderFrequency
    var reminderEnabled: Bool
    var completedDate: Date?
    
    init(id: String = UUID().uuidString,
         title: String,
         notes: String? = nil,
         dueDate: Date,
         priority: ReminderPriority = .medium,
         status: ReminderStatus = .pending,
         category: String,
         frequency: ReminderFrequency = .once,
         reminderEnabled: Bool = true,
         completedDate: Date? = nil) {
        self.id = id
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.priority = priority
        self.status = status
        self.category = category
        self.frequency = frequency
        self.reminderEnabled = reminderEnabled
        self.completedDate = completedDate
    }
    
    // Helper method to get formatted due date
    var formattedDueDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dueDate)
    }
    
    // Helper method to get formatted due time
    var formattedDueTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: dueDate)
    }
    
    // Helper method to check if reminder is overdue
    var isOverdue: Bool {
        return dueDate < Date() && status == .pending
    }
    
    // Helper method to get days remaining or overdue
    var daysRemainingText: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dueDay = calendar.startOfDay(for: dueDate)
        
        let components = calendar.dateComponents([.day], from: today, to: dueDay)
        guard let days = components.day else { return "" }
        
        if days == 0 {
            return "Today"
        } else if days == 1 {
            return "Tomorrow"
        } else if days > 1 {
            return "In \(days) days"
        } else if days == -1 {
            return "Yesterday"
        } else {
            return "\(-days) days overdue"
        }
    }
    
    // Helper method to mark reminder as completed
    mutating func markAsCompleted() {
        status = .completed
        completedDate = Date()
    }
    
    // Helper method to mark reminder as missed
    mutating func markAsMissed() {
        status = .missed
    }
    
    // Helper method to reschedule reminder based on frequency
    mutating func reschedule() {
        let calendar = Calendar.current
        
        switch frequency {
        case .once:
            // No rescheduling for one-time reminders
            break
            
        case .daily:
            dueDate = calendar.date(byAdding: .day, value: 1, to: dueDate) ?? dueDate
            
        case .weekly:
            dueDate = calendar.date(byAdding: .day, value: 7, to: dueDate) ?? dueDate
            
        case .monthly:
            dueDate = calendar.date(byAdding: .month, value: 1, to: dueDate) ?? dueDate
            
        case .yearly:
            dueDate = calendar.date(byAdding: .year, value: 1, to: dueDate) ?? dueDate
        }
        
        status = .pending
        completedDate = nil
    }
}

enum HealthReminderCategory: String, Codable, CaseIterable {
    case generalCheckup
    case vaccination
    case screening
    case dental
    case vision
    case other
    
    var displayName: String {
        switch self {
        case .generalCheckup: return "General Checkup"
        case .vaccination: return "Vaccination"
        case .screening: return "Screening"
        case .dental: return "Dental"
        case .vision: return "Vision"
        case .other: return "Other"
        }
    }
}

enum RecurrencePattern: Codable {
    case daily
    case weekly(daysOfWeek: [Int])
    case monthly(dayOfMonth: Int)
    case yearly(month: Int, day: Int)
    case custom(intervalDays: Int)
} 