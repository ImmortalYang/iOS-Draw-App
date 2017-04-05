//
//  ViewController.swift
//  DrawCircle
//
//  Created by ImmortalYang on 16/03/17.
//  Copyright © 2017 John Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //MARK: Properties and fields
    public let defaultColor: CGColor = UIColor.blue.cgColor //default fill color
    public let defaultStrokeColor = UIColor.black.cgColor
    public let defaultDrawShape: DrawShape = .Ellipse
    public let defaultLineWidth: CGFloat = 3.0
    public let defaultPointsOnStar = 5
    
    //Hold an instance of the model class
    private var drawEngine = DrawEngine()
    
    private var startPoint : CGPoint
    private var layer : CAShapeLayer?
    private var color: CGColor //fill color
    private var strokeColor: CGColor
    private var shape: DrawShape
    private var lineWidth: CGFloat
    //properties and fields to control star drawing
    private var _pointsOnStar: Int
    public var pointsOnStar: Int{
        get{
            return _pointsOnStar
        }
        set{
            _pointsOnStar = newValue
            lblPointsOnStar.text = "Points: \(newValue)"
        }
    }
    private var _extrusionOfStar: CGFloat?
    private var _rotationOfStarInRadians: CGFloat?
    public var rotationOfStarInDegree: CGFloat?{
        get{
            if let rotationInRadians = _rotationOfStarInRadians{
                return rotationInRadians * CGFloat(180 / M_PI)
            }else{
                return nil
            }
        }
        set{
            if let rotationInDegree = newValue{
                _rotationOfStarInRadians = rotationInDegree * CGFloat(M_PI / 180)
            }else{
                _rotationOfStarInRadians = nil
            }
        }
    }
    
    //The layer on which user will be drawing. Distinct from UI controls
    private var userDrawLayer = CALayer()
    
    @IBOutlet weak var btnEllipse: UIButton!
    @IBOutlet weak var btnRect: UIButton!
    @IBOutlet weak var btnCircle: UIButton!
    @IBOutlet weak var btnSquare: UIButton!
    @IBOutlet weak var btnStar: UIButton!
    @IBOutlet weak var btnLine: UIButton!
    @IBOutlet weak var btnFreeStyle: UIButton!
    @IBOutlet weak var stackShapes: UIStackView!
    @IBOutlet weak var stackColorPicks: UIStackView!
    @IBOutlet weak var stackFuncBtns: UIStackView!
    @IBOutlet weak var lineWidthControl: UIStackView!
    @IBOutlet weak var pointsOnStarControl: UIStackView!
    @IBOutlet weak var lblPointsOnStar: UILabel!
    
    //MARK: Methods
    required init?(coder aDecoder: NSCoder) {
        startPoint = CGPointFromString("0")
        color = defaultColor
        strokeColor = defaultStrokeColor
        shape = defaultDrawShape
        lineWidth = defaultLineWidth
        _pointsOnStar = defaultPointsOnStar
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        lineWidthControl.isHidden = true
        pointsOnStarControl.isHidden = true
        
        btnEllipse.setImage(#imageLiteral(resourceName: "Ellipse"), for: .normal)
        btnRect.setImage(#imageLiteral(resourceName: "Rectangle"), for: .normal)
        btnLine.setImage(#imageLiteral(resourceName: "Line"), for: .normal)
        btnCircle.setImage(#imageLiteral(resourceName: "Circle"), for: .normal)
        btnSquare.setImage(#imageLiteral(resourceName: "Square"), for: .normal)
        btnStar.setImage(#imageLiteral(resourceName: "Star"), for: .normal)
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
        color = (sender.backgroundColor?.cgColor) ?? defaultColor
        //Clear border width
        for btn in stackColorPicks.subviews{
            btn.layer.borderWidth = 0
        }
        //Set border width for current selected button
        sender.layer.borderWidth = defaultLineWidth
        
        //Change the tint color for selected shape button
        for btn in stackShapes.subviews{
            if btn.layer.borderWidth > 0{
                btn.tintColor = UIColor(cgColor: color)
                break
            }
        }
    }
    
    @IBAction func shapeChange(_ sender: UIButton) {
        //Tag value of each shape button is designed to be correspond to rawValue of each Shape in the enum
        shape = DrawShape(rawValue: sender.tag) ?? DrawShape.Ellipse
        //Hide line width control if not drawing lines
        if sender.tag == DrawShape.Line.rawValue ||
            sender.tag == DrawShape.FreeStyle.rawValue
        {
            lineWidthControl.isHidden = false
        }else{
            lineWidthControl.isHidden = true
        }
        //Hide points of star control if not drawing stars
        if sender.tag == DrawShape.Star.rawValue{
            pointsOnStarControl.isHidden = false
        }else{
            pointsOnStarControl.isHidden = true
        }
        //Clear tint color and border width
        for btn in stackShapes.subviews{
            btn.tintColor = UIColor.black
            btn.layer.borderWidth = 0.0
        }
        //Set tint color and border for selected shape button
        sender.tintColor = UIColor(cgColor: color)
        sender.layer.borderWidth = defaultLineWidth
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer)
    {
        if sender.state == .began
        {
            startPoint = sender.location(in: sender.view)
            layer = CAShapeLayer()
            layer?.fillColor = color
            layer?.strokeColor = color
            layer?.lineWidth = lineWidth
            userDrawLayer.addSublayer(layer!)
        }
        else if sender.state == .changed
        {
            let translation = sender .translation(in: sender.view)
            
            switch shape {
            case DrawShape.Ellipse, DrawShape.Rectangle:
                //The CGRect in which ellipses and rectangles will be drawn
                let shapeInRect: CGRect = CGRect(x: startPoint.x, y: startPoint.y, width: translation.x, height: translation.y)
                switch shape {
                case DrawShape.Ellipse:
                    layer?.path = drawEngine.ellipsePath(in: shapeInRect)
                default:  //DrawShape.Rectangle
                    layer?.path = drawEngine.rectanglePath(in: shapeInRect)
                }
            
            case DrawShape.Circle, DrawShape.Square, DrawShape.Star:
                //The CGRect in which Circles, Squares and Stars will be drawn. The side length of which is the shortest side of the above shapeInRect CGRect in the previous case.
                let x = abs(translation.x), y = abs(translation.y)
                let sideLength = x > y ? translation.y : translation.x
                let shapeInSquare: CGRect = CGRect(x: startPoint.x, y: startPoint.y, width: sideLength, height: sideLength)
                switch shape {
                case DrawShape.Circle:
                    layer?.path = drawEngine.ellipsePath(in: shapeInSquare)
                case DrawShape.Square:
                    layer?.path = drawEngine.rectanglePath(in: shapeInSquare)
                default: //DrawShape.Star
                    layer?.path = drawEngine.starPath(in: shapeInSquare, points: pointsOnStar, extrusion: _extrusionOfStar, rotation: _rotationOfStarInRadians)
                    //bring star control to front
                    self.view.bringSubview(toFront: pointsOnStarControl)
                }

            case DrawShape.Line, DrawShape.FreeStyle:
                let endPoint: CGPoint = CGPoint(x: startPoint.x + translation.x, y: startPoint.y + translation.y)
                switch shape {
                case DrawShape.Line:
                    layer?.path = drawEngine.straightLinePath(from: startPoint, to: endPoint)
                    
                default: //DrawShape.FreeStyle
                    layer?.path = drawEngine.freeStyleLinePath(from: startPoint, to: endPoint)
                }//end inner switch
                //bring line width control to front
                self.view.bringSubview(toFront: lineWidthControl)
            }//end switch
            //After drawing, bring UI buttons to the top layer
            //so that user input won't block buttons
            self.view.bringSubview(toFront: stackColorPicks)
            self.view.bringSubview(toFront: stackFuncBtns)
            self.view.bringSubview(toFront: stackShapes)

        }
        else if sender.state == .ended{
            drawEngine.reset()
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

    @IBAction func settingBtnTapped(_ sender: UIButton){
        
    }
    
    //User changed the line width
    @IBAction func lineWidthDidChange(_ sender: UISlider){
        lineWidth = CGFloat(sender.value)
    }
    
    //User changed points on star
    @IBAction func pointsOnStarDidChange(_ sender: UIStepper) {
        pointsOnStar = Int(sender.value)
    }
    
    //Closure for UI delete action
    private func deleteAllDrawings(action: UIAlertAction){
        userDrawLayer.removeFromSuperlayer()
        userDrawLayer = CALayer()
        self.view.layer.addSublayer(userDrawLayer)
    }
    
    //Give notification when saving image is finished.
    //This func is called by selector
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





