//
//  ViewController.swift
//  GMHud
//
//  Created by Guillaume on 11/9/16.
//  Copyright © 2016 gdollardollar. All rights reserved.
//

import UIKit
import GMHud

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hud = Hud.loading()

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { 
            hud.set(text: "Dude")
        }
////        let hud = Hud.show(text: "dude")
    }

}

