//
//  CardView.swift
//  test
//
//  Created by Rana Muneeb on 10/11/2020.
//

import Foundation
import UIKit

@IBDesignable
class CircleImageView: UIImageView {

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
    
}
