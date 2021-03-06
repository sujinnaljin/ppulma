//
//  PostableService.swift
//  Ppulma
//
//  Created by 강수진 on 2018. 10. 29..
//  Copyright © 2018년 강수진. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol PostableService {
    associatedtype NetworkData : Codable
    typealias networkResult = (resCode : Int, resResult : NetworkData)
    func post(_ URL:String, params : [String : Any],method : HTTPMethod, completion : @escaping (Result<networkResult>)->Void)
    
}

extension PostableService {
    
    func gino(_ value : Int?) -> Int {
        return value ?? 0
    }
    
    
    func post(_ URL:String, params : [String : Any], method : HTTPMethod = .post, completion : @escaping (Result<networkResult>)->Void){
        
        guard let encodedUrl = URL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("networking - invalid url")
            return
        }
        
        print("url 은 \(encodedUrl)")
        let userToken = UserDefaults.standard.string(forKey: "userToken") ?? "-1"
        var headers: HTTPHeaders?
        
        if userToken != "-1" {
            headers = [
                "authorization" : userToken
            ]
        }
        
        Alamofire.request(encodedUrl, method: method, parameters: params, encoding: CustomPostEncoding(), headers: headers).responseData(){
            res in
            switch res.result {
            case .success:
                print(encodedUrl)
                print("networking Post Here")
                print(JSON(res.result))
                if let value = res.result.value {
                    print(JSON(value))
                    let decoder = JSONDecoder()
                    
                    
                    do {
                        
                        let resCode = self.gino(res.response?.statusCode)
                        let data = try decoder.decode(NetworkData.self, from: value)
                        
                        let result : networkResult = (resCode, data)
                        completion(.success(result))
                        
                        
                    }catch{
                        
                        completion(.error("error post"))
                    }
                }
                break
            case .failure(let err):
                print(err.localizedDescription)
                completion(.failure(err))
                break
            }
        }
        
        
    }
    
    
    
}

