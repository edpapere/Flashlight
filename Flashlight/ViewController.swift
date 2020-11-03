//
//  ViewController.swift
//  Flashlight
//
//  Created by Andrey Pereslavtsev on 02.11.2020.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    // MARK: - Properties -
    
    var currentColor = 0 // 0 - off, 1 - white, 2 - red, 3 - yellow, 4 - green
    var isLightOn: Bool { currentColor > 0 } // var isLightOn = false
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    let minimumLuminosity: CGFloat = 0.2
    var currentLuminosity: CGFloat = 1
    var isAdjustmentMode = false
    
    /// The color of screen calculated from currentColor and currentLuminosity properties
    var screenColor: UIColor {
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
    
    /// Values representing the on-screen length corresponding to full range of luminocity (0...1)
    /// Calculated as one half of view height.
    var adjustmentScale: CGFloat {
        self.view.frame.height / 2
    }
    
    // MARK: - Methods -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        //print( #line, #function, adjustmentScale)
    }
    
    /// Update device flashlight according to isLightOn and currentLuminosity properties
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
    
    /// Update device screen and flashlight according to isLightOn and currentLuminosity properties
    fileprivate func updateUI() {
        self.view.backgroundColor = isLightOn ? screenColor : .black
        updateTorch()
    }
    
    /// Process screen taps to switch touches: switch state through the sequence off - white - red - yellow - green - off
    /// - Parameters:
    ///   - touches: A set of UITouch instances that represent the touches whose values changed.
    ///   - event: The event to which the touches belong.
    /// Detailed description of parameters see in UIResponder documentation.
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
    
    /// Process screen swipes to increase and decrease luminosity
    /// - Parameters:
    ///   - touches: A set of UITouch instances that represent the touches whose values changed.
    ///   - event: The event to which the touches belong.
    /// Detailed description of parameters see in UIResponder documentation.
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

