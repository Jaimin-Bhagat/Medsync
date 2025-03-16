import Foundation

struct Appointment: Codable, Identifiable {
    var id: String
    var title: String
    var doctorName: String
    var specialty: String
    var location: String
    var date: Date
    var duration: Int // in minutes
    var notes: String?
    var reminderEnabled: Bool
    
    init(id: String = UUID().uuidString,
         title: String,
         doctorName: String,
         specialty: String,
         location: String,
         date: Date,
         duration: Int = 30,
         notes: String? = nil,
         reminderEnabled: Bool = true) {
        self.id = id
        self.title = title
        self.doctorName = doctorName
        self.specialty = specialty
        self.location = location
        self.date = date
        self.duration = duration
        self.notes = notes
        self.reminderEnabled = reminderEnabled
    }
    
    // Helper method to get formatted date
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // Helper method to get formatted time
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Helper method to get formatted duration
    var formattedDuration: String {
        if duration < 60 {
            return "\(duration) min"
        } else {
            let hours = duration / 60
            let minutes = duration % 60
            if minutes == 0 {
                return "\(hours) hr"
            } else {
                return "\(hours) hr \(minutes) min"
            }
        }
    }
    
    // Helper method to check if appointment is upcoming
    var isUpcoming: Bool {
        return date > Date()
    }
    
    // Helper method to get end time
    var endDate: Date {
        return date.addingTimeInterval(Double(duration * 60))
    }
    
    // Helper method to get formatted end time
    var formattedEndTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: endDate)
    }
    
    // Helper method to get time range
    var timeRange: String {
        return "\(formattedTime) - \(formattedEndTime)"
    }
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