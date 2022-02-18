//
//  SceneDelegate.swift
//  Notes
//
//  Created by Arifin Firdaus on 21/02/21.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private var navigationController = UINavigationController()
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let flow = NoteFlow(navigationController: navigationController)
        flow.start()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    
}
