//
//  UrlHandler.swift
//  Lab6
//
//  Created by Jake Carlson on 11/6/18.
//  Copyright © 2018 Mobile Sensing. All rights reserved.
//

import Foundation
import UIKit

let SERVER_URL = "http://169.254.120.205:8000"

class UrlHandler: NSObject, URLSessionDelegate {
    var session = URLSession()
    let operationQueue = OperationQueue()
    
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
    
    func getPrediction(_ image:UIImage){
        let baseURL = "\(SERVER_URL)/ImageToText"
        let postUrl = URL(string: "\(baseURL)")

        var request = URLRequest(url: postUrl!)
        
        let boundary = generateBoundaryString()
        
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpBody = getImagePostBodyWithBoundary(image, boundary: boundary)
        
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
                    if let res = response {
                        print("Response:\n",res)
                    }
                    if let d = data {
                        print(String(data: d, encoding: .utf8)!)
                    }
                }
            }
        )
        postTask.resume() // start the task
    }
    
    func uploadLabeledImage(_ image: UIImage, label: String) {
        let baseURL = "\(SERVER_URL)/UploadLabeledImage?class_name=\(label)"
        print(baseURL)
        let postUrl = URL(string: "\(baseURL)")
       
        var request = URLRequest(url: postUrl!)
        
        let boundary = generateBoundaryString()
        
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = getImagePostBodyWithBoundary(image, boundary: boundary)
        
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
                    if let res = response {
                        print("Response:\n",res)
                    }
                    if let d = data {
                        print(String(data: d, encoding: .utf8)!)
                    }
                }
        }
        )
        postTask.resume() // start the task
    }
    
    private func getImagePostBodyWithBoundary(_ image: UIImage, boundary: String) -> Data {
        let imageData = image.jpegData(compressionQuality: 1.0)
        var body = Data()
        
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".utf8))
        body.append(Data("Content-Type: image/jpg\r\n\r\n".utf8))
        body.append(imageData!)
        body.append(Data("\r\n--\(boundary)--\r\n".utf8))
        
        return body
    }
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
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
