//
//  AppDelegate.swift
//  TheGinnersGame
//
//  Created by Daniel Sykes-Turner on 15/7/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var coordinator: AppCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Startup firebase
        FirebaseApp.configure()
        
        // Start the app, first window
        if let window = self.window {
            self.coordinator = AppCoordinator(window: window)
            self.coordinator?.showIntroView()
        }
        
        return true
    }
}

