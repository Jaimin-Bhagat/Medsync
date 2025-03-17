//
//  AppDelegate.swift
//  Medsync
//
//  Created by JAIMIN BHAGAT on 2025-03-16.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permissions
        NotificationService.shared.requestNotificationPermission { granted in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
        
        // Load sample data if needed
        MedicationDataStore.shared.loadSampleDataIfNeeded()
        AppointmentDataStore.shared.loadSampleDataIfNeeded()
        HealthReminderDataStore.shared.loadSampleDataIfNeeded()
        HealthRecordDataStore.shared.loadSampleDataIfNeeded()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification response
        let userInfo = response.notification.request.content.userInfo
        
        if let medicationId = userInfo["medicationId"] as? String {
            handleMedicationNotificationResponse(medicationId: medicationId, actionIdentifier: response.actionIdentifier)
        } else if let appointmentId = userInfo["appointmentId"] as? String {
            handleAppointmentNotificationResponse(appointmentId: appointmentId)
        } else if let reminderId = userInfo["reminderId"] as? String {
            handleReminderNotificationResponse(reminderId: reminderId)
        }
        
        completionHandler()
    }
    
    // MARK: - Notification Response Handlers
    
    private func handleMedicationNotificationResponse(medicationId: String, actionIdentifier: String) {
        guard let medication = MedicationDataStore.shared.getMedication(withId: medicationId) else {
            return
        }
        
        switch actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification - open medication detail
            openMedicationDetail(medication)
            
        case "TAKE_ACTION":
            // User marked medication as taken
            markMedicationAsTaken(medication)
            
        case "SKIP_ACTION":
            // User skipped medication
            markMedicationAsSkipped(medication)
            
        case "SNOOZE_ACTION":
            // User snoozed medication reminder
            snoozeMedicationReminder(medication)
            
        default:
            break
        }
    }
    
    private func handleAppointmentNotificationResponse(appointmentId: String) {
        guard let appointment = AppointmentDataStore.shared.getAppointment(withId: appointmentId) else {
            return
        }
        
        // Open appointment detail
        openAppointmentDetail(appointment)
    }
    
    private func handleReminderNotificationResponse(reminderId: String) {
        guard let reminder = HealthReminderDataStore.shared.getReminder(withId: reminderId) else {
            return
        }
        
        // Open reminder detail
        openReminderDetail(reminder)
    }
    
    // MARK: - Helper Methods
    
    private func openMedicationDetail(_ medication: Medication) {
        // Post notification to open medication detail
        NotificationCenter.default.post(
            name: NSNotification.Name("OpenMedicationDetail"),
            object: nil,
            userInfo: ["medicationId": medication.id]
        )
    }
    
    private func openAppointmentDetail(_ appointment: Appointment) {
        // Post notification to open appointment detail
        NotificationCenter.default.post(
            name: NSNotification.Name("OpenAppointmentDetail"),
            object: nil,
            userInfo: ["appointmentId": appointment.id]
        )
    }
    
    private func openReminderDetail(_ reminder: HealthReminder) {
        // Post notification to open reminder detail
        NotificationCenter.default.post(
            name: NSNotification.Name("OpenReminderDetail"),
            object: nil,
            userInfo: ["reminderId": reminder.id]
        )
    }
    
    private func markMedicationAsTaken(_ medication: Medication) {
        // Logic to mark medication as taken
        // This would update the medication history
        print("Medication \(medication.name) marked as taken")
    }
    
    private func markMedicationAsSkipped(_ medication: Medication) {
        // Logic to mark medication as skipped
        print("Medication \(medication.name) marked as skipped")
    }
    
    private func snoozeMedicationReminder(_ medication: Medication) {
        // Reschedule the reminder for 15 minutes later
        let snoozeDate = Date().addingTimeInterval(15 * 60)
        NotificationService.shared.scheduleMedicationReminder(for: medication, at: snoozeDate)
        print("Medication \(medication.name) reminder snoozed for 15 minutes")
    }
}

