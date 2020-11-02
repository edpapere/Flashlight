//
//  ViewController.swift
//  Flashlight
//
//  Created by Andrey Pereslavtsev on 02.11.2020.
//

import UIKit

class ViewController: UIViewController {

    var isLightOn = false
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    fileprivate func updateUI() {
        self.view.backgroundColor = isLightOn ? .white : .black
    }
        
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isLightOn.toggle()
        updateUI()
    }
    
}

