//
//  CATextField.swift
//  BankEnroll
//
//  Created by Nicolas Husser on 21/11/2017.
//  Copyright © 2017 Wavestone. All rights reserved.
//

import UIKit

class CATextField: UITextField, UITextFieldDelegate {
    
    private let border = CALayer()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        delegate = self
        createBorder()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        createBorder()
    }
    
    func createBorder(){
        let width = CGFloat(1.0)
        border.borderColor = UIColor(netHex: CAColors.green).cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func highlightField() {
        let width = CGFloat(3.0)
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.setNeedsLayout()
    }
    
    func unHighlightField() {
        let width = CGFloat(1.0)
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.setNeedsLayout()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("focused")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("lost focus")
    }
    
}
