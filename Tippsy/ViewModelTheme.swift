//
//  ViewModelTheme.swift
//  Tippsy
//
//  Created by Michael L Mehr on 3/7/16.
//  Copyright © 2016 Michael L. Mehr. All rights reserved.
//

import UIKit

struct ViewModelTheme {
    let fgColor: UIColor
    let bgColor: UIColor
    
    static func transform( input: ViewModelTheme ) -> ViewModelTheme {
        return ViewModelTheme(fgColor: input.bgColor, bgColor: input.fgColor)
    }
    
    static func fromView( view: UIView ) -> ViewModelTheme {
        let backgroundColor = view.backgroundColor ?? UIColor.clearColor()
        return ViewModelTheme(fgColor: view.tintColor, bgColor: backgroundColor)
    }
}
