//
//  ViewController.swift
//  Lab6
//
//  Source: https://medium.com/flawless-app-stories/vision-in-ios-text-detection-and-tesseract-recognition-26bbcd735d8f
//
//  Created by Eric Smith on 11/3/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

import UIKit
import Anchors
import AVFoundation
import Vision

class ViewController: UIViewController {
    
    private let cameraController = CameraViewController()
    private let visionService = VisionService()
    private let boxService = BoxService()
    private let urlHandler = UrlHandler()
    @IBOutlet weak var uploadEvalSegmentedControl: UISegmentedControl!
    
    // TODO: set label based off returned text
//    private lazy var label: UILabel = {
//        let label = UILabel()
//        label.text = String("Ian is cool")
//        label.textAlignment = .right
//        label.font = UIFont.preferredFont(forTextStyle: .headline)
//        label.textColor = .black
//        return label
//    }()
    
    private lazy var labelInput: UITextField = {
        let labelInput = UITextField()
        labelInput.text = String("Label")
        labelInput.textAlignment = .right
        labelInput.font = UIFont.preferredFont(forTextStyle: .headline)
        labelInput.textColor = .black
        return labelInput
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraController.delegate = self
        add(childController: cameraController)
        activate(
            cameraController.view.anchor.edges
        )
        
//        view.addSubview(label)
//        activate(label.anchor.bottom.right.constant(0))
        
        view.addSubview(labelInput)
        activate(labelInput.anchor.bottom)
        
        visionService.delegate = self
        boxService.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.labelInput.resignFirstResponder()
    }
}

extension ViewController: CameraControllerDelegate {
    func cameraController(_ controller: CameraViewController, didCapture buffer: CMSampleBuffer) {
        visionService.handle(buffer: buffer)
    }
}

extension ViewController: VisionServiceDelegate {
    func visionService(_ version: VisionService, didDetect image: UIImage, results: [VNTextObservation]) {
        boxService.handle(
            cameraLayer: cameraController.cameraLayer,
            image: image,
            results: results,
            on: cameraController.view
        )
    }
}

extension ViewController: BoxServiceDelegate {
    func boxService(_ service: BoxService, didDetect images: [UIImage]) {
        guard let biggestImage = images.sorted(by: {
            $0.size.width > $1.size.width && $0.size.height > $1.size.height
        }).first else {
            return
        }
        
        // TODO: push biggest image to server
        // TODO: check if delegate says to upload or eval image
        switch self.uploadEvalSegmentedControl.selectedSegmentIndex {
        case 0:
            urlHandler.uploadLabeledImage(biggestImage, label: self.labelInput.text!)
            break;
        case 1:
            urlHandler.getPrediction(biggestImage)
        case 2:
            // TODO: run prediction locally
            break;
        default:
            urlHandler.getPrediction(biggestImage)
        }
    }
}

