import Foundation

struct Medication: Identifiable, Codable {
    var id = UUID()
    var name: String
    var dosage: String
    var schedule: [MedicationTime]
    var instructions: String
    var color: String // Store as hex string
    var imageURL: URL?
    var refillDate: Date?
    var refillReminder: Bool
    var remainingDoses: Int?
    
    struct MedicationTime: Identifiable, Codable {
        var id = UUID()
        var time: Date
        var daysOfWeek: [Int] // 1-7 representing Sunday-Saturday
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