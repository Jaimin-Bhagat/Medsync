import Foundation

enum MedicationFrequency: String, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case asNeeded = "As Needed"
}

struct Medication: Codable, Identifiable {
    var id: String
    var name: String
    var dosage: String
    var frequency: MedicationFrequency
    var schedule: [String] // Time strings in format "HH:MM"
    var daysOfWeek: [Int] // 1 = Sunday, 2 = Monday, etc. (for weekly frequency)
    var daysOfMonth: [Int] // 1-31 (for monthly frequency)
    var startDate: Date
    var endDate: Date?
    var instructions: String?
    var reminderEnabled: Bool
    var refillThreshold: Int
    var quantityRemaining: Int
    var prescribedBy: String?
    var notes: String?
    
    init(id: String = UUID().uuidString,
         name: String,
         dosage: String,
         frequency: MedicationFrequency,
         schedule: [String],
         daysOfWeek: [Int],
         daysOfMonth: [Int],
         startDate: Date,
         endDate: Date? = nil,
         instructions: String? = nil,
         reminderEnabled: Bool = true,
         refillThreshold: Int = 5,
         quantityRemaining: Int = 30,
         prescribedBy: String? = nil,
         notes: String? = nil) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.schedule = schedule
        self.daysOfWeek = daysOfWeek
        self.daysOfMonth = daysOfMonth
        self.startDate = startDate
        self.endDate = endDate
        self.instructions = instructions
        self.reminderEnabled = reminderEnabled
        self.refillThreshold = refillThreshold
        self.quantityRemaining = quantityRemaining
        self.prescribedBy = prescribedBy
        self.notes = notes
    }
    
    // Helper method to check if medication needs refill
    var needsRefill: Bool {
        return quantityRemaining <= refillThreshold
    }
    
    // Helper method to get formatted frequency description
    var frequencyDescription: String {
        switch frequency {
        case .daily:
            return "Daily"
        case .weekly:
            let dayNames = daysOfWeek.map { dayNumberToName($0) }.joined(separator: ", ")
            return "Weekly (\(dayNames))"
        case .monthly:
            let dayNumbers = daysOfMonth.map { String($0) }.joined(separator: ", ")
            return "Monthly (Day\(daysOfMonth.count > 1 ? "s" : "") \(dayNumbers))"
        case .asNeeded:
            return "As needed"
        }
    }
    
    // Helper method to get formatted schedule description
    var scheduleDescription: String {
        if schedule.isEmpty {
            return "No scheduled times"
        }
        
        let formattedTimes = schedule.map { formatTimeString($0) }.joined(separator: ", ")
        return formattedTimes
    }
    
    // Helper method to convert day number to name
    private func dayNumberToName(_ dayNumber: Int) -> String {
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        guard dayNumber >= 1 && dayNumber <= 7 else { return "" }
        return days[dayNumber - 1]
    }
    
    // Helper method to format time string
    private func formatTimeString(_ timeString: String) -> String {
        let components = timeString.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return timeString
        }
        
        let hourValue = hour % 12 == 0 ? 12 : hour % 12
        let amPm = hour < 12 ? "AM" : "PM"
        return String(format: "%d:%02d %@", hourValue, minute, amPm)
    }
}

// Status of a medication for a specific time
enum MedicationStatus: String, Codable {
    case pending
    case taken
    case skipped
    case missed
}

// Record of medication taken
struct MedicationRecord: Identifiable, Codable {
    var id = UUID()
    var medicationId: UUID
    var scheduledTime: Date
    var actualTime: Date?
    var status: MedicationStatus
    var notes: String?
} 