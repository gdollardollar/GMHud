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
    
    @IBAction func textAndButton(_ sender: AnyObject?) {
        _ = Hud.display(text: "This is a text. It is long to be multiline.", buttons: ["Ok", "This is great"], action: { (hud, view) -> (Bool) in
            switch view.tag {
            case Hud.coverTag:
                print("cover")
            default:
                print("index: \(view.tag)")
            }
            return true
        })
    }

}

