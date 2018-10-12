//
//  ViewController.swift
//  ImageLab
//
//  Created by Eric Larson
//  Copyright © 2016 Eric Larson. All rights reserved.
//

import UIKit
import AVFoundation

class FaceViewController: UIViewController   {

    //MARK: Class Properties
    var filters : [CIFilter]! = nil
    var videoManager:VideoAnalgesic! = nil
    let pinchFilterIndex = 2
    var detector:CIDetector! = nil
    let bridge = OpenCVBridgeFace()
    var filterFace = true // filter face or eyes
    
    //MARK: Outlets in view
    @IBOutlet weak var flashSlider: UISlider!
    @IBOutlet weak var smilingLabel: UILabel!
    
    //MARK: ViewController Hierarchy
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = nil
        self.setupFilters()
        
        self.bridge.loadHaarCascade(withFilename: "nose")
        
        self.videoManager = VideoAnalgesic.sharedInstance
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.front)
        
        // create dictionary for face detection
        // HINT: you need to manipulate these proerties for better face detection efficiency
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyLow,CIDetectorTracking:true] as [String : Any]
        
        // setup a face detector in swift
        self.detector = CIDetector(ofType: CIDetectorTypeFace,
                                  context: self.videoManager.getCIContext(), // perform on the GPU is possible
            options: (optsDetector as [String : AnyObject]))
        
        self.videoManager.setProcessingBlock(newProcessBlock: self.processImage)
        
        if !videoManager.isRunning{
            videoManager.start()
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.front)
        self.videoManager.setProcessingBlock(newProcessBlock: self.processImage)
        if !videoManager.isRunning{
            videoManager.start()
        }
    }
    
    //MARK: Process image output
    func processImage(inputImage:CIImage) -> CIImage{
        
        // detect faces
        let f = getFaces(img: inputImage)
        
        // if no faces, just return original image
        if f.count == 0 { return inputImage }
        
        var retImage = inputImage
        
        // if you just want to process on separate queue use this code
        // this is a NON BLOCKING CALL, but any changes to the image in OpenCV cannot be displayed real time
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
//            self.bridge.setImage(retImage, withBounds: retImage.extent, andContext: self.videoManager.getCIContext())
//            self.bridge.processImage()
//        }
        
        // use this code if you are using OpenCV and want to overwrite the displayed image via OpenCv
        // this is a BLOCKING CALL
//        self.bridge.setTransforms(self.videoManager.transform)
//        self.bridge.setImage(retImage, withBounds: retImage.extent, andContext: self.videoManager.getCIContext())
//        self.bridge.processImage()
//        retImage = self.bridge.getImage()
        
        //HINT: you can also send in the bounds of the face to ONLY process the face in OpenCV
        // or any bounds to only process a certain bounding region in OpenCV
//        self.bridge.setTransforms(self.videoManager.transform)
//        self.bridge.setImage(retImage,
//                             withBounds: f[0].bounds, // the first face bounds
//                             andContext: self.videoManager.getCIContext())
//
//        self.bridge.processImage()
//        retImage = self.bridge.getImageComposite() // get back opencv processed part of the image (overlayed on original)
//
        if self.filterFace {
            retImage = self.applyFiltersToFaces(inputImage: retImage, features: f);
        } else {
            retImage = self.applyFiltersToMouthAndEyes(inputImage: retImage, features: f);
        }
        
        return retImage
    }
    
    //MARK: Setup filtering
    func setupFilters(){
        filters = []
        
        let filterTwirl = CIFilter(name:"CITwirlDistortion")!
        filters.append(filterTwirl)
        
    }
    
    //MARK: Apply filters and apply feature detectors
    func applyFiltersToFaces(inputImage:CIImage,features:[CIFaceFeature])->CIImage{
        var retImage = inputImage
        var filterCenter = CGPoint()
        
        for f in features {
            //set where to apply filter
            filterCenter.x = f.bounds.midX
            filterCenter.y = f.bounds.midY
            
            //do for each filter (assumes all filters have property, "inputCenter")
            for filt in filters{
                filt.setValue(retImage, forKey: kCIInputImageKey)
                filt.setValue(CIVector(cgPoint: filterCenter), forKey: "inputCenter")
                filt.setValue(f.bounds.width/2, forKey: "inputRadius")
                
                // could also manipualte the radius of the filter based on face size!
                retImage = filt.outputImage!
            }
        }
        return retImage
    }
    
    func applyFiltersToMouthAndEyes(inputImage:CIImage,features:[CIFaceFeature])->CIImage{
        var retImage = inputImage
        let filterTwirlLeft = CIFilter(name:"CITwirlDistortion")!
        let filterTwirlRight = CIFilter(name:"CITwirlDistortion")!
        let filterMouth = CIFilter(name:"CIPinchDistortion")!
        
        for f in features {
            
            //do for each filter (assumes all filters have property, "inputCenter")
            
            if (f.hasLeftEyePosition) {
                filterTwirlLeft.setValue(retImage, forKey: kCIInputImageKey)
                filterTwirlLeft.setValue(CIVector(cgPoint: f.leftEyePosition), forKey: "inputCenter")
                filterTwirlLeft.setValue(f.bounds.width/8, forKey: "inputRadius")
            }
            
            retImage = filterTwirlLeft.outputImage!
            
            if (f.hasRightEyePosition) {
                filterTwirlRight.setValue(retImage, forKey: kCIInputImageKey)
                filterTwirlRight.setValue(CIVector(cgPoint: f.rightEyePosition), forKey: "inputCenter")
                filterTwirlRight.setValue(f.bounds.width/8, forKey: "inputRadius")
            }
            
            // could also manipualte the radius of the filter based on face size!
            retImage = filterTwirlRight.outputImage!
            
            if (f.hasMouthPosition) {
                filterMouth.setValue(retImage, forKey: kCIInputImageKey)
                filterMouth.setValue(CIVector(cgPoint: f.mouthPosition), forKey: "inputCenter")
                filterMouth.setValue(f.bounds.width/4, forKey: "inputRadius")
            }

            if (f.hasSmile) {
                DispatchQueue.main.async {
                    self.smilingLabel.text = "Smiling"
                }
            }
            else {
                DispatchQueue.main.async {
                    self.smilingLabel.text = "Not Smiling"
                }
            }
            
            retImage = filterMouth.outputImage!
            
        }
        return retImage
    }
    
    func getFaces(img:CIImage) -> [CIFaceFeature]{
        // this ungodly mess makes sure the image is the correct orientation
        //let optsFace = [CIDetectorImageOrientation:self.videoManager.getImageOrientationFromUIOrientation(UIApplication.sharedApplication().statusBarOrientation)]
        let optsFace = [CIDetectorImageOrientation:self.videoManager.ciOrientation]
        // get Face Features
        return self.detector.features(in: img, options: optsFace) as! [CIFaceFeature]
        
    }
    
    
    
    @IBAction func swipeRecognized(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.left:
            self.bridge.processType += 1
        case UISwipeGestureRecognizerDirection.right:
            self.bridge.processType -= 1
        default:
            break
            
        }
    }
    
    //MARK: Convenience Methods for UI Flash and Camera Toggle
    @IBAction func flash(_ sender: AnyObject) {
        if(self.videoManager.toggleFlash()){
            self.flashSlider.value = 1.0
        }
        else{
            self.flashSlider.value = 0.0
        }
    }
    
    @IBAction func switchCamera(_ sender: AnyObject) {
        self.videoManager.toggleCameraPosition()
    }
    
    @IBAction func setFlashLevel(sender: UISlider) {
        if(sender.value>0.0){
            self.videoManager.turnOnFlashwithLevel(sender.value)
        }
        else if(sender.value==0.0){
            self.videoManager.turnOffFlash()
        }
    }

    @IBAction func toggleFilter(_ sender: Any) {
        if self.filterFace {
            self.filterFace = false
        }
        else {
            self.filterFace = true
        }
    }
    
}

