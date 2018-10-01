//
//  ViewController.swift
//  Lab3
//
//  Created by Jake Carlson on 9/22/18.
//  Copyright © 2018 Jake Carlson. All rights reserved.
//

import UIKit

class ViewController: CoreMotionViewControllerBase {
    @IBOutlet weak var stepsTodayLabel: UILabel!
    @IBOutlet weak var stepsYesterdayLabel: UILabel!
    @IBOutlet weak var currentActivityLabel: UILabel!
    @IBOutlet weak var stepsToGoalLabel: UILabel!
    @IBOutlet weak var stepGoalTextField: UITextField!
    @IBOutlet weak var playGameButton: UIButton!
    
    var labelUpdateTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.stepsTodayLabel.text = String(self.getNumStepsToday())
        self.stepsYesterdayLabel.text = String(self.getNumStepsYesterday())
        self.stepGoalTextField.text = String(self.getUserStepGoal())
        self.updateStepGoalLabel()
    }
    
    @IBAction func stepGoalDidChange(_ sender: UITextField) {
        if let inputText = sender.text {
            if inputText != "" {
                self.setUserStepGoal(newGoal: Int(inputText)!)
            }
            else {
                self.setUserStepGoal(newGoal: 0)
                self.stepGoalTextField.text = "0"
            }
        }
        self.updateStepGoalLabel()
    }
    
    func updateStepGoalLabel() {
        let stepsToday = self.getNumStepsToday()
        let stepGoal = self.getUserStepGoal()
        if stepGoal >= stepsToday {
            self.stepsToGoalLabel.text = String(stepGoal - stepsToday)
        }
        else {
            self.stepsToGoalLabel.text = "Passed goal!"
            self.playGameButton.isEnabled = true
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.stepGoalTextField.resignFirstResponder()
    }
    
    override func updateNumStepsToday(value: Int) -> Void {
        DispatchQueue.main.async {
            self.stepsTodayLabel.text = String(value)
            self.updateStepGoalLabel()
        }
    }
    
    override func updateNumStepsYesterday(value: Int) -> Void {
        DispatchQueue.main.async {
            self.stepsYesterdayLabel.text = String(value)
        }
    }
    
    override func updateCurrentActivity(label: String) -> Void{
        DispatchQueue.main.async {
            self.currentActivityLabel.text = label
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! GameViewController
        
        var numLives = 1
        
        if stepGoal > 0 {
            numLives = numStepsToday / stepGoal
           
            if numLives > 3 {
                numLives = 3
            }
        }

        vc.numLives = numLives
    }
}

