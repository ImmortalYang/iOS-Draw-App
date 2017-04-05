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

class DrawEngine{
    //Set a state and path for storing free style line
    private var _userIsDraggingInFreeStyleMode = false
    private var _freeStyleLinePath = UIBezierPath()
    
    public func reset(){
        _userIsDraggingInFreeStyleMode = false
        _freeStyleLinePath = UIBezierPath()
    }
    
    //Generate path of ellipse
    public func ellipsePath(in rect: CGRect) -> CGPath{
        return (UIBezierPath(ovalIn: rect)).cgPath
    }
    
    //Generate path of rectangle
    public func rectanglePath(in rect: CGRect) -> CGPath{
        return (UIBezierPath(rect: rect)).cgPath
    }
    
    //Generate path of straight line
    public func straightLinePath(from startPoint: CGPoint, to endPoint: CGPoint) -> CGPath{
        let linePath = UIBezierPath()
        linePath.move(to: startPoint)
        linePath.addLine(to: endPoint)
        return linePath.cgPath
    }
    
    //Generate path of free style line
    public func freeStyleLinePath(from startPoint: CGPoint, to endPoint: CGPoint) -> CGPath{
        if !_userIsDraggingInFreeStyleMode{
            //Add the first line in free style path
            _freeStyleLinePath.move(to: startPoint)
            _freeStyleLinePath.addLine(to: endPoint)
            _userIsDraggingInFreeStyleMode = true
        }
        else{
            _freeStyleLinePath.addLine(to: endPoint)
        }
        //The end point of current segment of line is the start point of next segment of line
        _freeStyleLinePath.move(to: endPoint)
        return _freeStyleLinePath.cgPath
    }
    
    //Generate a path of star given the restrict rectangle, points on star, extrusion and rotation.
    //points: how many points the star has
    //extrusion: length from center to extrude point
    //rotation: rotation angle
    public func starPath(in rect: CGRect, points: Int, extrusion: CGFloat? = nil, rotation: CGFloat? = nil) -> CGPath {
        let path = UIBezierPath()
        
        //Extrusion should always be positive so call rect.width instead of rect.size.width
        let starExtrusion = extrusion ?? rect.width / 4.0
        
        //Must call rect.size.width instead of rect.width to get a signed value
        let center = CGPoint(x: rect.origin.x + rect.size.width/2.0, y: rect.origin.y + rect.size.height/2.0)
        
        //default start from -180 degree
        var angle:CGFloat = rotation ?? -CGFloat(M_PI / 2.0)
        let angleIncrement = CGFloat(M_PI * 2.0 / Double(points))
        let radius = rect.width / 2.0
        
        for index in 1...points {
            
            let point = pointFrom(angle: angle, radius: radius, center: center)
            let nextPoint = pointFrom(angle: angle + angleIncrement, radius: radius, center: center)
            let midPoint = pointFrom(angle: angle + angleIncrement / 2.0, radius: starExtrusion, center: center)
            
            if index == 1 {
                path.move(to: point)
            }
            
            path.addLine(to: midPoint)
            path.addLine(to: nextPoint)
            
            angle += angleIncrement
        }
        path.close()
        return path.cgPath
    }
    
    //Calculate a point from a given center, angle and radius
    private func pointFrom(angle: CGFloat, radius: CGFloat, center: CGPoint) -> CGPoint{
        let x = center.x + sin(angle)*radius
        let y = center.y + cos(angle)*radius
        return CGPoint(x: x, y: y)
    }

}//end class DrawBrain

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
