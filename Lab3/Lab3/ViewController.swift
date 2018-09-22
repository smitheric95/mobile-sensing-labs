//
//  ViewController.swift
//  Lab3
//
//  Created by Jake Carlson on 9/22/18.
//  Copyright © 2018 Jake Carlson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var stepsTodayLabel: UILabel!
    @IBOutlet weak var stepsYesterdayLabel: UILabel!
    @IBOutlet weak var currentActivityLabel: UILabel!
    
    let motionModel = CoreMotionModel.getSharedModel()
    var labelUpdateTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.stepsTodayLabel.text = String(self.motionModel.getNumStepsToday())
        self.stepsYesterdayLabel.text = String(self.motionModel.getNumStepsYesterday())
        self.labelUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) {
            _ in DispatchQueue.main.async {
                self.updateStepLabels()
            }
        }
    }
    
    func updateStepLabels() -> Void {
        self.stepsTodayLabel.text = String(self.motionModel.getNumStepsToday())
        self.stepsYesterdayLabel.text = String(self.motionModel.getNumStepsYesterday())
        self.currentActivityLabel.text = self.motionModel.getCurrentActivity()
    }

}

