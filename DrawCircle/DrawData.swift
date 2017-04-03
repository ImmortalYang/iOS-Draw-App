//
//  DrawData.swift
//  DrawCircle
//
//  Created by ImmortalYang on 3/04/17.
//  Copyright © 2017 John Zhang. All rights reserved.
//

import Foundation
import UIKit

//Possible shapes that users can choose from
enum DrawShape: Int
{
    case Ellipse = 0
    case Rectangle = 1
    case Circle = 2
    case Square = 3
    case Line = 4     //straight line
    case FreeStyle = 5//exact path of user's touch
}

extension UIImage {
    convenience init(layer: CALayer) {
        UIGraphicsBeginImageContext(layer.superlayer!.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage!)!)
        
    }
}
