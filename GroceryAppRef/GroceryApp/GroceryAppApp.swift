//
//  GroceryAppApp.swift
//  GroceryApp
//
//  Created by Mohammad Azam on 10/23/20.
//

import SwiftUI
import Firebase

@main
struct GroceryAppApp: App {
    
    func setupTheme() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navBarAppearance
            .largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navBarAppearance
        
            .backgroundColor = UIColor(red: 142/255, green: 68/255, blue: 173/255, alpha: 1.0)
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
            
        UINavigationBar.appearance().tintColor = UIColor.white
        
        UIBarButtonItem.appearance()
            .setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
    }
    
    init() {
        setupTheme()
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
