//
//  APIHelper.swift
//  ImageFetchingAndDisplayingDemo
//
//  Created by NC2-28 on 13/02/18.
//  Copyright © 2018 NC2-28. All rights reserved.
//fc

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class APIHelper {
    static let shared : APIHelper = {
        let instance = APIHelper()
        return instance
    }()
    
    //MARK: - Get Request to be called
    func postJsonRequest(url:String,parameter: Parameters,headers: HTTPHeaders,completion: @escaping (Bool,String,[String:Any]) -> Void) {
		if !isNetworkConnected
		{
            ShowToast(message: "Please check your internet connection..")
			completion(false, "ConnectionLost", [:])
		}
        
        Alamofire.request(url,
                          method: .post,
                          parameters: parameter,
                          encoding: JSONEncoding.default,
                          headers: headers ).validate(contentType: ["application/json"]).responseJSON
            { (response:DataResponse<Any>) in
               // print(response)
                if let _ = response.result.error{
                    if((response.result.error! as NSError).code == NSURLErrorNetworkConnectionLost || (response.result.error! as NSError).code == NSURLErrorTimedOut){
                        self.postJsonRequest(url: url, parameter: parameter, headers: headers, completion: completion)
                    }else{
                         completion(false, MESSAGE,[:])
                       // responseData(nil, response.result.error as NSError?, MESSAGE)
                    }
                }
                
                let status = response.response?.statusCode
                 print("STATUS \(status)")
                if let data = response.data
                { let json = String(data: data, encoding: String.Encoding.utf8)
                    print("Response: \(String(describing: json))")

                }
                switch(response.result)
                {
                case .success( _):
                    if let result = response.result.value as? [String:Any]{
                        completion(true, "success", result)
                    }else{
                        completion(false, "Failed", [:])
                    }
                  //  print("response is success:  \(response)")
                    break
                case .failure( _):
                    
                    
                    var message = "Something went wrong"
                    guard case let .failure(error) = response.result else { return }
                    
                        if let error = error as? AFError {
                            switch error {
                            case .invalidURL(let url):
                                print("Invalid URL: \(url) - \(error.localizedDescription)")
                                message = "Invalid URL"
                            case .parameterEncodingFailed(let reason):
                                print("Parameter encoding failed: \(error.localizedDescription)")
                                print("Failure Reason: \(reason)")
                                message = "Parameter encoding failed"
                            case .multipartEncodingFailed(let reason):
                                print("Multipart encoding failed: \(error.localizedDescription)")
                                print("Failure Reason: \(reason)")
                                message = "Multipart encoding failed"
                            case .responseValidationFailed(let reason):
                                print("Response validation failed: \(error.localizedDescription)")
                                print("Failure Reason: \(reason)")
                                message = "Response validation failed"
                            case .responseSerializationFailed(let reason):
                                print("Response serialization failed: \(error.localizedDescription)")
                                print("Failure Reason: \(reason)")
                                message = "Response serialization failed"
                            }
                            
                            print("Underlying error: \(error.underlyingError)")
                        } else if let error = error as? URLError {
                            print("URLError occurred: \(error)")
                        } else {
                            print("Unknown error: \(error)")
                        }
                    completion(false, message,[:])
                    break
                }
        }
    }
    
    func postMultipartJSONRequest(endpointurl:String, parameters:NSDictionary, encodingType:ParameterEncoding = JSONEncoding.default, responseData:@escaping (_ data: AnyObject?, _ error: NSError?, _ message: String?) -> Void)
    {
        //ShowNetworkIndicator(xx: true)
		if !isNetworkConnected
		{
			responseData(nil, nil, "Please check your internet connection..")
		}
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            var imageCount = 1
            for (key, value) in parameters
            {
                if value is UIImage {
					if let imageData:Data = (value as? UIImage)?.jpegData(compressionQuality: 0.3)
					{
						multipartFormData.append(imageData, withName: key as! String, fileName: "swift_file_\(imageCount).jpg", mimeType: "image/*")
						imageCount += 1
					}
                }
                else if value is NSArray || value is NSMutableArray {
                    for childValue in value as! NSArray
                    {
                        if childValue is UIImage {
							if let imageData:Data = (childValue as? UIImage)?.jpegData(compressionQuality: 0.3)
							{
								multipartFormData.append(imageData, withName: key as! String, fileName: "swift_file_\(imageCount).jpg", mimeType: "image/*")
								imageCount += 1
							}
                        }
                    }
                }else if value is [UIImage] {
                    for childValue in value as! [UIImage]
                    {
                        let imageData:Data = (childValue).jpegData(compressionQuality: 0.3)!
                        multipartFormData.append(imageData, withName: key as! String, fileName: "swift_file_\(imageCount).jpg", mimeType: "image/*")
						imageCount += 1
                    }
                }
                else if value is URL{
                    let audioData : Data
                    do {
                        audioData = try Data (contentsOf: (value as! URL), options: .mappedIfSafe)
                        multipartFormData.append(audioData, withName: key as! String, fileName: "swift_file.m4a", mimeType: "audio/*")
                    } catch {
                        print(error)
                        return
                    }
                }else if value is NSURL || value is URL {
                    let videoData:Data
                    do {
                        videoData = try Data (contentsOf: (value as! URL), options: .mappedIfSafe)
                        multipartFormData.append(videoData, withName: key as! String, fileName: "swift_file.mp4", mimeType: "video/*")
                    } catch {
                        print(error)
                        return
                    }
                }
                else if let otherValue = "\(value)".data(using: .utf8) {
                    multipartFormData.append(otherValue, withName: key as! String)
                }
            }
            
        }, to: endpointurl, headers: headers) { encodingResult in
            
            //ShowNetworkIndicator(xx: false)
            
            
            switch encodingResult {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    //if isUploading && isForeground {
                    //self.delegate?.didReceivedProgress(progress: Float(progress.fractionCompleted))
                    //}
                })
                
                upload.responseString(completionHandler: { (resp) in
                    //print("RESP : \(resp)")
                })
                
                upload.responseJSON { response in
                    ////print(response)
                    if let data = response.data
                    { let json = String(data: data, encoding: String.Encoding.utf8)
                        print("Response: \(String(describing: json))")
                        
                    }
                    switch(response.result) {
                    case .success(_):
                        if let data = response.result.value
                        {
                            print(data)
                            
                            let Message = (data as! NSDictionary)[MESSAGE] as? String
                            //                            let responseStatus = (data as! NSDictionary)[WSSTATUS] as! NSString
                            //                            switch (responseStatus.integerValue) {
                            //
                            //                            case RESPONSE_STATUS.VALID.rawValue :
                            //                                self.resObjects = (data as! NSDictionary) as AnyObject!
                            //                                break
                            //
                            //                            case RESPONSE_STATUS.INVALID.rawValue :
                            //                                self.resObjects = (data as! NSDictionary) as AnyObject!
                            //                                break
                            //                            default :
                            //                                break
                            //                            }
                            responseData(data as AnyObject, nil, Message)
                            
                        }
                        break
                        
                    case .failure(_):
                        var message = "Something went wrong"
                        guard case let .failure(error) = response.result else { return }
                        
                            if let error = error as? AFError {
                                switch error {
                                case .invalidURL(let url):
                                    print("Invalid URL: \(url) - \(error.localizedDescription)")
                                    message = "Invalid URL"
                                case .parameterEncodingFailed(let reason):
                                    print("Parameter encoding failed: \(error.localizedDescription)")
                                    print("Failure Reason: \(reason)")
                                    message = "Parameter encoding failed"
                                case .multipartEncodingFailed(let reason):
                                    print("Multipart encoding failed: \(error.localizedDescription)")
                                    print("Failure Reason: \(reason)")
                                    message = "Multipart encoding failed"
                                case .responseValidationFailed(let reason):
                                    print("Response validation failed: \(error.localizedDescription)")
                                    print("Failure Reason: \(reason)")
                                    message = "Response validation failed"
                                case .responseSerializationFailed(let reason):
                                    print("Response serialization failed: \(error.localizedDescription)")
                                    print("Failure Reason: \(reason)")
                                    message = "Response serialization failed"
                                }
                                
                                print("Underlying error: \(error.underlyingError)")
                            } else if let error = error as? URLError {
                                print("URLError occurred: \(error)")
                            } else {
                                print("Unknown error: \(error)")
                            }
                        responseData(nil, response.result.error as NSError?,message)
                        break
                        
                    }
                }
            case .failure( _):
                responseData(nil, nil, MESSAGE)
            }
        }
    }
    
    //MARK:- GET Request
    func getRequestWithoutParams(endpointurl:String,responseData:@escaping (_ data:AnyObject?, _ error: NSError?, _ message: String?) -> Void)
    {
        
        let  alamofireManager = Alamofire.SessionManager.default
        alamofireManager.request(endpointurl, method: .get).responseJSON { (response:DataResponse<Any>) in
            
//                        if let data = response.data
//                        { let json = String(data: data, encoding: String.Encoding.utf8)
//                            print("Response: \(String(describing: json))")
//
//                        }
            
            if let _ = response.result.error
            {
                responseData(nil, response.result.error as NSError?,MESSAGE)
            }
            else
            {
                switch(response.result)
                {
                case .success(_):
                    if let data = response.result.value
                    {
                        //let Message = (data as! NSDictionary)[MESSAGE] as! String
//                        let responseStatus = (data as! NSDictionary)[VSTATUS] as! NSString
//                        // if ( responseStatus .isEqual(to: RESPONSE_STATUS_message.success.rawValue as String))
//                        if ( responseStatus .isEqual(to:"success"))
//                        {
//                            self.resObjects = (data as! NSDictionary) as AnyObject!
//                        }
//                        else
//                        {
//                            self.resObjects = (data as! NSDictionary) as AnyObject!
//                        }
//
                        responseData(data as AnyObject, nil, "Sucess")
                    }
                    break
                case .failure(_):
                    responseData(nil, response.result.error as NSError?, MESSAGE)
                    break
                }
            }
        }
    }

}
