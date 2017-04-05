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
    case Star = 4
    case Line = 5     //straight line
    case FreeStyle = 6//exact path of user's touch
}

//Generate a path of star given the restrict rectangle and points on star
public func starPathInRect(rect: CGRect, points: Int) -> UIBezierPath {
    let path = UIBezierPath()
    
    let starExtrusion:CGFloat = rect.width / 4.0
    
    let center = CGPoint(x: rect.origin.x + rect.width/2.0, y: rect.origin.y + rect.height/2.0)
    
    var angle:CGFloat = -CGFloat(M_PI / 2.0)
    let angleIncrement = CGFloat(M_PI * 2.0 / Double(points))
    let radius = rect.width / 2.0
    
    var firstPoint = true
    
    for _ in 1...points {
        
        let point = pointFrom(angle: angle, radius: radius, center: center)
        let nextPoint = pointFrom(angle: angle + angleIncrement, radius: radius, center: center)
        let midPoint = pointFrom(angle: angle + angleIncrement / 2.0, radius: starExtrusion, center: center)
        
        if firstPoint {
            firstPoint = false
            path.move(to: point)
        }
        
        path.addLine(to: midPoint)
        path.addLine(to: nextPoint)
        
        angle += angleIncrement
    }
    
    path.close()
    
    return path
}

//Calculate a point from a given center, angle and radius
func pointFrom(angle: CGFloat, radius: CGFloat, center: CGPoint) -> CGPoint{
    let x = center.x + sin(angle)*radius
    let y = center.y + cos(angle)*radius
    return CGPoint(x: x, y: y)
}

//Extension method on UIImage: initialize a UIImage given a userDrawLayer
extension UIImage {
    convenience init(layer: CALayer) {
        UIGraphicsBeginImageContext(layer.superlayer!.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage!)!)
        
    }
}
