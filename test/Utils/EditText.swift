//
//  CardView.swift
//  test
//
//  Created by Rana Muneeb on 10/11/2020.
//

import Foundation
import UIKit

@IBDesignable
class EditText: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        override open func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        }

        override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        }

        override open func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.shadowRadius = newValue
            layer.masksToBounds = false
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: CGColor {
        get {
            return CGColor.init(red: 0, green: 0, blue: 0, alpha: 0.1)
        }
        set {
            layer.borderColor = newValue
        }
    }


    func setupRightImage(imageName:String){
      let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
      imageView.image = UIImage(named: imageName)
      let imageContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 55, height: 40))
      imageContainerView.addSubview(imageView)
      rightView = imageContainerView
      rightViewMode = .always
      self.tintColor = .lightGray
  }

   //MARK:- Set Image on left of text fields

      func setupLeftImage(imageName:String){
         let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
         imageView.image = UIImage(named: imageName)
         let imageContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 55, height: 40))
         imageContainerView.addSubview(imageView)
         leftView = imageContainerView
         leftViewMode = .always
         self.tintColor = .lightGray
       }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           return false
       }
}
