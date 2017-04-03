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
    
    //The layer on which user will be drawing. Distinct from UI controls
    var userDrawLayer = CALayer()
    //Set a state and path for storing free style line
    var userIsDraggingInFreeStyleMode = false
    var freeStyleLinePath = UIBezierPath()
    
    @IBOutlet weak var btnEllipse: UIButton!
    @IBOutlet weak var btnRect: UIButton!
    @IBOutlet weak var btnCircle: UIButton!
    @IBOutlet weak var btnSquare: UIButton!
    @IBOutlet weak var btnLine: UIButton!
    @IBOutlet weak var btnFreeStyle: UIButton!
    @IBOutlet weak var stackShapes: UIStackView!
    @IBOutlet weak var stackColorPicks: UIStackView!
    @IBOutlet weak var stackFuncBtns: UIStackView!
    @IBOutlet weak var lineWidthControl: UIStackView!
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        color = defaultColor
        strokeColor = defaultStrokeColor
        shape = defaultDrawShape
        lineWidth = defaultLineWidth
        
        lineWidthControl.isHidden = true
        
        btnEllipse.setImage(#imageLiteral(resourceName: "Ellipse"), for: .normal)
        btnRect.setImage(#imageLiteral(resourceName: "Rectangle"), for: .normal)
        btnLine.setImage(#imageLiteral(resourceName: "Line"), for: .normal)
        btnCircle.setImage(#imageLiteral(resourceName: "Circle"), for: .normal)
        btnSquare.setImage(#imageLiteral(resourceName: "Square"), for: .normal)
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
        
        //Change the tint color for selected shape button
        for btn in stackShapes.subviews{
            if btn.layer.borderWidth > 0{
                btn.tintColor = UIColor(cgColor: color!)
                break
            }
        }
    }
    
    @IBAction func shapeChange(_ sender: UIButton) {
        //Tag value of each shape button is designed to be correspond to rawValue of each Shape in the enum
        shape = DrawShape(rawValue: sender.tag)
        //Hide line width control if not drawing lines
        if sender.tag == DrawShape.Line.rawValue ||
            sender.tag == DrawShape.FreeStyle.rawValue
        {
            lineWidthControl.isHidden = false
        }else{
            lineWidthControl.isHidden = true
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
            layer?.lineWidth = lineWidth!
            userDrawLayer.addSublayer(layer!)
        }
        else if sender.state == .changed
        {
            let translation = sender .translation(in: sender.view)
            
            switch shape! {
            case DrawShape.Ellipse, DrawShape.Rectangle:
                //The CGRect in which ellipses and rectangles will be drawn
                let shapeInRect: CGRect = CGRect(x: startPoint.x, y: startPoint.y, width: translation.x, height: translation.y)
                switch shape! {
                case DrawShape.Ellipse:
                    layer?.path = (UIBezierPath(ovalIn:shapeInRect)).cgPath
                default:  //DrawShape.Rectangle
                    layer?.path =
                        (UIBezierPath(rect: shapeInRect)).cgPath
                }
            
            case DrawShape.Circle, DrawShape.Square:
                //The CGRect in which Circles and Squares will be drawn. The side length of which is the shortest side of the above shapeInRect CGRect in the previous case.
                let x = abs(translation.x), y = abs(translation.y)
                let sideLength = x > y ? translation.y : translation.x
                let shapeInSquare: CGRect = CGRect(x: startPoint.x, y: startPoint.y, width: sideLength, height: sideLength)
                switch shape! {
                case DrawShape.Circle:
                    layer?.path = (UIBezierPath(ovalIn: shapeInSquare)).cgPath
                default: //DrawShape.Square
                    layer?.path = (UIBezierPath(rect: shapeInSquare)).cgPath
                }

            case DrawShape.Line, DrawShape.FreeStyle:
                let endPoint: CGPoint = CGPoint(x: startPoint.x + translation.x, y: startPoint.y + translation.y)
                switch shape! {
                case DrawShape.Line:
                    let linePath = UIBezierPath()
                    linePath.move(to: startPoint)
                    linePath.addLine(to: endPoint)
                    layer?.path = linePath.cgPath
                    
                default: //DrawShape.FreeStyle
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
                    //end case DrawShape.FreeStyle
                }//end inner switch
            
            }//end switch
            //After drawing, bring UI buttons to the top layer
            //so that user input won't block buttons
            self.view.bringSubview(toFront: stackColorPicks)
            self.view.bringSubview(toFront: stackFuncBtns)
            self.view.bringSubview(toFront: stackShapes)
            //If user is drawing line or free style then bring line control to front as well
            if let shapeValue = shape?.rawValue
            {
                if shapeValue == DrawShape.Line.rawValue || shapeValue == DrawShape.FreeStyle.rawValue
                {
                    self.view.bringSubview(toFront: lineWidthControl)
                }
            }
        }
        else if sender.state == .ended{
            userIsDraggingInFreeStyleMode = false
        }//end if...else
    }//end func handlePan
    
    //User touch the delete button
    @IBAction func deleteBtnTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Warning", message: "All Drawings & Stickers will be deleted", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete All", style: .destructive, handler: deleteAllDrawings)
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func UndoBtnTapped(_ sender: UIButton) {
        if let howManyLayers = userDrawLayer.sublayers?.count
        {
            userDrawLayer.sublayers![howManyLayers - 1].removeFromSuperlayer()
        }
    }
    
    @IBAction func saveBtnTapped(_ sender: UIButton) {
        let img = UIImage(layer: userDrawLayer)
        UIImageWriteToSavedPhotosAlbum(
            img,
            self,
            #selector(notifyWhenWritingImageFinished(image:didFinishSavingWithError:contextInfo:)),
            nil)
    }

    @IBAction func lineWidthDidChange(_ sender: UISlider){
        lineWidth = CGFloat(sender.value)
    }
    
    //Closure for UI delete action
    private func deleteAllDrawings(action: UIAlertAction){
        userDrawLayer.removeFromSuperlayer()
        userDrawLayer = CALayer()
        self.view.layer.addSublayer(userDrawLayer)
    }
    
    @objc private func notifyWhenWritingImageFinished(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeRawPointer)
    {
        if error == nil{
            let alertController = UIAlertController(title: "Success", message: "Image saved to photo album.", preferredStyle: .alert)
        
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
        else{
            let alertController = UIAlertController(title: "Fail", message: "Failed to save the image.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
}//end class ViewController





