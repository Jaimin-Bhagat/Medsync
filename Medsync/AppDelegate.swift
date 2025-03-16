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
        // Setup notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Setup notification actions
        NotificationService.shared.setupNotificationActions()
        
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
        let userInfo = response.notification.request.content.userInfo
        
        // Handle medication notification actions
        if response.notification.request.content.categoryIdentifier == "MEDICATION_REMINDER" {
            if let medicationIdString = userInfo["medicationId"] as? String,
               let medicationId = UUID(uuidString: medicationIdString) {
                
                let medications = DataStore.shared.loadMedications()
                guard let medication = medications.first(where: { $0.id == medicationId }) else {
                    completionHandler()
                    return
                }
                
                var records = DataStore.shared.loadMedicationRecords()
                let now = Date()
                
                // Create a new record based on the action
                let record = MedicationRecord(
                    medicationId: medicationId,
                    scheduledTime: now,
                    actualTime: now,
                    status: .pending,
                    notes: nil
                )
                
                switch response.actionIdentifier {
                case "TAKE_ACTION":
                    // Mark as taken
                    var updatedRecord = record
                    updatedRecord.status = .taken
                    records.append(updatedRecord)
                    DataStore.shared.saveMedicationRecords(records)
                    
                case "SKIP_ACTION":
                    // Mark as skipped
                    var updatedRecord = record
                    updatedRecord.status = .skipped
                    records.append(updatedRecord)
                    DataStore.shared.saveMedicationRecords(records)
                    
                case "SNOOZE_ACTION":
                    // Snooze for 15 minutes
                    let snoozeTime = now.addingTimeInterval(15 * 60)
                    NotificationService.shared.scheduleMedicationReminder(
                        for: medication,
                        at: snoozeTime,
                        identifier: "snooze-\(medicationId.uuidString)-\(Int(now.timeIntervalSince1970))"
                    )
                    
                default:
                    break
                }
            }
        }
        
        completionHandler()
    }
}

