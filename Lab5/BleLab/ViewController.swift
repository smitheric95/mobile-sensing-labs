//
//  ViewController.swift
//  ExampleRedBearChat
//
//  Created by Eric Larson on 9/26/17.
//  Copyright © 2017 Eric Larson. All rights reserved.
//

import UIKit
import Charts

class ViewController: UIViewController{
    
    // MARK: ====== VC Properties ======
    lazy var bleShield: BLE = (UIApplication.shared.delegate as! AppDelegate).bleShield
    var rssiTimer = Timer()
    var photoVals = Array<Int>()
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var sliderValueLabel: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var ledOnLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // BLE Connect Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onBLEDidConnectNotification),
                                               name: NSNotification.Name(rawValue: kBleConnectNotification),
                                               object: nil)
        
        // BLE Disconnect Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onBLEDidDisconnectNotification),
                                               name: NSNotification.Name(rawValue: kBleDisconnectNotification),
                                               object: nil)
        
        // BLE Recieve Data Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onBLEDidRecieveDataNotification),
                                               name: NSNotification.Name(rawValue: kBleReceivedDataNotification),
                                               object: nil)
        
        self.spinner.startAnimating()
    }
    
    func readRSSITimer(timer:Timer){
        bleShield.readRSSI { (number, error) in
            // when RSSI read is complete, display it
            self.rssiLabel.text = String(format: "%.1f",(number?.floatValue)!)
        }
    }

    // MARK: ====== BLE Delegate Methods ======
    func bleDidUpdateState() {
        
    }

    // NEW  CONNECT FUNCTION
    @objc func onBLEDidConnectNotification(notification:Notification){
        print("Notification arrived that BLE Connected")
        
        self.spinner.stopAnimating()
        let s = notification.userInfo?["name"] as! String?
        self.deviceNameLabel.text = s
        
        rssiTimer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                                 repeats: true,
                                                 block: self.readRSSITimer)
    }

    // NEW  DISCONNECT FUNCTION
    @objc func onBLEDidDisconnectNotification(notification:Notification){
        print("Notification arrived that BLE Disconnected a Peripheral")
        rssiTimer.invalidate()
    }
    
    func savePhoto(val: String) {
        let newVal = Int(val)
        self.photoVals.append(newVal!)
        if self.photoVals.count > 60 {
            self.plotPhotoVals()
            self.photoVals.removeFirst(10)
        }
    }
    
    func plotPhotoVals() {
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<self.photoVals.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(self.photoVals[i]))
            dataEntries.append(dataEntry)
        }
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Intensity")
        chartDataSet.drawCirclesEnabled = false
        
        
        let chartData = LineChartData(dataSet: chartDataSet)
        self.chartView.data = chartData
    }
    
    // NEW FUNCTION EXAMPLE: this was written for you to show how to change to a notification based model
    @objc func onBLEDidRecieveDataNotification(notification:Notification){
        let d = notification.userInfo?["data"] as! Data?
        let s = String(bytes: d!, encoding: String.Encoding.utf8)
        print(s!)
        let photoPrefix = "PHOTO:"
        if s!.range(of: photoPrefix) != nil {
            let rxArr = s!.components(separatedBy: ";")
            print(rxArr)
            self.savePhoto(val: rxArr[0].components(separatedBy: ":")[1]);
            self.ledOnLabel.text = rxArr[1].components(separatedBy: ":")[1] == "TRUE" ? "ON" : "OFF";
        }
    }
    
    // OLD FUNCTION: parse the received data using BLEDelegate protocol
    func bleDidReceiveData(data: Data?) {
        // this data could be anything, here we know its an encoded string
        let s = String(bytes: data!, encoding: String.Encoding.utf8)
        
    }
    
    // MARK: ====== User initiated Functions ======

    @IBAction func sliderChanged(_ sender: UISlider) {
        self.sliderValueLabel.text = "\(Int(sender.value))"
        let s = "SET LED: \(Int(sender.value))"
        let d = s.data(using: String.Encoding.utf8)!
        bleShield.write(d)
    }
}








