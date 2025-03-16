import Foundation

class MedicationDataStore {
    static let shared = MedicationDataStore()
    
    private let userDefaults = UserDefaults.standard
    private let medicationsKey = "medications"
    
    private init() {}
    
    // MARK: - CRUD Operations
    
    func getAllMedications() -> [Medication] {
        guard let data = userDefaults.data(forKey: medicationsKey) else {
            return []
        }
        
        do {
            let medications = try JSONDecoder().decode([Medication].self, from: data)
            return medications.sorted { $0.name < $1.name }
        } catch {
            print("Error decoding medications: \(error.localizedDescription)")
            return []
        }
    }
    
    func getMedication(withId id: String) -> Medication? {
        return getAllMedications().first { $0.id == id }
    }
    
    func saveMedication(_ medication: Medication) {
        var medications = getAllMedications()
        
        // Update existing or add new
        if let index = medications.firstIndex(where: { $0.id == medication.id }) {
            medications[index] = medication
        } else {
            medications.append(medication)
        }
        
        saveMedications(medications)
    }
    
    func deleteMedication(withId id: String) {
        var medications = getAllMedications()
        medications.removeAll { $0.id == id }
        saveMedications(medications)
    }
    
    // MARK: - Helper Methods
    
    private func saveMedications(_ medications: [Medication]) {
        do {
            let data = try JSONEncoder().encode(medications)
            userDefaults.set(data, forKey: medicationsKey)
        } catch {
            print("Error encoding medications: \(error.localizedDescription)")
        }
    }
    
    func getMedicationsDueToday() -> [Medication] {
        let allMedications = getAllMedications()
        let today = Calendar.current.startOfDay(for: Date())
        
        return allMedications.filter { medication in
            guard medication.reminderEnabled else { return false }
            
            switch medication.frequency {
            case .daily:
                return true
                
            case .weekly:
                let weekday = Calendar.current.component(.weekday, from: today)
                return medication.daysOfWeek.contains(weekday)
                
            case .monthly:
                let dayOfMonth = Calendar.current.component(.day, from: today)
                return medication.daysOfMonth.contains(dayOfMonth)
                
            case .asNeeded:
                return false
            }
        }
    }
    
    func getMedicationsForDate(_ date: Date) -> [Medication] {
        let allMedications = getAllMedications()
        let targetDate = Calendar.current.startOfDay(for: date)
        let weekday = Calendar.current.component(.weekday, from: targetDate)
        let dayOfMonth = Calendar.current.component(.day, from: targetDate)
        
        return allMedications.filter { medication in
            guard medication.reminderEnabled else { return false }
            
            switch medication.frequency {
            case .daily:
                return true
                
            case .weekly:
                return medication.daysOfWeek.contains(weekday)
                
            case .monthly:
                return medication.daysOfMonth.contains(dayOfMonth)
                
            case .asNeeded:
                return false
            }
        }
    }
    
    func getMedicationsNeedingRefill() -> [Medication] {
        return getAllMedications().filter { $0.quantityRemaining <= $0.refillThreshold }
    }
    
    // MARK: - Sample Data
    
    func loadSampleDataIfNeeded() {
        if getAllMedications().isEmpty {
            let sampleMedications = [
                Medication(
                    id: "med1",
                    name: "Lisinopril",
                    dosage: "10mg",
                    frequency: .daily,
                    schedule: ["08:00", "20:00"],
                    daysOfWeek: [],
                    daysOfMonth: [],
                    startDate: Date(),
                    endDate: nil,
                    instructions: "Take with food",
                    reminderEnabled: true,
                    refillThreshold: 5,
                    quantityRemaining: 15,
                    prescribedBy: "Dr. Smith",
                    notes: "For blood pressure"
                ),
                Medication(
                    id: "med2",
                    name: "Vitamin D",
                    dosage: "1000 IU",
                    frequency: .daily,
                    schedule: ["08:00"],
                    daysOfWeek: [],
                    daysOfMonth: [],
                    startDate: Date(),
                    endDate: nil,
                    instructions: "Take with breakfast",
                    reminderEnabled: true,
                    refillThreshold: 10,
                    quantityRemaining: 30,
                    prescribedBy: "Dr. Johnson",
                    notes: "For vitamin D deficiency"
                ),
                Medication(
                    id: "med3",
                    name: "Ibuprofen",
                    dosage: "200mg",
                    frequency: .asNeeded,
                    schedule: [],
                    daysOfWeek: [],
                    daysOfMonth: [],
                    startDate: Date(),
                    endDate: nil,
                    instructions: "Take as needed for pain",
                    reminderEnabled: false,
                    refillThreshold: 5,
                    quantityRemaining: 20,
                    prescribedBy: nil,
                    notes: "For headaches and minor pain"
                )
            ]
            
            for medication in sampleMedications {
                saveMedication(medication)
            }
        }
    }
} 