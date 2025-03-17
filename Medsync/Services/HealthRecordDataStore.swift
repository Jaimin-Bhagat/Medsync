import Foundation

class HealthRecordDataStore {
    static let shared = HealthRecordDataStore()
    
    private let userDefaults = UserDefaults.standard
    private let healthProfileKey = "healthProfile"
    private let vitalSignsKey = "vitalSigns"
    private let healthDocumentsKey = "healthDocuments"
    
    private init() {}
    
    // MARK: - Health Profile
    
    func getHealthProfile() -> HealthProfile? {
        guard let data = userDefaults.data(forKey: healthProfileKey) else {
            return nil
        }
        
        do {
            let profile = try JSONDecoder().decode(HealthProfile.self, from: data)
            return profile
        } catch {
            print("Error decoding health profile: \(error.localizedDescription)")
            return nil
        }
    }
    
    func saveHealthProfile(_ profile: HealthProfile) {
        do {
            let data = try JSONEncoder().encode(profile)
            userDefaults.set(data, forKey: healthProfileKey)
        } catch {
            print("Error encoding health profile: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Vital Signs
    
    func getAllVitalSigns() -> [VitalSigns] {
        guard let data = userDefaults.data(forKey: vitalSignsKey) else {
            return []
        }
        
        do {
            let vitalSigns = try JSONDecoder().decode([VitalSigns].self, from: data)
            return vitalSigns.sorted { $0.date > $1.date }
        } catch {
            print("Error decoding vital signs: \(error.localizedDescription)")
            return []
        }
    }
    
    func getVitalSign(withId id: String) -> VitalSigns? {
        return getAllVitalSigns().first { $0.id == id }
    }
    
    func saveVitalSign(_ vitalSign: VitalSigns) {
        var vitalSigns = getAllVitalSigns()
        
        // Update existing or add new
        if let index = vitalSigns.firstIndex(where: { $0.id == vitalSign.id }) {
            vitalSigns[index] = vitalSign
        } else {
            vitalSigns.append(vitalSign)
        }
        
        saveVitalSigns(vitalSigns)
    }
    
    func deleteVitalSign(withId id: String) {
        var vitalSigns = getAllVitalSigns()
        vitalSigns.removeAll { $0.id == id }
        saveVitalSigns(vitalSigns)
    }
    
    private func saveVitalSigns(_ vitalSigns: [VitalSigns]) {
        do {
            let data = try JSONEncoder().encode(vitalSigns)
            userDefaults.set(data, forKey: vitalSignsKey)
        } catch {
            print("Error encoding vital signs: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Health Documents
    
    func getAllHealthDocuments() -> [HealthDocument] {
        guard let data = userDefaults.data(forKey: healthDocumentsKey) else {
            return []
        }
        
        do {
            let documents = try JSONDecoder().decode([HealthDocument].self, from: data)
            return documents.sorted { $0.date > $1.date }
        } catch {
            print("Error decoding health documents: \(error.localizedDescription)")
            return []
        }
    }
    
    func getHealthDocument(withId id: UUID) -> HealthDocument? {
        return getAllHealthDocuments().first { $0.id == id }
    }
    
    func saveHealthDocument(_ document: HealthDocument) {
        var documents = getAllHealthDocuments()
        
        // Update existing or add new
        if let index = documents.firstIndex(where: { $0.id == document.id }) {
            documents[index] = document
        } else {
            documents.append(document)
        }
        
        saveHealthDocuments(documents)
    }
    
    func deleteHealthDocument(withId id: UUID) {
        var documents = getAllHealthDocuments()
        documents.removeAll { $0.id == id }
        saveHealthDocuments(documents)
    }
    
    private func saveHealthDocuments(_ documents: [HealthDocument]) {
        do {
            let data = try JSONEncoder().encode(documents)
            userDefaults.set(data, forKey: healthDocumentsKey)
        } catch {
            print("Error encoding health documents: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Sample Data
    
    func loadSampleDataIfNeeded() {
        // Create sample health profile if needed
        if getHealthProfile() == nil {
            let calendar = Calendar.current
            let birthDate = calendar.date(byAdding: .year, value: -35, to: Date())!
            
            let sampleProfile = HealthProfile(
                firstName: "John",
                lastName: "Doe",
                dateOfBirth: birthDate,
                gender: "Male",
                bloodType: "O+",
                height: 175.0,
                weight: 70.0,
                emergencyContacts: [
                    EmergencyContact(
                        name: "Jane Doe",
                        relationship: "Spouse",
                        phoneNumber: "555-123-4567"
                    )
                ],
                allergies: ["Peanuts", "Penicillin"],
                chronicConditions: ["Asthma"]
            )
            
            saveHealthProfile(sampleProfile)
        }
        
        // Create sample vital signs if needed
        if getAllVitalSigns().isEmpty {
            let now = Date()
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
            let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: now)!
            
            let sampleVitalSigns = [
                VitalSigns(
                    id: "vital1",
                    date: now,
                    bloodPressureSystolic: 120,
                    bloodPressureDiastolic: 80,
                    heartRate: 72,
                    respiratoryRate: 16,
                    temperature: 98.6,
                    oxygenSaturation: 98,
                    notes: "Feeling good"
                ),
                VitalSigns(
                    id: "vital2",
                    date: yesterday,
                    bloodPressureSystolic: 118,
                    bloodPressureDiastolic: 78,
                    heartRate: 70,
                    respiratoryRate: 15,
                    temperature: 98.4,
                    oxygenSaturation: 99,
                    notes: nil
                ),
                VitalSigns(
                    id: "vital3",
                    date: lastWeek,
                    bloodPressureSystolic: 122,
                    bloodPressureDiastolic: 82,
                    heartRate: 74,
                    respiratoryRate: 16,
                    temperature: 98.8,
                    oxygenSaturation: 97,
                    notes: "After exercise"
                )
            ]
            
            for vitalSign in sampleVitalSigns {
                saveVitalSign(vitalSign)
            }
        }
        
        // Create sample documents if needed
        if getAllHealthDocuments().isEmpty {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let sampleDocuments = [
                HealthDocument(
                    title: "Annual Physical Results",
                    date: Date(),
                    fileURL: documentsDirectory.appendingPathComponent("physical_results.pdf"),
                    notes: "Annual checkup with Dr. Smith",
                    category: "Lab Results"
                ),
                HealthDocument(
                    title: "Vaccination Record",
                    date: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
                    fileURL: documentsDirectory.appendingPathComponent("vaccination_record.pdf"),
                    notes: "COVID-19 and flu vaccines",
                    category: "Immunizations"
                )
            ]
            
            for document in sampleDocuments {
                saveHealthDocument(document)
            }
        }
    }
} 