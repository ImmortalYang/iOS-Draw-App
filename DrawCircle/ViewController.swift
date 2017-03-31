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
    let defaultLineWidth: CGFloat = 3.0

    var startPoint : CGPoint = CGPointFromString("0")
    var layer : CAShapeLayer?
    var color: CGColor?
    var strokeColor: CGColor?
    var shape: DrawShape?
    var lineWidth: CGFloat?
    
    var userDrawLayer = CALayer()
    var userIsDraggingInFreeStyleMode = false
    var freeStyleLinePath = UIBezierPath()
    
    @IBOutlet weak var btnEllipse: UIButton!
    @IBOutlet weak var btnRect: UIButton!
    @IBOutlet weak var btnLine: UIButton!
    @IBOutlet weak var btnFreeStyle: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var stackShapes: UIStackView!
    @IBOutlet weak var stackColorPicks: UIStackView!
    @IBOutlet weak var stackFuncBtns: UIStackView!
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
        btnEllipse.tintColor = UIColor(cgColor: defaultColor)
        
        //Set border color and width for shape-picker buttons
        for (index, btn) in stackShapes.subviews.enumerated(){
            btn.layer.borderColor = UIColor.black.cgColor
            if index == 0{
                btn.layer.borderWidth = defaultLineWidth
            }
            else{
                btn.layer.borderWidth = 0.0
            }
        }
        
        //Set border color and width for color-picker buttons
        for (index, btn) in stackColorPicks.subviews.enumerated(){
            btn.layer.borderColor = UIColor.black.cgColor
            if index == 0{
                btn.layer.borderWidth = defaultLineWidth
            }
            else{
                btn.layer.borderWidth = 0.0
            }
            
        }
        
        self.view.layer.addSublayer(userDrawLayer)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func colorChange(_ sender: UIButton) {
        color = sender.backgroundColor?.cgColor
        //Clear border width
        for btn in stackColorPicks.subviews{
            btn.layer.borderWidth = 0
        }
        //Set border width for current selected button
        sender.layer.borderWidth = defaultLineWidth
        
        //Change the tint color of selected shape-pick button
        for btn in stackShapes.subviews{
            if btn.layer.borderWidth > 0{
                btn.tintColor = UIColor(cgColor: color!)
                break
            }
        }
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
        //Clear tint color and border width
        for btn in stackShapes.subviews{
            btn.tintColor = UIColor.black
            btn.layer.borderWidth = 0.0
        }
        //Set tint color and border for selected shape button
        sender.tintColor = UIColor(cgColor: color!)
        sender.layer.borderWidth = defaultLineWidth
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer)
    {
        if sender.state == .began
        {
            startPoint = sender .location(in: sender.view)
            layer = CAShapeLayer()
            layer?.fillColor = color
            layer?.opacity = 0.5
            layer?.strokeColor = color
            layer?.lineWidth = defaultLineWidth
            //self.view.layer.addSublayer(layer!)
            userDrawLayer.addSublayer(layer!)
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
                
            case DrawShape.FreeStyle:
                let endPoint: CGPoint = CGPoint(x: startPoint.x + translation.x, y: startPoint.y + translation.y)
                if !userIsDraggingInFreeStyleMode{
                    //Add the first line in free style path
                    freeStyleLinePath = UIBezierPath()
                    freeStyleLinePath.move(to: startPoint)
                    freeStyleLinePath.addLine(to: endPoint)
                    userIsDraggingInFreeStyleMode = true
                    
                }
                else{
                    freeStyleLinePath.addLine(to: endPoint)
                }
                //The end point of current segment of line is the start point of next segment of line
                freeStyleLinePath.move(to: endPoint)
                layer?.path = freeStyleLinePath.cgPath
                
            }//end switch
            //After drawing, bring UI buttons to the top layer
            //so that user input won't block buttons
            self.view.bringSubview(toFront: stackColorPicks)
            self.view.bringSubview(toFront: stackFuncBtns)
        }
        else if sender.state == .ended{
            userIsDraggingInFreeStyleMode = false
            
        }//end if...else
    }//end func handlePan
    
    //User touch the delete button
    @IBAction func deleteBtnTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Warning", message: "All Drawings & Stickers will be deleted", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete All", style: .default, handler: deleteAllDrawings)
        alertController.addAction(deleteAction)
        
        let cancellAction = UIAlertAction(title: "Cancell", style: .default, handler: nil)
        alertController.addAction(cancellAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    private func deleteAllDrawings(action: UIAlertAction){
        userDrawLayer.removeFromSuperlayer()
        userDrawLayer = CALayer()
        self.view.layer.addSublayer(userDrawLayer)
    }
    
}//end class ViewController

//Possible shapes that users can choose from
enum DrawShape: Int
{
    case Ellipse = 0
    case Rectangle
    case Line      //straight line
    case FreeStyle //exact path of user's touch
}



