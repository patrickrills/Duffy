//
//  Duffy
//
//

import UIKit
import DuffyFramework

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
                
        if let urlContext = connectionOptions.urlContexts.first {
            handleURL(urlContext.url)
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        LoggingService.log("App will resign active")
        
        if let window = window {
            if let root = window.rootViewController as? MainTableViewController {
                root.unsubscribeToHealthUpdates()
            }
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        LoggingService.log("App did enter background")
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.scheduleTask()
        }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        LoggingService.log("App will enter foreground")
        
        if let window = window {
            if let root = window.rootViewController as? MainTableViewController {
                root.refresh()
                root.subscribeToHealthUpdates()
            }
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        LoggingService.log("App did become active")
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        LoggingService.log("Scene did disconnect")
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let urlContext = URLContexts.first {
            handleURL(urlContext.url)
        }
    }
    
    private func handleURL(_ url: URL) {
        if let host = url.host, host == "debug" {
            DebugService.toggleDebugMode()
        }
    }
}
