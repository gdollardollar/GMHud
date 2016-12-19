//
//  InputViewController.swift
//  GMHud
//
//  Created by Guillaume on 11/22/16.
//  Copyright © 2016 gdollardollar. All rights reserved.
//

import UIKit
import GMHud

class InputViewController: Hud {
    
    override var blurStyle: Int? {
        return nil
    }
    
    override func animateDisplay() {
        
        let c = view.backgroundColor
        view.backgroundColor = .clear
        content!.transform.ty = content!.bounds.height
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.view.backgroundColor = c
            self.content!.transform.ty = 0
        }, completion: nil)
        
    }
    
    override func animateDismiss(completion: @escaping (Bool) -> ()) {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.view.backgroundColor = .clear
            self.content!.transform.ty = self.content!.bounds.height
        }, completion: completion)
    }
    
    override func coverTapShouldBegin(tap: UITapGestureRecognizer) -> Bool {
        return true
    }

}
