//
//  CoreMotionModel.swift
//  Lab3
//
//  Created by Jake Carlson on 9/22/18.
//  Copyright © 2018 Jake Carlson. All rights reserved.
//

import Foundation
import CoreMotion
import UIKit

class CoreMotionViewControllerBase : UIViewController {
    
    // MARK: Properties
    let pedometer = CMPedometer()
    let activityManager = CMMotionActivityManager()
    let activityQueue = OperationQueue()
    let defaults = UserDefaults.standard
    
    lazy var numStepsToday = 0
    lazy var numStepsReceivedToday = 0
    lazy var numStepsYesterday = 0
    lazy var stepGoal = 0
    lazy var currentActivity: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calcNumStepsToday()
        self.calcNumStepsYesterday()
        if CMPedometer.isStepCountingAvailable() {
            self.pedometer.startUpdates(from: Date()) {
                (pedData: CMPedometerData?, error: Error?) -> Void in
                self.numStepsReceivedToday = pedData?.numberOfSteps.intValue ?? 0
                self.updateNumStepsToday(value: self.getNumStepsToday())
            }
        }
        if CMMotionActivityManager.isActivityAvailable() {
            self.activityManager.startActivityUpdates(to: self.activityQueue) {
                (activity: CMMotionActivity?) -> Void in
                self.currentActivity = self.getCurrentActivityString(activity: activity!)
                self.updateCurrentActivity(label: self.currentActivity)
            }
        }
        self.stepGoal = defaults.integer(forKey: "labThreeStepGoal")
    }
    
    deinit {
        if CMPedometer.isStepCountingAvailable() {
            self.pedometer.stopUpdates()
        }
        if CMMotionActivityManager.isActivityAvailable() {
            self.activityManager.stopActivityUpdates()
        }
    }
    
    // MARK: Accessors
    
    func getNumStepsToday() -> Int {
        return self.numStepsToday + self.numStepsReceivedToday
    }
    
    func getNumStepsYesterday() -> Int {
        return self.numStepsYesterday
    }
    
    func getCurrentActivity() -> String {
        return self.currentActivity
    }
    
    func getUserStepGoal() -> Int {
        return self.stepGoal
    }
    
    // MARK: Mutators
    func setUserStepGoal(newGoal: Int) -> Void {
        self.defaults.set(newGoal, forKey: "labThreeStepGoal")
        self.stepGoal = newGoal
    }
    
    func updateNumStepsToday(value: Int) -> Void {
        fatalError("Must override")
    }
    
    func updateNumStepsYesterday(value: Int) -> Void {
        fatalError("Must override")
    }
    
    func updateCurrentActivity(label: String) -> Void {
        fatalError("Must override")
    }
    
    // MARK: Data Management
    private func calcNumStepsToday() -> Void {
        let now = Date()
        let from = Calendar.current.startOfDay(for: now)
        self.pedometer.queryPedometerData(from: from, to: now) {
            (pedData: CMPedometerData?, error: Error?) -> Void in
            self.numStepsToday = pedData!.numberOfSteps.intValue
            self.updateNumStepsToday(value: self.getNumStepsToday())
        }
    }
    
    private func calcNumStepsYesterday() -> Void {
        let now = Date()
        let startOfToday = Calendar.current.startOfDay(for: now)
        let startOfYesterday = startOfToday.addingTimeInterval(-60*60*24)
        self.pedometer.queryPedometerData(from: startOfYesterday, to: startOfToday) {
            (pedData: CMPedometerData?, error: Error?) -> Void in
            self.numStepsYesterday = pedData!.numberOfSteps.intValue
            self.updateNumStepsYesterday(value: pedData!.numberOfSteps.intValue)
        }
    }
    
    private func getCurrentActivityString(activity: CMMotionActivity) -> String {
        if activity.walking {
            return "Walking"
        }
        else if activity.automotive {
            return "Driving"
        }
        else if activity.cycling {
            return "Cycling"
        }
        else if activity.running {
            return "Running"
        }
        else if activity.stationary {
            return "Stationary"
        }
        return "Unknown Activity"
    }
    
}
