//
//  ViewController.swift
//  DrawCircle
//
//  Created by ImmortalYang on 16/03/17.
//  Copyright © 2017 John Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //MARK: Properties
    let defaultColor: CGColor = UIColor.blue.cgColor //default fill color
    let defaultStrokeColor = UIColor.black.cgColor
    let defaultDrawShape: DrawShape = .Ellipse
    let defaultLineWidth: CGFloat = 1.0

    var startPoint : CGPoint = CGPointFromString("0")
    var layer : CAShapeLayer?
    var color: CGColor?
    var strokeColor: CGColor?
    var shape: DrawShape?
    var lineWidth: CGFloat?
    
    @IBOutlet weak var btnEllipse: UIButton!
    @IBOutlet weak var btnRect: UIButton!
    @IBOutlet weak var btnLine: UIButton!
    @IBOutlet weak var btnFreeStyle: UIButton!
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        color = defaultColor
        strokeColor = defaultStrokeColor
        shape = defaultDrawShape
        lineWidth = defaultLineWidth
        btnEllipse.setImage(#imageLiteral(resourceName: "Ellipse"), for: .normal)
        btnRect.setImage(#imageLiteral(resourceName: "Rectangle"), for: .normal)
        btnLine.setImage(#imageLiteral(resourceName: "Line"), for: .normal)
        btnFreeStyle.setImage(#imageLiteral(resourceName: "FreeStyle"), for: .normal)
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
        case DrawShape.Ellipse.rawValue:
            shape = DrawShape.Ellipse
        case DrawShape.Rectangle.rawValue:
            shape = .Rectangle
        case DrawShape.Line.rawValue:
            shape = .Line
        case DrawShape.FreeStyle.rawValue:
            shape = .FreeStyle
        default:
            shape = .Ellipse
        }
        sender.tintColor = UIColor.blue
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
            case DrawShape.Ellipse:
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
            case DrawShape.FreeStyle:
                break;
            }
            
        }
    }
        
}

enum DrawShape: Int
{
    case Ellipse = 0
    case Rectangle
    case Line
    case FreeStyle
}



