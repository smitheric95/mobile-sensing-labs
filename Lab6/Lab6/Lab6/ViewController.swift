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


let buttonBar = UIView()

class Responder: NSObject {
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        UIView.animate(withDuration: 0.3) {
            buttonBar.frame.origin.x = (sender.frame.width / CGFloat(sender.numberOfSegments)) * CGFloat(sender.selectedSegmentIndex)
        }
    }

}

class ViewController: UIViewController {
    
    private let cameraController = CameraViewController()
    private let visionService = VisionService()
    private let boxService = BoxService()
    private let urlHandler = UrlHandler()
    private let responder = Responder()
    
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
        labelInput.font = UIFont.preferredFont(forTextStyle: .headline).withSize(30)
        labelInput.textColor = .white
        labelInput.backgroundColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.6)
        labelInput.textAlignment = .center
        labelInput.returnKeyType = .go
        labelInput.addTarget(nil, action:"firstResponderAction:", for:.editingDidEndOnExit)
        
        return labelInput
    }()
    
    private lazy var uploadEvalSegmentedControl: UISegmentedControl = {
        let uploadEvalSegmentedControl = UISegmentedControl()
        uploadEvalSegmentedControl.insertSegment(withTitle: "Upload", at: 0, animated: true)
        uploadEvalSegmentedControl.insertSegment(withTitle: "Evaluate", at: 1, animated: true)
        uploadEvalSegmentedControl.insertSegment(withTitle: "Local", at: 2, animated: true)
        uploadEvalSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        uploadEvalSegmentedControl.selectedSegmentIndex = 0
        
        uploadEvalSegmentedControl.backgroundColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.6)
        uploadEvalSegmentedControl.tintColor = .clear
        
        uploadEvalSegmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 25.0),
            NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ], for: .normal)
        
        uploadEvalSegmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 25.0),
            NSAttributedString.Key.foregroundColor: UIColor.white
            ], for: .selected)
        
        return uploadEvalSegmentedControl
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraController.delegate = self
        add(childController: cameraController)
        activate(
            cameraController.view.anchor.edges
        )
        
        view.addSubview(labelInput)
        activate(labelInput.anchor.centerY, labelInput.anchor.centerX, labelInput.anchor.width.equal.to(120))
        
        view.addSubview(uploadEvalSegmentedControl)
        
        // constraints for segmented control
        uploadEvalSegmentedControl.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        uploadEvalSegmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        uploadEvalSegmentedControl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // button bar
        buttonBar.translatesAutoresizingMaskIntoConstraints = false
        buttonBar.backgroundColor = UIColor(red:0.20, green:0.48, blue:0.96, alpha:1.0)
        view.addSubview(buttonBar)
        
        // constraints for button bar
        buttonBar.topAnchor.constraint(equalTo: uploadEvalSegmentedControl.bottomAnchor).isActive = true
        buttonBar.heightAnchor.constraint(equalToConstant: 5).isActive = true
        buttonBar.leftAnchor.constraint(equalTo: uploadEvalSegmentedControl.leftAnchor).isActive = true
        buttonBar.widthAnchor.constraint(equalTo: uploadEvalSegmentedControl.widthAnchor, multiplier: 1 / CGFloat(uploadEvalSegmentedControl.numberOfSegments)).isActive = true
        
        // move button bar
        uploadEvalSegmentedControl.addTarget(responder, action: #selector(responder.segmentedControlValueChanged(_:)), for: UIControl.Event.valueChanged)
        
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

