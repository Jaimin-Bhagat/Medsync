import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Medication Reminders
    
    func scheduleMedicationReminder(for medication: Medication, at time: Date, identifier: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = "Medication Reminder"
        content.body = "Time to take \(medication.name) - \(medication.dosage)"
        content.sound = .default
        content.userInfo = ["medicationId": medication.id.uuidString]
        content.categoryIdentifier = "MEDICATION_REMINDER"
        
        // Create trigger
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create request
        let id = identifier ?? "medication-\(medication.id.uuidString)-\(components.hour ?? 0)-\(components.minute ?? 0)"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        // Add request
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling medication reminder: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleAppointmentReminder(for appointment: Appointment) {
        let content = UNMutableNotificationContent()
        content.title = "Appointment Reminder"
        content.body = appointment.title
        content.sound = .default
        content.userInfo = ["appointmentId": appointment.id.uuidString]
        
        // Create trigger based on appointment time and reminder time
        var reminderDate = appointment.date
        if let reminderTime = appointment.reminderTime {
            reminderDate = appointment.date.addingTimeInterval(-reminderTime)
        }
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(identifier: "appointment-\(appointment.id.uuidString)", content: content, trigger: trigger)
        
        // Add request
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling appointment reminder: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleRefillReminder(for medication: Medication) {
        guard let refillDate = medication.refillDate, medication.refillReminder else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Medication Refill Reminder"
        content.body = "Time to refill \(medication.name)"
        content.sound = .default
        content.userInfo = ["medicationId": medication.id.uuidString]
        
        // Create trigger
        let components = Calendar.current.dateComponents([.year, .month, .day], from: refillDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(identifier: "refill-\(medication.id.uuidString)", content: content, trigger: trigger)
        
        // Add request
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling refill reminder: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleHealthReminder(for reminder: HealthReminder) {
        let content = UNMutableNotificationContent()
        content.title = "Health Reminder"
        content.body = reminder.title
        content.sound = .default
        content.userInfo = ["reminderId": reminder.id.uuidString]
        
        // Create trigger
        let components = Calendar.current.dateComponents([.year, .month, .day], from: reminder.dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(identifier: "health-\(reminder.id.uuidString)", content: content, trigger: trigger)
        
        // Add request
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling health reminder: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelMedicationReminders(for medicationId: UUID) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiers = requests.filter { $0.identifier.contains(medicationId.uuidString) }.map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    func cancelAppointmentReminder(for appointmentId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["appointment-\(appointmentId.uuidString)"])
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func setupNotificationActions() {
        // Medication actions
        let takeAction = UNNotificationAction(identifier: "TAKE_ACTION", title: "Take", options: .foreground)
        let skipAction = UNNotificationAction(identifier: "SKIP_ACTION", title: "Skip", options: .destructive)
        let snoozeAction = UNNotificationAction(identifier: "SNOOZE_ACTION", title: "Snooze 15 min", options: .foreground)
        
        let medicationCategory = UNNotificationCategory(
            identifier: "MEDICATION_REMINDER",
            actions: [takeAction, skipAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([medicationCategory])
    }
} 