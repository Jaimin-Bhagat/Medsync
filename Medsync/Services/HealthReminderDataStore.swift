import Foundation

class HealthReminderDataStore {
    static let shared = HealthReminderDataStore()
    
    private let userDefaults = UserDefaults.standard
    private let remindersKey = "healthReminders"
    
    private init() {}
    
    // MARK: - CRUD Operations
    
    func getAllReminders() -> [HealthReminder] {
        guard let data = userDefaults.data(forKey: remindersKey) else {
            return []
        }
        
        do {
            let reminders = try JSONDecoder().decode([HealthReminder].self, from: data)
            return reminders.sorted { $0.dueDate < $1.dueDate }
        } catch {
            print("Error decoding health reminders: \(error.localizedDescription)")
            return []
        }
    }
    
    func getReminder(withId id: String) -> HealthReminder? {
        return getAllReminders().first { $0.id == id }
    }
    
    func saveReminder(_ reminder: HealthReminder) {
        var reminders = getAllReminders()
        
        // Update existing or add new
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
        } else {
            reminders.append(reminder)
        }
        
        saveReminders(reminders)
    }
    
    func deleteReminder(withId id: String) {
        var reminders = getAllReminders()
        reminders.removeAll { $0.id == id }
        saveReminders(reminders)
    }
    
    // MARK: - Helper Methods
    
    private func saveReminders(_ reminders: [HealthReminder]) {
        do {
            let data = try JSONEncoder().encode(reminders)
            userDefaults.set(data, forKey: remindersKey)
        } catch {
            print("Error encoding health reminders: \(error.localizedDescription)")
        }
    }
    
    func getUpcomingReminders() -> [HealthReminder] {
        let now = Date()
        return getAllReminders().filter { $0.dueDate > now && $0.status == .pending }
    }
    
    func getOverdueReminders() -> [HealthReminder] {
        let now = Date()
        return getAllReminders().filter { $0.dueDate < now && $0.status == .pending }
    }
    
    func getCompletedReminders() -> [HealthReminder] {
        return getAllReminders().filter { $0.status == .completed }
    }
    
    func getRemindersForDate(_ date: Date) -> [HealthReminder] {
        let calendar = Calendar.current
        return getAllReminders().filter {
            calendar.isDate($0.dueDate, inSameDayAs: date)
        }
    }
    
    func getRemindersForCategory(_ category: String) -> [HealthReminder] {
        return getAllReminders().filter { $0.category == category }
    }
    
    func markReminderAsCompleted(withId id: String) {
        guard var reminder = getReminder(withId: id) else { return }
        
        reminder.markAsCompleted()
        saveReminder(reminder)
        
        // If the reminder has a frequency, reschedule it
        if reminder.frequency != .once {
            var newReminder = reminder
            newReminder.id = UUID().uuidString
            newReminder.reschedule()
            saveReminder(newReminder)
        }
    }
    
    func markReminderAsMissed(withId id: String) {
        guard var reminder = getReminder(withId: id) else { return }
        
        reminder.markAsMissed()
        saveReminder(reminder)
    }
    
    func updateOverdueReminders() {
        let now = Date()
        var reminders = getAllReminders()
        
        for (index, reminder) in reminders.enumerated() {
            if reminder.dueDate < now && reminder.status == .pending {
                reminders[index].markAsMissed()
            }
        }
        
        saveReminders(reminders)
    }
    
    // MARK: - Sample Data
    
    func loadSampleDataIfNeeded() {
        if getAllReminders().isEmpty {
            let calendar = Calendar.current
            
            // Today
            let today = Date()
            
            // Tomorrow
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            
            // Next week
            let nextWeek = calendar.date(byAdding: .day, value: 7, to: today)!
            
            let sampleReminders = [
                HealthReminder(
                    id: "rem1",
                    title: "Blood Pressure Check",
                    notes: "Record systolic and diastolic readings",
                    dueDate: today,
                    priority: .medium,
                    status: .pending,
                    category: "Vitals",
                    frequency: .daily,
                    reminderEnabled: true
                ),
                HealthReminder(
                    id: "rem2",
                    title: "Annual Physical Exam",
                    notes: "Schedule with Dr. Smith",
                    dueDate: nextWeek,
                    priority: .high,
                    status: .pending,
                    category: "Appointments",
                    frequency: .yearly,
                    reminderEnabled: true
                ),
                HealthReminder(
                    id: "rem3",
                    title: "Take Vitamin D",
                    notes: "1000 IU with breakfast",
                    dueDate: tomorrow,
                    priority: .low,
                    status: .pending,
                    category: "Medications",
                    frequency: .daily,
                    reminderEnabled: true
                ),
                HealthReminder(
                    id: "rem4",
                    title: "Drink Water",
                    notes: "8 glasses throughout the day",
                    dueDate: today,
                    priority: .medium,
                    status: .pending,
                    category: "Wellness",
                    frequency: .daily,
                    reminderEnabled: true
                )
            ]
            
            for reminder in sampleReminders {
                saveReminder(reminder)
            }
        }
    }
} 