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
    lazy var numStepsToday = 0
    lazy var numStepsReceivedToday = 0
    lazy var numStepsYesterday = 0
    
    // creates a singleton for the model
    // reference: https://cocoacasts.com/what-is-a-singleton-and-how-to-create-one-in-swift
    private static var sharedCoreMotionModel: CoreMotionModel = {
        return CoreMotionModel()
    }()
    
    private init() {
        if CMPedometer.isStepCountingAvailable() {
            self.calcNumStepsToday()
            self.calcNumStepsYesterday()
            self.pedometer.startUpdates(from: Date()) {
                (pedData: CMPedometerData?, error: Error?) -> Void in
                    self.numStepsReceivedToday = pedData?.numberOfSteps.intValue ?? 0
            }
        }
    }
    
    deinit {
        self.pedometer.stopUpdates()
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
    
    // MARK: Data Management
    private func calcNumStepsToday() -> Void {
        let now = Date()
        let from = Calendar.current.startOfDay(for: now)
        self.pedometer.queryPedometerData(from: from, to: now) {
            (pedData: CMPedometerData?, error: Error?) -> Void in
            if let n = pedData?.numberOfSteps {
                self.numStepsToday = n.intValue
            }
        }
    }
    
    private func calcNumStepsYesterday() -> Void {
        let now = Date()
        let startOfToday = Calendar.current.startOfDay(for: now)
        let startOfYesterday = startOfToday.addingTimeInterval(-60*60*24)
        self.pedometer.queryPedometerData(from: startOfYesterday, to: startOfToday) {
            (pedData: CMPedometerData?, error: Error?) -> Void in
            if let n = pedData?.numberOfSteps {
                self.numStepsYesterday = n.intValue
            }
        }
    }
    
}
