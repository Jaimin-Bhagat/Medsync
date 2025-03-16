import Foundation

class AppointmentDataStore {
    static let shared = AppointmentDataStore()
    
    private let userDefaults = UserDefaults.standard
    private let appointmentsKey = "appointments"
    
    private init() {}
    
    // MARK: - CRUD Operations
    
    func getAllAppointments() -> [Appointment] {
        guard let data = userDefaults.data(forKey: appointmentsKey) else {
            return []
        }
        
        do {
            let appointments = try JSONDecoder().decode([Appointment].self, from: data)
            return appointments.sorted { $0.date < $1.date }
        } catch {
            print("Error decoding appointments: \(error.localizedDescription)")
            return []
        }
    }
    
    func getAppointment(withId id: String) -> Appointment? {
        return getAllAppointments().first { $0.id == id }
    }
    
    func saveAppointment(_ appointment: Appointment) {
        var appointments = getAllAppointments()
        
        // Update existing or add new
        if let index = appointments.firstIndex(where: { $0.id == appointment.id }) {
            appointments[index] = appointment
        } else {
            appointments.append(appointment)
        }
        
        saveAppointments(appointments)
    }
    
    func deleteAppointment(withId id: String) {
        var appointments = getAllAppointments()
        appointments.removeAll { $0.id == id }
        saveAppointments(appointments)
    }
    
    // MARK: - Helper Methods
    
    private func saveAppointments(_ appointments: [Appointment]) {
        do {
            let data = try JSONEncoder().encode(appointments)
            userDefaults.set(data, forKey: appointmentsKey)
        } catch {
            print("Error encoding appointments: \(error.localizedDescription)")
        }
    }
    
    func getUpcomingAppointments() -> [Appointment] {
        let now = Date()
        return getAllAppointments().filter { $0.date > now }
    }
    
    func getPastAppointments() -> [Appointment] {
        let now = Date()
        return getAllAppointments().filter { $0.date < now }
    }
    
    func getAppointmentsForDate(_ date: Date) -> [Appointment] {
        let calendar = Calendar.current
        return getAllAppointments().filter {
            calendar.isDate($0.date, inSameDayAs: date)
        }
    }
    
    func getAppointmentsForMonth(_ date: Date) -> [Appointment] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        
        return getAllAppointments().filter {
            let appointmentComponents = calendar.dateComponents([.year, .month], from: $0.date)
            return appointmentComponents.year == components.year && appointmentComponents.month == components.month
        }
    }
    
    // MARK: - Sample Data
    
    func loadSampleDataIfNeeded() {
        if getAllAppointments().isEmpty {
            let calendar = Calendar.current
            
            // Create dates for sample appointments
            var dateComponents = DateComponents()
            dateComponents.hour = 10
            dateComponents.minute = 30
            
            // Tomorrow
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
            let tomorrowComponents = calendar.dateComponents([.year, .month, .day], from: tomorrow)
            dateComponents.year = tomorrowComponents.year
            dateComponents.month = tomorrowComponents.month
            dateComponents.day = tomorrowComponents.day
            let tomorrowAppointmentDate = calendar.date(from: dateComponents)!
            
            // Next week
            let nextWeek = calendar.date(byAdding: .day, value: 7, to: Date())!
            let nextWeekComponents = calendar.dateComponents([.year, .month, .day], from: nextWeek)
            dateComponents.year = nextWeekComponents.year
            dateComponents.month = nextWeekComponents.month
            dateComponents.day = nextWeekComponents.day
            dateComponents.hour = 14
            dateComponents.minute = 0
            let nextWeekAppointmentDate = calendar.date(from: dateComponents)!
            
            // Next month
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: Date())!
            let nextMonthComponents = calendar.dateComponents([.year, .month, .day], from: nextMonth)
            dateComponents.year = nextMonthComponents.year
            dateComponents.month = nextMonthComponents.month
            dateComponents.day = nextMonthComponents.day
            dateComponents.hour = 9
            dateComponents.minute = 0
            let nextMonthAppointmentDate = calendar.date(from: dateComponents)!
            
            let sampleAppointments = [
                Appointment(
                    id: "apt1",
                    title: "Annual Physical",
                    doctorName: "Dr. Smith",
                    specialty: "Primary Care",
                    location: "123 Medical Center, Suite 100",
                    date: tomorrowAppointmentDate,
                    duration: 60,
                    notes: "Bring insurance card and list of current medications",
                    reminderEnabled: true
                ),
                Appointment(
                    id: "apt2",
                    title: "Dental Cleaning",
                    doctorName: "Dr. Johnson",
                    specialty: "Dentist",
                    location: "456 Dental Office",
                    date: nextWeekAppointmentDate,
                    duration: 45,
                    notes: "Six-month cleaning and check-up",
                    reminderEnabled: true
                ),
                Appointment(
                    id: "apt3",
                    title: "Eye Exam",
                    doctorName: "Dr. Williams",
                    specialty: "Optometrist",
                    location: "789 Vision Center",
                    date: nextMonthAppointmentDate,
                    duration: 30,
                    notes: "Annual eye exam",
                    reminderEnabled: true
                )
            ]
            
            for appointment in sampleAppointments {
                saveAppointment(appointment)
            }
        }
    }
} 