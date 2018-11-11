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

let SERVER_URL = "http://192.168.0.9:8000"

class UrlHandler: NSObject, URLSessionDelegate {
    private var session = URLSession()
    private let operationQueue = OperationQueue()
    private let symbolModel = SymbolModel()
    
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
    
    func getLocalPrediction(_ image: UIImage) {
        let baseURL = "\(SERVER_URL)/SplitImage"
        let postUrl = URL(string: "\(baseURL)")
        
        var request = URLRequest(url: postUrl!)
        
        let boundary = generateBoundaryString()
        
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = getImagePostBodyWithBoundary(image, boundary: boundary)
        
        var chars = Dictionary<Int, SymbolModelOutput>()
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
                    var boundary = ""
                    if let res = response as? HTTPURLResponse {
                        print("Response:\n",res)
                    }
                    if let d = data {
                        let images = self.convertDataToDictionary(with: d)
                        print(images)
                        for i in 0..<(images["num"] as! Int) {
                            let dl = self.session.downloadTask(with: URL(string: "\(SERVER_URL)/\(images[String(i)]!)")!, completionHandler: {
                                (location, response, error) in
                                if (error == nil) {
                                    print(location)
                                    do {
                                        let subImage = try! UIImage(data: Data(contentsOf: location!))
                                        chars[i] = try self.symbolModel.prediction(input: SymbolModelInput(img: subImage!.pixelBufferGray(width: 50, height: 50)!))
                                    }
                                    catch {
                                        return
                                    }
                                }
                            })
                            dl.resume()
                        }
                    }
                }
            }
        )
        postTask.resume() // start the task
    }
    
//    private func imageToMultiArray(image: UIImage) -> MLMultiArray? {
//        let size = CGSize(width: 50, height: 50)
//        guard let array = try? MLMultiArray(shape: [1, 50, 50], dataType: .double) else {
//            return nil
//        }
//        let gr = image.cgImage.pi .filter { $0.offset % 4 == 1 }.map { $0.element }
//    }
    
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

// https://github.com/hollance/CoreMLHelpers/blob/master/CoreMLHelpers/UIImage%2BCVPixelBuffer.swift
extension UIImage {
    public func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        return pixelBuffer(width: width, height: height,
                           pixelFormatType: kCVPixelFormatType_32ARGB,
                           colorSpace: CGColorSpaceCreateDeviceRGB(),
                           alphaInfo: .noneSkipFirst)
    }
    
    public func pixelBufferGray(width: Int, height: Int) -> CVPixelBuffer? {
        return pixelBuffer(width: width, height: height,
                           pixelFormatType: kCVPixelFormatType_OneComponent8,
                           colorSpace: CGColorSpaceCreateDeviceGray(),
                           alphaInfo: .none)
    }
    
    func pixelBuffer(width: Int, height: Int, pixelFormatType: OSType,
                     colorSpace: CGColorSpace, alphaInfo: CGImageAlphaInfo) -> CVPixelBuffer? {
        var maybePixelBuffer: CVPixelBuffer?
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         pixelFormatType,
                                         attrs as CFDictionary,
                                         &maybePixelBuffer)
        
        guard status == kCVReturnSuccess, let pixelBuffer = maybePixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
        
        guard let context = CGContext(data: pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                      space: colorSpace,
                                      bitmapInfo: alphaInfo.rawValue)
            else {
                return nil
        }
        
        UIGraphicsPushContext(context)
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer
    }
}
