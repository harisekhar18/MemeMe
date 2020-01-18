//
//  BottomTextFieldDelegate.swift
//  MemeMe
//
//  Created by Hari Prasad on 1/14/20.
//  Copyright © 2020 Hari Prasad. All rights reserved.
//

import Foundation
import UIKit

class BottomTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    //MARK: Setting the textfield to blank when it is clicked
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        
    }

    //MARK: textFieldShouldReturn function implementation
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
