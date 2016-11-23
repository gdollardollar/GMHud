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
        

    }
    
    @IBAction func loading(_ sender: AnyObject?) {
        let hud = Hud.loading()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            hud.set(text: "Dude")
        }

    }
    
    @IBAction func text(_ sender: AnyObject?) {
        _ = Hud.display(text: "dude")
    }

}

