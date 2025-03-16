import Foundation

class DataStore {
    static let shared = DataStore()
    
    private let medicationsKey = "medications"
    private let medicationRecordsKey = "medicationRecords"
    private let appointmentsKey = "appointments"
    private let doctorsKey = "doctors"
    private let healthProfileKey = "healthProfile"
    private let healthRemindersKey = "healthReminders"
    
    private init() {}
    
    // MARK: - Medications
    
    func saveMedications(_ medications: [Medication]) {
        save(medications, forKey: medicationsKey)
    }
    
    func loadMedications() -> [Medication] {
        return load(forKey: medicationsKey) ?? []
    }
    
    func saveMedicationRecords(_ records: [MedicationRecord]) {
        save(records, forKey: medicationRecordsKey)
    }
    
    func loadMedicationRecords() -> [MedicationRecord] {
        return load(forKey: medicationRecordsKey) ?? []
    }
    
    // MARK: - Appointments
    
    func saveAppointments(_ appointments: [Appointment]) {
        save(appointments, forKey: appointmentsKey)
    }
    
    func loadAppointments() -> [Appointment] {
        return load(forKey: appointmentsKey) ?? []
    }
    
    // MARK: - Doctors
    
    func saveDoctors(_ doctors: [Doctor]) {
        save(doctors, forKey: doctorsKey)
    }
    
    func loadDoctors() -> [Doctor] {
        return load(forKey: doctorsKey) ?? []
    }
    
    // MARK: - Health Profile
    
    func saveHealthProfile(_ profile: HealthProfile) {
        save(profile, forKey: healthProfileKey)
    }
    
    func loadHealthProfile() -> HealthProfile? {
        return load(forKey: healthProfileKey)
    }
    
    // MARK: - Health Reminders
    
    func saveHealthReminders(_ reminders: [HealthReminder]) {
        save(reminders, forKey: healthRemindersKey)
    }
    
    func loadHealthReminders() -> [HealthReminder] {
        return load(forKey: healthRemindersKey) ?? []
    }
    
    // MARK: - Generic Save/Load
    
    private func save<T: Encodable>(_ data: T, forKey key: String) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let encoded = try encoder.encode(data)
            UserDefaults.standard.set(encoded, forKey: key)
        } catch {
            print("Error saving data: \(error.localizedDescription)")
        }
    }
    
    private func load<T: Decodable>(forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Error loading data: \(error.localizedDescription)")
            return nil
        }
    }
} 