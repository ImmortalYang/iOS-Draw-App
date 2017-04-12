//
//  SettingsViewController.swift
//  DrawCircle
//
//  Created by ImmortalYang on 12/04/17.
//  Copyright © 2017 John Zhang. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    //MARK: Properties
    private var _mainVC: ViewController?
    public var mainVC: ViewController?{
        get{
            return _mainVC
        }
        set{
            _mainVC = newValue
            _lineWidth = newValue?.lineWidth
            _pointsOnStar = newValue?.pointsOnStar
            _rotation = newValue?.rotationOfStarInDegree
            _extrusion = newValue?.extrusion
            
        }
    }
    private var _lineWidth: CGFloat?
    private var _pointsOnStar: Int?
    private var _rotation: CGFloat?
    private var _extrusion: CGFloat?

    @IBOutlet weak var lineWidthControl: UISlider!
    @IBOutlet weak var pointsOnStarControl: UIStepper!
    @IBOutlet weak var rotationControl: UISlider!
    @IBOutlet weak var extrusionControl: UISlider!
    @IBOutlet weak var lblLineWidth: UILabel!
    @IBOutlet weak var lblPointsOfStar: UILabel!
    @IBOutlet weak var lblRotation: UILabel!
    @IBOutlet weak var lblExtrusion: UILabel!
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
        lblLineWidth.text = String(format: "%.2f", _lineWidth!)
        lblPointsOfStar.text = String(format: "%d", _pointsOnStar!)
        lblRotation.text = String(format: "%.2f", _rotation!)
        lblExtrusion.text = String(format: "%.2f", _extrusion!)
        lineWidthControl.value = Float(_lineWidth!)
        pointsOnStarControl.value = Double(_pointsOnStar!)
        rotationControl.value = Float(_rotation!)
        extrusionControl.value = Float(_extrusion!)
        self.showAnimate()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func lineWidthDidChange(_ sender: UISlider) {
        self._lineWidth = CGFloat(sender.value)
        lblLineWidth.text = String(format: "%.2f", _lineWidth!)
    }
    
    @IBAction func pointsOnStarDidChange(_ sender: UIStepper) {
        self._pointsOnStar = Int(sender.value)
        lblPointsOfStar.text = String(format: "%d", _pointsOnStar!)
    }
    
    @IBAction func rotationDidChange(_ sender: UISlider){
        self._rotation = CGFloat(sender.value)
        lblRotation.text = String(format: "%.2f", _rotation!)
    }
    
    @IBAction func extrusionDidChange(_ sender: UISlider) {
        self._extrusion = CGFloat(sender.value)
        lblExtrusion.text = String(format: "%.2f", _extrusion!)
    }
    
    //User tap save button
    @IBAction func saveSettingAndClose(_ sender: UIButton) {
        mainVC?.lineWidth = _lineWidth!
        mainVC?.pointsOnStar = _pointsOnStar!
        mainVC?.rotationOfStarInDegree = _rotation!
        mainVC?.extrusion = _extrusion!
        
        self.removeAnimate()
    }
    
    //User close the pop up controller
    @IBAction func closeSettingsMenu(_ sender: UIButton) {
        self.removeAnimate()
    }
    
    //Pop up animation
    //This method is referenced from: https://github.com/awseeley/Swift-Pop-Up-View-Tutorial/blob/master/PopUp/PopUpViewController.swift
    //The owner granted copyright from this video: https://www.youtube.com/watch?v=FgCIRMz_3dE
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    //Fade out animation
    //This method is referenced from: https://github.com/awseeley/Swift-Pop-Up-View-Tutorial/blob/master/PopUp/PopUpViewController.swift
    //The owner granted copyright from this video: https://www.youtube.com/watch?v=FgCIRMz_3dE
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        });
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
