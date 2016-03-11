//
//  Colorable.swift
//  Tippsy
//
//  Created by Michael L Mehr on 3/7/16.
//  Copyright © 2016 Michael L. Mehr. All rights reserved.
//


import UIKit

protocol Colorable {
    var foreColor: UIColor { get set }
    var backColor: UIColor { get set }
}

extension UITextField: Colorable {
    var foreColor: UIColor {
        get {
            return self.textColor ?? UIColor.clearColor()
        }
        set {
            self.textColor = newValue
        }
    }
    var backColor: UIColor {
        get {
            return self.backgroundColor ?? UIColor.clearColor()
        }
        set {
            self.backgroundColor = newValue
        }
    }
}

extension UILabel: Colorable {
    var foreColor: UIColor {
        get {
            return self.textColor ?? UIColor.clearColor()
        }
        set {
            self.textColor = newValue
        }
    }
    var backColor: UIColor {
        get {
            return self.backgroundColor ?? UIColor.clearColor()
        }
        set {
            self.backgroundColor = newValue
        }
    }
}

