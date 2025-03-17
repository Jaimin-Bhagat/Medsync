import Foundation

struct HealthRecord: Codable, Identifiable {
    var id: String
    var title: String
    var date: Date
    var category: HealthRecordCategory
    var notes: String?
    var attachmentURLs: [URL]?
    var values: [String: Double]?
    
    init(id: String = UUID().uuidString,
         title: String,
         date: Date,
         category: HealthRecordCategory,
         notes: String? = nil,
         attachmentURLs: [URL]? = nil,
         values: [String: Double]? = nil) {
        self.id = id
        self.title = title
        self.date = date
        self.category = category
        self.notes = notes
        self.attachmentURLs = attachmentURLs
        self.values = values
    }
    
    // Helper method to get formatted date
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

enum HealthRecordCategory: String, Codable, CaseIterable {
    case profile = "Profile"
    case vitals = "Vitals"
    case labResults = "Lab Results"
    case medications = "Medications"
    case allergies = "Allergies"
    case immunizations = "Immunizations"
    case conditions = "Conditions"
    case procedures = "Procedures"
    case documents = "Documents"
    
    var displayName: String {
        return rawValue
    }
    
    var systemImageName: String {
        switch self {
        case .profile:
            return "person.circle"
        case .vitals:
            return "heart"
        case .labResults:
            return "flask"
        case .medications:
            return "pill"
        case .allergies:
            return "exclamationmark.shield"
        case .immunizations:
            return "syringe"
        case .conditions:
            return "stethoscope"
        case .procedures:
            return "scissors"
        case .documents:
            return "doc.text"
        }
    }
}

// Health Profile model for storing personal health information
struct HealthProfile: Codable {
    var firstName: String
    var lastName: String
    var dateOfBirth: Date
    var gender: String
    var bloodType: String?
    var height: Double? // in cm
    var weight: Double? // in kg
    var emergencyContacts: [EmergencyContact]?
    var allergies: [String]?
    var chronicConditions: [String]?
    
    // Helper method to get formatted date of birth
    var formattedDateOfBirth: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dateOfBirth)
    }
    
    // Helper method to get age
    var age: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year ?? 0
    }
    
    // Helper method to get formatted height in feet and inches
    var formattedHeight: String? {
        guard let height = height else { return nil }
        
        let heightInInches = height / 2.54
        let feet = Int(heightInInches / 12)
        let inches = Int(heightInInches.truncatingRemainder(dividingBy: 12))
        
        return "\(feet)' \(inches)\""
    }
    
    // Helper method to get formatted weight in pounds
    var formattedWeight: String? {
        guard let weight = weight else { return nil }
        
        let weightInPounds = weight * 2.20462
        return String(format: "%.1f lbs", weightInPounds)
    }
}

// Emergency Contact model
struct EmergencyContact: Codable {
    var name: String
    var relationship: String
    var phoneNumber: String
}

// Vital Signs model
struct VitalSigns: Codable, Identifiable {
    var id: String
    var date: Date
    var bloodPressureSystolic: Int?
    var bloodPressureDiastolic: Int?
    var heartRate: Int?
    var respiratoryRate: Int?
    var temperature: Double?
    var oxygenSaturation: Int?
    var notes: String?
    
    // Helper method to get formatted date
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Helper method to get formatted blood pressure
    var formattedBloodPressure: String? {
        guard let systolic = bloodPressureSystolic, let diastolic = bloodPressureDiastolic else {
            return nil
        }
        
        return "\(systolic)/\(diastolic) mmHg"
    }
    
    // Helper method to get formatted temperature
    var formattedTemperature: String? {
        guard let temperature = temperature else { return nil }
        
        return String(format: "%.1f °F", temperature)
    }
}

// Health Document model
struct HealthDocument: Identifiable, Codable {
    var id = UUID()
    var title: String
    var date: Date
    var fileURL: URL
    var notes: String?
    var category: String
}

// Vital Record model
struct VitalRecord: Identifiable, Codable {
    var id = UUID()
    var type: VitalType
    var value: Double
    var unit: String
    var date: Date
    var notes: String?
}

enum VitalType: String, Codable, CaseIterable {
    case weight
    case bloodPressureSystolic
    case bloodPressureDiastolic
    case heartRate
    case bloodGlucose
    case temperature
    case oxygenSaturation
    
    var displayName: String {
        switch self {
        case .weight: return "Weight"
        case .bloodPressureSystolic: return "Blood Pressure (Systolic)"
        case .bloodPressureDiastolic: return "Blood Pressure (Diastolic)"
        case .heartRate: return "Heart Rate"
        case .bloodGlucose: return "Blood Glucose"
        case .temperature: return "Temperature"
        case .oxygenSaturation: return "Oxygen Saturation"
        }
    }
    
    var defaultUnit: String {
        switch self {
        case .weight: return "kg"
        case .bloodPressureSystolic, .bloodPressureDiastolic: return "mmHg"
        case .heartRate: return "bpm"
        case .bloodGlucose: return "mg/dL"
        case .temperature: return "°C"
        case .oxygenSaturation: return "%"
        }
    }
}
