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
    @IBOutlet weak var stepsToGoalLabel: UILabel!
    @IBOutlet weak var stepGoalTextField: UITextField!
    
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
        self.stepGoalTextField.text = String(self.motionModel.getUserStepGoal())
    }
    
    func updateStepLabels() -> Void {
        let stepsToday = self.motionModel.getNumStepsToday()
        let stepsYesterday = self.motionModel.getNumStepsYesterday()
        let stepGoal = self.motionModel.getUserStepGoal()
        
        self.currentActivityLabel.text = self.motionModel.getCurrentActivity()
        self.stepsTodayLabel.text = String(stepsToday)
        self.stepsYesterdayLabel.text = String(stepsYesterday)
        if stepGoal >= stepsToday {
            self.stepsToGoalLabel.text = String(stepGoal - stepsToday)
        }
        else {
            self.stepsToGoalLabel.text = "Passed goal!"
        }
    }
    
    @IBAction func stepGoalDidChange(_ sender: UITextField) {
        if let inputText = sender.text {
            self.motionModel.setUserStepGoal(newGoal: Int(inputText)!)
        }
        self.updateStepLabels()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.stepGoalTextField.resignFirstResponder()
    }
}

