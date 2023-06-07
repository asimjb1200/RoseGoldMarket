//
//  NetworkingHelper.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import Foundation
import UIKit
import Alamofire

struct Networker {
    // static let shared = Networker()
    init() {}
    
    /// gets the correct base url for the environment that I am planning on working in
    func getUrlForEnv(appEnvironment: AppEnvironment) -> String? {
        guard let plist = Bundle.main.infoDictionary else {return nil}
        guard let endpoints = plist["URL Endpoints"] as? [String: String] else {return nil}
        guard let urlBase = endpoints[appEnvironment.rawValue] else {return nil}
        return urlBase
    }
    
    func constructRequest(uri: String, token: String = "", post: Bool = false, queryItems: [URLQueryItem]? = nil, deleteReq: Bool = false) -> URLRequest {
        var url = URL(string: uri)!
        
        if queryItems != nil {
            if let queryItems = queryItems {
                url.append(queryItems: queryItems)
            }
        }

        var request: URLRequest = URLRequest(url: url)
        
        if post {
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } else if deleteReq {
            request.httpMethod = "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } else {
            request.httpMethod = "GET"
        }
        
        if !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }
    
    func buildReqBody(req: URLRequest, body: [String:Any]) -> URLRequest {
        var request = req
        do {
//            let encoder = JSONEncoder()
//            encoder.outputFormatting = .prettyPrinted
//            let jsonData = json(from: body["items"] as! [ItemForBackend])
            let bodyData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = bodyData
        } catch let err {
            print(err)
        }
        return request
    }
    
    func json<T: Codable>(from convertMe: T) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        encoder.dataEncodingStrategy = .base64
        let data = try? encoder.encode(convertMe)
        guard let data = data else {return ""}
        let jsonData = String(data: data, encoding: .utf8)
        if let jsonData = jsonData {
            return jsonData
        } else {
            return ""
        }
    }
    
    func buildMultipartImageRequest(boundary: String, item: ItemForBackend, itemId:UInt = 0) -> Data {
        var data = Data()
        
        // add the rest of the item's info to the multipart form data
        let paramObj:[String: Any] = item.getParams()
        
        for(key, value) in paramObj {
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        if itemId != 0 {
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"itemId\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(itemId)\r\n".data(using: .utf8)!)
        }
        
        // add the image data to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"images\"; filename=\"\(item.filename1)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(item.image1)
        data.append("\r\n".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"images\"; filename=\"\(item.filename2)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(item.image2)
        data.append("\r\n".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"images\"; filename=\"\(item.filename3)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(item.image3)
        data.append("\r\n".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        return data
    }
    
    func addImageToRequest(paramName: String, fileName: String, image: Data) -> Data {
        let data = Data()
        
        return data
    }
    
    func checkOkStatus(res: HTTPURLResponse) -> Bool {
        if (200...299).contains(res.statusCode) {
            return true
        } else {
            return false
        }
    }
    
    func check404Status(res: HTTPURLResponse) -> Bool {
        if res.statusCode == 404 {
            return true
        } else {
            return false
        }
    }
}
