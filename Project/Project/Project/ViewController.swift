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
    var shouldUploadCode = false  // flag for triggering code upload
    private let urlHandler = UrlHandler()
    private let codeModel = PythonCodeModel()
    
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
        
        let result = observations.map({$0 as? VNTextObservation})
        
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

            // upload code
            if self.shouldUploadCode {
                self.shouldUploadCode = false
                DispatchQueue.global(qos: .userInitiated).async {
                    let lines = self.parseWords(result as! [VNTextObservation])
    //                print(lines)

                    let codeString = self.buildCodeWithModel(lines)
                    
                    self.sendCodeToServer(codeString)
                }
            }
        }
        
        
    }
    
    @IBAction func uploadCode(_ sender: Any) {
        self.shouldUploadCode = true
    }
    
    func buildCodeWithModel(_ lines: [Int: [Any]]) -> String {
        var result = ""
        // TODO: eval each image
        for i in 0..<lines.count {
            for j in 0..<lines[i]!.count {
                if (lines[i]![j] as! String) == "Space" {
                    result += " "
                }
                else {
                    let img = lines[i]![j] as! UIImage
                    result += (try! self.codeModel.prediction(img: (img).pixelBuffer(width: Int(img.size.width), height: Int(img.size.height))!)).classLabel
                }
            }
        }
        return result
    }
    
    func sendCodeToServer(_ codeString: String) {
        // TODO: pass in UILabel to update with prediction
        self.urlHandler.getPrediction(codeString, outputLabel: nil)
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
    
    
    func parseWords(_ regions: [VNTextObservation]) -> [Int : [Any]] {
        var lines = [Int : [Any]]()
        
        var lineNumber = 0
        let threshold = CGFloat(0.05)
        
        for i in 0..<regions.count {
            if let boxes = regions[i].characterBoxes {
                
                // draw rectangle for chars
                for j in 0..<boxes.count {
                    let characterBox = boxes[j]
                    
                    let rotatedImage = imageView.image!.imageRotatedByDegrees(degrees: 90)
                    let xCord = characterBox.topLeft.x * rotatedImage.size.width
                    let yCord = (1 - characterBox.topLeft.y) * rotatedImage.size.height
                    let width = (characterBox.topRight.x - characterBox.bottomLeft.x) * rotatedImage.size.width
                    let height = (characterBox.topLeft.y - characterBox.bottomLeft.y + 0.02) * rotatedImage.size.height
                    
                    // crop the image and append to lines
                    let croppedImage = self.crop(image: rotatedImage, rect: CGRect(x: xCord, y: yCord, width: width, height: height))
                    
                    if lines[lineNumber] != nil {
                        lines[lineNumber]!.append(croppedImage!)
                    }
                    else {
                        lines[lineNumber] = [croppedImage!]
                    }
                    
                    // handle next box
                    if j < boxes.count-1 {
                        let nextBox = boxes[j+1]
                        
                        // add space if the next character is far enough away
                        if nextBox.bottomLeft.x - characterBox.bottomRight.x > threshold {
                            lines[lineNumber]!.append("Space")
                        }
                        
                    }
                    // handle next region
                    else if i < regions.count-1 {
                        // always add space at end of region
                        lines[lineNumber]!.append("Space")
                        
                        // add a space if it's on the same line but far enough away
                        if regions[i+1].characterBoxes![0].bottomLeft.y - characterBox.bottomLeft.y < threshold
                            && regions[i+1].characterBoxes![0].bottomLeft.x - characterBox.bottomRight.x > threshold {
                            lines[lineNumber]!.append("Space")
                        }
                        // increment line number if far enough down
                        else if characterBox.bottomLeft.y - regions[i+1].characterBoxes![0].bottomLeft.y > threshold {
                            lineNumber += 1
                        }
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
        let height = (minY - maxY + 0.02) * imageView.frame.size.height
        
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
                let height = (characterBox.topLeft.y - characterBox.bottomLeft.y + 0.02) * imageView.frame.size.height
                
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
                    let height = (box_i.topRight.y - box_i.bottomRight.y + 0.02) * imageView.frame.size.height // height based off left character
                    
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
    
    // source: https://stackoverflow.com/a/44727608
    private func getImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) ->UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        guard let cgImage = context.makeImage() else {
            return nil
        }
        let image = UIImage(cgImage: cgImage, scale: 1, orientation:.up)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        return image
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
        
        // set imageView image to output of camera
        guard let outputImage = getImageFromSampleBuffer(sampleBuffer: sampleBuffer) else {
            return
        }
        
        DispatchQueue.main.async() {
            self.imageView.image = outputImage
        }
    }
    
}

extension UIImage {
    // source: https://stackoverflow.com/a/44148427
    public func imageRotatedByDegrees(degrees: CGFloat) -> UIImage {
        //Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat.pi / 180))
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

    public func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        return pixelBuffer(width: width, height: height,
                           pixelFormatType: kCVPixelFormatType_32ARGB,
                           colorSpace: CGColorSpaceCreateDeviceRGB(),
                           alphaInfo: .noneSkipFirst)
    }
    
    func pixelBuffer(width: Int, height: Int, pixelFormatType: OSType,
                     colorSpace: CGColorSpace, alphaInfo: CGImageAlphaInfo) -> CVPixelBuffer? {
        var maybePixelBuffer: CVPixelBuffer?
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         pixelFormatType,
                                         attrs as CFDictionary,
                                         &maybePixelBuffer)
        
        guard status == kCVReturnSuccess, let pixelBuffer = maybePixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
        
        guard let context = CGContext(data: pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                      space: colorSpace,
                                      bitmapInfo: alphaInfo.rawValue)
            else {
                return nil
        }
        
        UIGraphicsPushContext(context)
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer
    }
}
