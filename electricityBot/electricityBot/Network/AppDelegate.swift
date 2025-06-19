//
//  AppDelegate.swift
//  electricityBot
//
//  Created by Dana Litvak on 18.06.2025.
//

import Foundation
import UIKit
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
      _ app: UIApplication,
      open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
      var handled: Bool

      handled = GIDSignIn.sharedInstance.handle(url)
      if handled {
        return true
      }

      return false
    }
}
