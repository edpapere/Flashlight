//
//  ViewController.swift
//  Flashlight
//
//  Created by Andrey Pereslavtsev on 02.11.2020.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var currentColor = 0 // 0 - off, 1 - white, 2 - red, 3 - yellow, 4 - green
    var isLightOn: Bool { currentColor > 0 } // var isLightOn = false
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    let minimumLuminosity: CGFloat = 0.2
    var currentLuminosity: CGFloat = 1
    var isAdjustmentMode = false

    var lightColor: UIColor {
        switch currentColor {
        case 2:
            return UIColor(red: currentLuminosity, green: 0, blue: 0, alpha: 1)
        case 3:
            return UIColor(red: currentLuminosity, green: currentLuminosity, blue: 0, alpha: 1)
        case 4:
            return UIColor(red: 0, green: currentLuminosity, blue: 0, alpha: 1)
        default:
            return UIColor(red: currentLuminosity, green: currentLuminosity, blue: currentLuminosity, alpha: 1)
        }
    }
    
    var adjustmentScale: CGFloat {
        self.view.frame.height / 2
    }

    // MARK: - METHODS -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        //print( #line, #function, adjustmentScale)
    }

    fileprivate func updateTorch() {
        guard
            let device = AVCaptureDevice.default(for: AVMediaType.video),
            device.hasTorch
        else { return }
        
        do {
            try device.lockForConfiguration()
            if isLightOn {
                try device.setTorchModeOn(level: Float(currentLuminosity) )
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
        
    }
    
    fileprivate func updateUI() {
        self.view.backgroundColor = isLightOn ? lightColor : .black
        updateTorch()
    }
        
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        // do not toggle the light in adjustment mode -- quit ajustment mode instead
        if isAdjustmentMode {
            isAdjustmentMode = false
        } else {
            currentColor = (currentColor + 1) % 5 // isLightOn.toggle()
        }

        updateUI()
        //print(#line,#function, isLightOn, lightLuminosity)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        if touch != nil {
            
            // Enter manual adjustment mode
            isAdjustmentMode = true
            
            // if light is off then switch it on at minimal luminosity
            if !isLightOn {
                currentLuminosity = minimumLuminosity
                currentColor = 1 // isLightOn = true
            }
            
            // Calculate adjustment change and apply to current luminosity:
            //  - swipe up increases lummonicity
            //  - swipe down decreases luminocity
            let change = touch!.previousLocation(in: nil).y - touch!.location(in: nil).y
            currentLuminosity += ( change/adjustmentScale )
            
            // let luminosity to stay in interval [minimumLuminosity...1] and
            // switch light off if luminosity had been adjusted to lower than minimum
            // (additionaly set luminosity to maximum in order to reset everything to initial state)
            currentLuminosity = currentLuminosity > 1.0 ? 1.0 : currentLuminosity
            if currentLuminosity < minimumLuminosity {
                currentLuminosity = 1.0
                currentColor = 0 // isLightOn = false
            }
            
            updateUI()
            
            //print(#line,#function, isLightOn, currentLuminosity, change)
        }
        
        super.touchesMoved(touches, with: event)
            
    }
    
}

