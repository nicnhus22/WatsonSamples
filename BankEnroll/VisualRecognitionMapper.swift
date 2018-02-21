//
//  VisualRecognitionMapper.swift
//  BankEnroll
//
//  Created by Nicolas Husser on 23/11/2017.
//  Copyright © 2017 Wavestone. All rights reserved.
//


import Alamofire
import ObjectMapper
import SwiftyJSON

class VisualRecognitionMapper {
    
    static func recognizeImage(_ imageURL: String, completion:
        @escaping (_ maleOrFemale: String) -> Void) {
        
        let URL = Routes.IBM_VR_URL
        let parameters : [ String : AnyObject] = [
            "url": imageURL as AnyObject
        ]
        let headers = ["csrf-token": UIApplication.valueForAPIKey(named: "VISUAL_RECOGNITION_TOKEN"),
                       "Content-Type": "application/json" ]
        
        Alamofire.request(URL, method: .post, parameters: parameters, encoding: JSONEncoding.default,
                          headers: headers).validate().responseJSON { response in
            if String(describing: response).range(of: "FEMALE") != nil {
                completion("FEMALE")
            } else {
                completion("MALE")
            }
        }
    }
}

