//
//  ViewController.swift
//  DrawCircle
//
//  Created by ImmortalYang on 16/03/17.
//  Copyright © 2017 John Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var startPoint : CGPoint = CGPointFromString("0")
    var layer : CAShapeLayer?
    let defaultColor: CGColor = UIColor.blue.cgColor
    let defaultStrokeColor = UIColor.black.cgColor
    let defaultDrawShape: DrawShape = .Eclipse
    let defaultLineWidth: CGFloat = 1.0
    var color: CGColor?
    var strokeColor: CGColor?
    var shape: DrawShape?
    var lineWidth: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        color = defaultColor
        strokeColor = defaultStrokeColor
        shape = defaultDrawShape
        lineWidth = defaultLineWidth
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func colorChange(_ sender: UIButton) {
        color = sender.backgroundColor?.cgColor
    }
    
    
    @IBAction func shapeChange(_ sender: UIButton) {
        let tag = sender.tag
        switch tag{
        case DrawShape.Eclipse.rawValue:
            shape = DrawShape.Eclipse
        case DrawShape.Rectangle.rawValue:
            shape = .Rectangle
        case DrawShape.Line.rawValue:
            shape = .Line
        default:
            shape = .Eclipse
        }
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer)
    {
        if sender.state == .began
        {
            startPoint = sender .location(in: sender.view)
            layer = CAShapeLayer()
            layer?.fillColor = color
            layer?.opacity = 0.5
            layer?.strokeColor = defaultStrokeColor
            layer?.lineWidth = defaultLineWidth
            self.view.layer.addSublayer(layer!)
        }
        else if sender.state == .changed
        {
            let translation = sender .translation(in: sender.view)
            let shapeInRect: CGRect = CGRect(x: startPoint.x, y: startPoint.y, width: translation.x, height: translation.y)
            
            switch shape! {
            case DrawShape.Eclipse:
                layer?.path = (UIBezierPath(ovalIn:shapeInRect)).cgPath
            case DrawShape.Rectangle:
                layer?.path =
                    (UIBezierPath(rect: shapeInRect)).cgPath
            case DrawShape.Line:
                let linePath = UIBezierPath()
                let endPoint: CGPoint = CGPoint(x: startPoint.x + translation.x, y: startPoint.y + translation.y)
                linePath.move(to: startPoint)
                linePath.addLine(to: endPoint)
                layer?.path = linePath.cgPath
                layer?.strokeColor = color
                layer?.lineWidth = lineWidth ?? defaultLineWidth
            }
            
        }
    }
        
}

enum DrawShape: Int
{
    case Eclipse = 0
    case Rectangle
    case Line
}



