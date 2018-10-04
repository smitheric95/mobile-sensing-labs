//
//  HeartViewController.swift
//  ImageLab
//
//  Created by Eric Smith on 10/3/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

import UIKit
import AVFoundation

class HeartViewController: UIViewController {
    
    var videoManager:VideoAnalgesic! = nil
    let bridge = OpenCVBridgeHeart()
    @IBOutlet weak var heartRateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.videoManager = VideoAnalgesic.sharedInstance
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.back)
        
        self.videoManager.setProcessingBlock(newProcessBlock: self.processImage)
//        self.videoManager.turnOnFlashwithLevel(1.0)
        
        if !videoManager.isRunning{
            videoManager.start()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.back)
        self.videoManager.setProcessingBlock(newProcessBlock: self.processImage)
        if !videoManager.isRunning{
            videoManager.start()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoManager.turnOffFlash()
    }
    
    //MARK: Process image output
    func processImage(inputImage:CIImage) -> CIImage{
        // TODO: try to move this to view will appear, idk why but it seems like it only gets called once there
        self.videoManager.turnOnFlashwithLevel(1.0)
        var retImage = inputImage
        self.bridge.setTransforms(self.videoManager.transform)
        self.bridge.setImage(retImage,
                             withBounds: retImage.extent, // the first face bounds
            andContext: self.videoManager.getCIContext())
        
        self.bridge.processImage()
        retImage = self.bridge.getImageComposite() // get back opencv processed part of the image (overlayed on original)
        
        DispatchQueue.main.async {
            self.heartRateLabel.text = String(self.bridge.heartRate)
        }
        
        return retImage
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
