//
//  CoreMotionModel.swift
//  Lab3
//
//  Created by Jake Carlson on 9/22/18.
//  Copyright © 2018 Jake Carlson. All rights reserved.
//

import Foundation
import CoreMotion

class CoreMotionModel {
    
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
    
    
    // creates a singleton for the model
    // reference: https://cocoacasts.com/what-is-a-singleton-and-how-to-create-one-in-swift
    private static var sharedCoreMotionModel: CoreMotionModel = {
        return CoreMotionModel()
    }()
    
    private init() {
        self.calcNumStepsToday()
        self.calcNumStepsYesterday()
        if CMPedometer.isStepCountingAvailable() {
            self.pedometer.startUpdates(from: Date()) {
                (pedData: CMPedometerData?, error: Error?) -> Void in
                    self.numStepsReceivedToday = pedData?.numberOfSteps.intValue ?? 0
            }
        }
        if CMMotionActivityManager.isActivityAvailable() {
            self.activityManager.startActivityUpdates(to: self.activityQueue) {
                (activity: CMMotionActivity?) -> Void in
                self.currentActivity = self.getCurrentActivityString(activity: activity!)
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
    
    // returns the singleton instance of the model
    class func getSharedModel() -> CoreMotionModel {
        return .sharedCoreMotionModel
    }
    
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
    
    // MARK: Data Management
    private func calcNumStepsToday() -> Void {
        let now = Date()
        let from = Calendar.current.startOfDay(for: now)
        self.pedometer.queryPedometerData(from: from, to: now) {
            (pedData: CMPedometerData?, error: Error?) -> Void in
            self.numStepsToday = pedData!.numberOfSteps.intValue
        }
    }
    
    private func calcNumStepsYesterday() -> Void {
        let now = Date()
        let startOfToday = Calendar.current.startOfDay(for: now)
        let startOfYesterday = startOfToday.addingTimeInterval(-60*60*24)
        self.pedometer.queryPedometerData(from: startOfYesterday, to: startOfToday) {
            (pedData: CMPedometerData?, error: Error?) -> Void in
            self.numStepsYesterday = pedData!.numberOfSteps.intValue
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
