import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    // Request notification permissions
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
            completion(granted)
        }
    }
    
    // Schedule a medication reminder notification
    func scheduleMedicationReminder(medication: Medication, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Medication Reminder"
        content.body = "Time to take \(medication.name) - \(medication.dosage)"
        content.sound = .default
        content.badge = 1
        content.userInfo = ["medicationId": medication.id]
        
        // Create a calendar-based trigger
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create the request
        let identifier = "medication-\(medication.id)-\(date.timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling medication notification: \(error.localizedDescription)")
            }
        }
    }
    
    // Schedule an appointment reminder notification
    func scheduleAppointmentReminder(appointment: Appointment) {
        let content = UNMutableNotificationContent()
        content.title = "Appointment Reminder"
        content.body = "You have an appointment with \(appointment.doctorName) tomorrow at \(formatTime(from: appointment.date))"
        content.sound = .default
        content.badge = 1
        content.userInfo = ["appointmentId": appointment.id]
        
        // Create a calendar-based trigger for 1 day before the appointment
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: appointment.date)
        components.day = components.day! - 1
        components.hour = 9 // Notify at 9 AM the day before
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create the request
        let identifier = "appointment-\(appointment.id)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling appointment notification: \(error.localizedDescription)")
            }
        }
    }
    
    // Schedule a health reminder notification
    func scheduleHealthReminder(reminder: HealthReminder) {
        guard reminder.reminderEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Health Reminder"
        content.body = reminder.title
        if let notes = reminder.notes {
            content.body += " - \(notes)"
        }
        content.sound = .default
        content.badge = 1
        content.userInfo = ["reminderId": reminder.id]
        
        // Create a calendar-based trigger
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create the request
        let identifier = "reminder-\(reminder.id)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling health reminder notification: \(error.localizedDescription)")
            }
        }
    }
    
    // Schedule all pending medication reminders
    func scheduleAllPendingMedicationReminders() {
        // Get all medications from the data store
        let medications = MedicationDataStore.shared.getAllMedications()
        
        // Clear existing medication notifications
        clearMedicationNotifications()
        
        // Schedule new notifications for each medication
        for medication in medications {
            // Skip medications that don't have reminders enabled
            guard medication.reminderEnabled else { continue }
            
            // Calculate the next reminder times based on frequency and schedule
            let reminderTimes = calculateMedicationReminderTimes(for: medication)
            
            // Schedule a notification for each reminder time
            for reminderTime in reminderTimes {
                scheduleMedicationReminder(medication: medication, date: reminderTime)
            }
        }
    }
    
    // Schedule all pending appointment reminders
    func scheduleAllPendingAppointmentReminders() {
        // Get all upcoming appointments from the data store
        let appointments = AppointmentDataStore.shared.getUpcomingAppointments()
        
        // Clear existing appointment notifications
        clearAppointmentNotifications()
        
        // Schedule new notifications for each appointment
        for appointment in appointments {
            // Only schedule reminders for future appointments
            if appointment.date > Date() {
                scheduleAppointmentReminder(appointment: appointment)
            }
        }
    }
    
    // Schedule all pending health reminders
    func scheduleAllPendingHealthReminders() {
        // Get all upcoming reminders from the data store
        let reminders = HealthReminderDataStore.shared.getUpcomingReminders()
        
        // Clear existing health reminder notifications
        clearHealthReminderNotifications()
        
        // Schedule new notifications for each reminder
        for reminder in reminders {
            scheduleHealthReminder(reminder: reminder)
        }
    }
    
    // Clear all medication notifications
    private func clearMedicationNotifications() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let medicationIdentifiers = requests.filter { $0.identifier.hasPrefix("medication-") }.map { $0.identifier }
            center.removePendingNotificationRequests(withIdentifiers: medicationIdentifiers)
        }
    }
    
    // Clear all appointment notifications
    private func clearAppointmentNotifications() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let appointmentIdentifiers = requests.filter { $0.identifier.hasPrefix("appointment-") }.map { $0.identifier }
            center.removePendingNotificationRequests(withIdentifiers: appointmentIdentifiers)
        }
    }
    
    // Clear all health reminder notifications
    private func clearHealthReminderNotifications() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let reminderIdentifiers = requests.filter { $0.identifier.hasPrefix("reminder-") }.map { $0.identifier }
            center.removePendingNotificationRequests(withIdentifiers: reminderIdentifiers)
        }
    }
    
    // Calculate medication reminder times based on frequency and schedule
    private func calculateMedicationReminderTimes(for medication: Medication) -> [Date] {
        var reminderTimes: [Date] = []
        let calendar = Calendar.current
        let now = Date()
        
        // Look ahead 7 days for scheduling reminders
        let lookAheadDays = 7
        
        switch medication.frequency {
        case .daily:
            // Schedule daily reminders for the next week
            for dayOffset in 0..<lookAheadDays {
                for timeString in medication.schedule {
                    if let reminderTime = createDateFromTimeString(timeString, dayOffset: dayOffset) {
                        // Only add future reminders
                        if reminderTime > now {
                            reminderTimes.append(reminderTime)
                        }
                    }
                }
            }
            
        case .weekly:
            // Schedule weekly reminders
            for dayOffset in 0..<(lookAheadDays * 7) {
                let futureDate = calendar.date(byAdding: .day, value: dayOffset, to: now)!
                let weekday = calendar.component(.weekday, from: futureDate)
                
                // Check if this day matches one of the medication's scheduled days
                if medication.daysOfWeek.contains(weekday) {
                    for timeString in medication.schedule {
                        if let reminderTime = createDateFromTimeString(timeString, date: futureDate) {
                            // Only add future reminders
                            if reminderTime > now {
                                reminderTimes.append(reminderTime)
                            }
                        }
                    }
                }
            }
            
        case .monthly:
            // Schedule monthly reminders
            let daysInMonth = calendar.range(of: .day, in: .month, for: now)?.count ?? 30
            for monthOffset in 0..<3 { // Look ahead 3 months
                for dayOfMonth in medication.daysOfMonth {
                    // Make sure the day is valid for the month
                    if dayOfMonth > 0 && dayOfMonth <= daysInMonth {
                        var components = calendar.dateComponents([.year, .month], from: now)
                        components.month = (components.month ?? 1) + monthOffset
                        components.day = dayOfMonth
                        
                        for timeString in medication.schedule {
                            if let time = timeStringToComponents(timeString) {
                                components.hour = time.hour
                                components.minute = time.minute
                                
                                if let reminderDate = calendar.date(from: components), reminderDate > now {
                                    reminderTimes.append(reminderDate)
                                }
                            }
                        }
                    }
                }
            }
            
        case .asNeeded:
            // No automatic reminders for as-needed medications
            break
        }
        
        return reminderTimes
    }
    
    // Helper function to create a Date from a time string (e.g., "09:00")
    private func createDateFromTimeString(_ timeString: String, dayOffset: Int = 0) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        
        guard let time = timeStringToComponents(timeString) else {
            return nil
        }
        
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        if dayOffset > 0 {
            let futureDate = calendar.date(byAdding: .day, value: dayOffset, to: now)!
            components = calendar.dateComponents([.year, .month, .day], from: futureDate)
        }
        
        components.hour = time.hour
        components.minute = time.minute
        
        return calendar.date(from: components)
    }
    
    // Create a date from a time string using a specific date as the base
    private func createDateFromTimeString(_ timeString: String, date: Date) -> Date? {
        let calendar = Calendar.current
        
        guard let time = timeStringToComponents(timeString) else {
            return nil
        }
        
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = time.hour
        components.minute = time.minute
        
        return calendar.date(from: components)
    }
    
    // Convert a time string (e.g., "09:00") to hour and minute components
    private func timeStringToComponents(_ timeString: String) -> (hour: Int, minute: Int)? {
        let components = timeString.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]),
              hour >= 0 && hour < 24,
              minute >= 0 && minute < 60 else {
            return nil
        }
        
        return (hour: hour, minute: minute)
    }
    
    // Format a date to display only the time
    private func formatTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
} 