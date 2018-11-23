//
//  ViewController.swift
//  Project
//
//  Created by Eric Smith on 11/18/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController {
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    var session = AVCaptureSession()
    var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uploadButton.layer.cornerRadius = 2;
        uploadButton.layer.borderWidth = 2;
        uploadButton.layer.borderColor = UIColor.yellow.cgColor
        uploadButton.setTitleColor(UIColor.yellow, for: .normal)
        uploadButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        startLiveVideo()
        startTextDetection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startLiveVideo() {
        //1
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        //2
        guard
            let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let deviceInput = try? AVCaptureDeviceInput(device: frontCamera)
            else {
                return
        }
        
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        //3
        let imageLayer = AVCaptureVideoPreviewLayer(session: session)
        imageLayer.frame = imageView.bounds
        imageView.layer.addSublayer(imageLayer)
        
        session.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        imageView.layer.sublayers?[0].frame = imageView.bounds
    }
    
    func startTextDetection() {
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.detectTextHandler)
        textRequest.reportCharacterBoxes = true
        self.requests = [textRequest]
    }
    
    func detectTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results else {
            print("no result")
            return
        }
        
        var result = observations.map({$0 as? VNTextObservation})
        
        DispatchQueue.main.async() {
            self.imageView.layer.sublayers?.removeSubrange(1...)
            
            // highlight space between regions
            if result.count > 0 {
                self.highlightRegions(result as! [VNTextObservation])
            }
            
            for region in result {
                guard let rg = region else {
                    continue
                }
                
                self.highlightWord(box: rg)
                
            }
        }
        
        
    }
    
    // highlight whitespace between regions
    func highlightRegions(_ regions: [VNTextObservation]){
        for i in 0..<regions.count-1 {
            let box_i = regions[i].characterBoxes?[ (regions[i].characterBoxes?.count)! - 1 ]
            let box_j = regions[i+1].characterBoxes?[0]
            
            let threshold = CGFloat(0.05)
            if box_j!.bottomLeft.x - box_i!.bottomRight.x > threshold {
                let xCord = box_i!.topRight.x * imageView.frame.size.width
                let yCord = (1 - box_i!.topRight.y) * imageView.frame.size.height
                let width = (box_j!.topLeft.x - box_i!.bottomRight.x) * imageView.frame.size.width
                let height = (box_i!.topRight.y - box_i!.bottomRight.y) * imageView.frame.size.height // height based off left character
                
                // add green box over space
                let outline = CALayer()
                outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
                outline.borderWidth = 1.0
                outline.borderColor = UIColor.green.cgColor
                
                imageView.layer.addSublayer(outline)
            }
        }
    }
    
    
    func parseWords(box: VNTextObservation) -> [Int : [Any]] {
        var lines = [Int : [Any]]()
        
        if let boxes = box.characterBoxes {
            var lineNumber = 1
            let threshold = CGFloat(0.05)
            
            // draw rectangle for chars
            for i in 0..<boxes.count {
                let characterBox = boxes[i]
                let xCord = characterBox.topLeft.x * imageView.frame.size.width
                let yCord = (1 - characterBox.topLeft.y) * imageView.frame.size.height
                let width = (characterBox.topRight.x - characterBox.bottomLeft.x) * imageView.frame.size.width
                let height = (characterBox.topLeft.y - characterBox.bottomLeft.y + 0.01) * imageView.frame.size.height
                
                // crop the image and append to lines
                let croppedImage = self.crop(image: imageView.image!, rect: CGRect(x: xCord, y: yCord, width: width, height: height))
                lines[lineNumber]!.append(croppedImage!)
                
                // handle next box
                if i < boxes.count-1 {
                    let nextBox = boxes[i+1]
                    
                    // add space if the next character is far enough away
                    if nextBox.bottomLeft.x - characterBox.bottomRight.x > threshold {
                        lines[lineNumber]!.append("Space")
                    }
                    
                    // increment line number if far enough down
                    if nextBox.topLeft.y - characterBox.bottomLeft.y > threshold {
                        lineNumber += 1
                    }
                }
            }
        }
        
        return lines
    }
    
    func highlightWord(box: VNTextObservation) {
        guard let boxes = box.characterBoxes else {
            return
        }
        
        var maxX: CGFloat = 9999.0
        var minX: CGFloat = 0.0
        var maxY: CGFloat = 9999.0
        var minY: CGFloat = 0.0
        
        // find edges of all the words
        for char in boxes {
            if char.bottomLeft.x < maxX {
                maxX = char.bottomLeft.x
            }
            if char.bottomRight.x > minX {
                minX = char.bottomRight.x
            }
            if char.bottomRight.y < maxY {
                maxY = char.bottomRight.y
            }
            if char.topRight.y > minY {
                minY = char.topRight.y
            }
        }
        
        // draw rectangle for words
        let xCord = maxX * imageView.frame.size.width
        let yCord = (1 - minY) * imageView.frame.size.height
        let width = (minX - maxX) * imageView.frame.size.width
        let height = (minY - maxY + 0.01) * imageView.frame.size.height
        
        let outline = CALayer()
        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
        outline.borderWidth = 2.0
        outline.borderColor = UIColor.red.cgColor
        
        imageView.layer.addSublayer(outline)
        
        
        if let boxes = box.characterBoxes {
            // draw rectangle for chars
            for characterBox in boxes {
                let xCord = characterBox.topLeft.x * imageView.frame.size.width
                let yCord = (1 - characterBox.topLeft.y) * imageView.frame.size.height
                let width = (characterBox.topRight.x - characterBox.bottomLeft.x) * imageView.frame.size.width
                let height = (characterBox.topLeft.y - characterBox.bottomLeft.y + 0.01) * imageView.frame.size.height
                
                let outline = CALayer()
                outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
                outline.borderWidth = 1.0
                outline.borderColor = UIColor.blue.cgColor
                
                imageView.layer.addSublayer(outline)
            }
            
            // draw boxes for spaces
            let threshold = CGFloat(0.05)
            for i in 0..<boxes.count-1 {
                let box_i = boxes[i]
                let box_j = boxes[i+1]
                
                // if boxes are far enough apart
                if box_j.bottomLeft.x - box_i.bottomRight.x > threshold {
                    let xCord = box_i.topRight.x * imageView.frame.size.width
                    let yCord = (1 - box_i.topRight.y) * imageView.frame.size.height
                    let width = (box_j.topLeft.x - box_i.bottomRight.x) * imageView.frame.size.width
                    let height = (box_i.topRight.y - box_i.bottomRight.y) * imageView.frame.size.height // height based off left character
                    
                    // add green box over space
                    let outline = CALayer()
                    outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
                    outline.borderWidth = 1.0
                    outline.borderColor = UIColor.green.cgColor
                    
                    imageView.layer.addSublayer(outline)
                }
            }
        }
    }
    
    func highlightLetters(box: VNRectangleObservation) {
        let xCord = box.topLeft.x * imageView.frame.size.width
        let yCord = (1 - box.topLeft.y) * imageView.frame.size.height
        let width = (box.topRight.x - box.bottomLeft.x) * imageView.frame.size.width
        let height = (box.topLeft.y - box.bottomLeft.y) * imageView.frame.size.height
        
        let outline = CALayer()
        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
        outline.borderWidth = 1.0
        outline.borderColor = UIColor.blue.cgColor
        
        imageView.layer.addSublayer(outline)
    }
    
    private func crop(image: UIImage, rect: CGRect) -> UIImage? {
        guard let cropped = image.cgImage?.cropping(to: rect) else {
            return nil
        }
        
        return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
    }
    
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics:camData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
}
