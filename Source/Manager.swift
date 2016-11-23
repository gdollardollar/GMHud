//
//  HudManager.swift
//  Pods
//
//  Created by Guillaume on 11/9/16.
//
//

import UIKit

final class Manager {
    
    private var hudWindow: UIWindow?
    
//    private weak var mainWindow: UIWindow?
    
    private var displayedHud: Hud? {
        return hudWindow?.rootViewController as? Hud
    }
    
    private var hudQueue: [Hud] = []
    
    static let instance = Manager()
    
    func display(hud: Hud) {
        
        guard displayedHud == nil else {
            hudQueue.append(hud)
            //TODO: start timer
            return
        }
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = UIWindowLevelNormal
        window.backgroundColor = .clear
        window.rootViewController = hud
        window.makeKeyAndVisible()
        hudWindow = window
        
    }
    
    func dismiss(hud: Hud) {
        guard displayedHud == hud else {
            if let index = hudQueue.index(of: hud) {
                hudQueue.remove(at: index)
            }
            return
        }
        
        hud.animateDismiss { (f) in
            self.hudWindow?.resignKey()
            self.hudWindow = nil
            //TODO: start timer
        }
    }
}
