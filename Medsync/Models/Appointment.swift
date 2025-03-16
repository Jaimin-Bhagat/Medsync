import Foundation

struct Appointment: Identifiable, Codable {
    var id = UUID()
    var title: String
    var doctorId: UUID?
    var location: String
    var date: Date
    var duration: TimeInterval // in minutes
    var notes: String?
    var reminderTime: TimeInterval? // How many minutes before to remind
}

struct Doctor: Identifiable, Codable {
    var id = UUID()
    var name: String
    var specialty: String
    var phone: String?
    var email: String?
    var address: String?
    var notes: String?
    var isFavorite: Bool = false
    var acceptedInsurance: [String]?
} 