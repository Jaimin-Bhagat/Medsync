import Foundation

struct HealthReminder: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var dueDate: Date
    var completed: Bool
    var category: HealthReminderCategory
    var recurrence: RecurrencePattern?
    var notes: String?
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