//
//  UrlHandler.swift
//  Lab6
//
//  Created by Jake Carlson on 11/6/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

import Foundation
import UIKit
import CoreML

let SERVER_URL = "http://192.168.1.6:8000"

class UrlHandler: NSObject, URLSessionDelegate {
    private var session = URLSession()
    private let operationQueue = OperationQueue()
    
    override init() {
        super.init()
        
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 8.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        self.session = URLSession(configuration: sessionConfig,
                                  delegate: self,
                                  delegateQueue:self.operationQueue)
    }
    
    func getPrediction(_ code:String, outputLabel: UITextView){
        let baseURL = "\(SERVER_URL)/RunCode"
        let postUrl = URL(string: "\(baseURL)")

        var request = URLRequest(url: postUrl!)
        
        request.httpMethod = "POST"
        request.httpBody = self.convertDictionaryToData(with: ["code": code])
        
        let postTask : URLSessionDataTask = self.session.dataTask(
            with: request,
            completionHandler:{
                (data, response, error) in
                if(error != nil){
                    print("here error")
                    print(error)
                }
                else {
                    print("here data")
//                    if let res = response {
//                        print("Response:\n",res)
//                    }
                    if let d = data {
                        print(String(data: d, encoding: .utf8)!)
                        DispatchQueue.main.async {
                            outputLabel.text = ">>> " + String(data: d, encoding: .utf8)!
                        }
                    }
                }
            }
        )
        postTask.resume() // start the task
    }
    
    private func convertDictionaryToData(with jsonUpload:NSDictionary) -> Data?{
        do { // try to make JSON and deal with errors using do/catch block
            let requestBody = try JSONSerialization.data(withJSONObject: jsonUpload, options:JSONSerialization.WritingOptions.prettyPrinted)
            return requestBody
        } catch {
            print("json error: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func convertDataToDictionary(with data:Data?)->NSDictionary{
        do { // try to parse JSON and deal with errors using do/catch block
            let jsonDictionary: NSDictionary =
                try JSONSerialization.jsonObject(with: data!,
                                                 options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            return jsonDictionary
            
        } catch {
            print("json error: \(error.localizedDescription)")
            return NSDictionary() // just return empty
        }
    }
    
}
