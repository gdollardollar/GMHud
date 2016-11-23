//
//  HudSegue.swift
//  GMHud
//
//  Created by Guillaume on 11/22/16.
//  Copyright © 2016 gdollardollar. All rights reserved.
//

import UIKit

class HudSegue: UIStoryboardSegue {
    
    override func perform() {
        
        (destination as! Hud).display()
        
    }

}
