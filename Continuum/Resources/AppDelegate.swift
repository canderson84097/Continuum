//
//  AppDelegate.swift
//  Continuum
//
//  Created by DevMountain on 2/11/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    checkAccountStatus { (success) in
        let fetchedUserStatement = success ? "Successfully retrieved a logged user" : "Failed to retrieve a logged user"
        print(fetchedUserStatement)
    }
    
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
        if let error = error {
            print("There was an error in \(#function) : \(error.localizedDescription)")
            return
        }
        success ? print("Successfully authorized push notifications") : print("Failed: User declined push notifications")
    }
    application.registerForRemoteNotifications()
    return true
  }
    
    func checkAccountStatus(completion: @escaping (Bool) -> Void) {
        CKContainer.default().accountStatus { (status, error) in
            if let error = error {
                print("Error checking account status: \(error.localizedDescription)")
                return completion(false)
            } else {
                DispatchQueue.main.async {
                    let tabBarController = self.window?.rootViewController
                    let errorText = "Sign into iCloud in your Settings"
                    switch status {
                    case .available:
                        completion(true);
                    case .noAccount:
                        tabBarController?.presentSimpleAlertWith(title: errorText, message: "No account found")
                        completion(false)
                    case .couldNotDetermine:
                        tabBarController?.presentSimpleAlertWith(title: errorText, message: "Unkown error fetching your iCloud Account")
                        completion(false)
                    case .restricted:
                        tabBarController?.presentSimpleAlertWith(title: errorText, message: "Your iCloud account is restricted")
                        completion(false)
                    }
                }
            }
        }
    }
}

