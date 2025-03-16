import Foundation

struct HealthProfile: Identifiable, Codable {
    var id = UUID()
    var name: String
    var dateOfBirth: Date
    var gender: String
    var height: Double? // in cm
    var allergies: [String]
    var conditions: [String]
    var bloodType: String?
    var emergencyContacts: [EmergencyContact]
    var documents: [HealthDocument]
    var vitalRecords: [VitalRecord]
    
    struct EmergencyContact: Identifiable, Codable {
        var id = UUID()
        var name: String
        var relationship: String
        var phone: String
        var email: String?
    }
}

struct HealthDocument: Identifiable, Codable {
    var id = UUID()
    var title: String
    var date: Date
    var fileURL: URL
    var notes: String?
    var category: String
}

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