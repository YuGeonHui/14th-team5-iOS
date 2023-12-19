//
//  SceneDelegate.swift
//  App
//
//  Created by Kim dohyun on 11/15/23.
//

import UIKit

import Core

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let profileDIContainer = ProfileDIContainer().makeViewController()
        window = UIWindow(windowScene: scene)
        window?.rootViewController = UINavigationController(rootViewController: HomeViewController(reacter: HomeViewReactor()))
        window?.makeKeyAndVisible()
    }
}




