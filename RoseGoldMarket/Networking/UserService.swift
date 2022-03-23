//
//  User.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/2/22.
//

import Foundation



final class UserNetworking {
    let networker: Networker = Networker()
    static let shared: UserNetworking = UserNetworking()
    private let keyChainLabel = "rose-gold-access-token"
    
    func emailSupport(subject: String, message: String, token: String, completion: @escaping (Result<Bool, SupportErrors>) -> ()) {
        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "http://localhost:4000/users/email-support", token: token, post: true)
        let session = URLSession.shared
        let body = ["subject": subject, "message": message]
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
        session.dataTask(with: request) {(_, response, error) in
            if error != nil {
                print("there was an error with the request")
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }
            
            let isOK = self.networker.checkOkStatus(res: response)
            if isOK {
                completion(.success(true))
            } else if response.statusCode ~= 403 {
                completion(.failure(.tokenExpired))
            } else {
                completion(.failure(.serverError))
            }
        }.resume()
    }
    
    func saveNewAddress(newAddress:String, newCity:String, newState:String, newZipCode:UInt, newGeoLocation:String, completion: @escaping (Result<Bool, SupportErrors>) -> ()) {
        let request = networker.constructRequest(uri: "http://localhost:4000/users/change-address", post: true)
        let body:[String:Any] = ["newAddress":newAddress, "newCity":newCity, "newState":newState, "newZip":newZipCode, "newGeolocation":newGeoLocation]
        let req = networker.buildReqBody(req: request, body: body)
        
        URLSession.shared.dataTask(with: req) {[weak self] (_, response, error) in
            if error != nil {
                completion(.success(false))
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }
            
            let isOK = self?.networker.checkOkStatus(res: response)
            
            if let isOK = isOK {
                if isOK {
                    completion(.success(true))
                } else if response.statusCode ~= 403 {
                    completion(.failure(.tokenExpired))
                } else {
                    completion(.failure(.serverError))
                }
            }
        }.resume()
    }
    
    func fetchCurrentAddress(accountId: UInt, completion: @escaping (Result<AddressInfo, AccountDetailsErrors>) -> ()) {
        let request = networker.constructRequest(uri: "http://localhost:4000/users/address-details?accountId=\(accountId)", post: false)
        
        URLSession.shared.dataTask(with: request) {(data, response, err) in
            if err != nil {
                completion(.failure(.serverError))
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }
            
            guard (200...299).contains(response.statusCode) else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let addy = try JSONDecoder().decode(AddressInfo.self, from: data)
                completion(.success(addy))
            } catch let acctErr {
                print(acctErr)
                completion(.failure(.dataDecodingError))
            }
        }.resume()
    }
    
    func fetchUsersItems(accountId: UInt, completion: @escaping (Result<[ItemNameAndId], AccountDetailsErrors>) -> ()) {
        let req = networker.constructRequest(uri: "http://localhost:4000/users/user-items?accountId=\(accountId)", post: false)
        
        URLSession.shared.dataTask(with: req) {(data, response, error) in
            if error != nil {
                completion(.failure(.serverError))
            }
            
            guard let _ = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }

            guard let data = data else {
                completion(.failure(.dataDecodingError))
                return
            }
            
            do {
                let itemData = try JSONDecoder().decode([ItemNameAndId].self, from: data)
                completion(.success(itemData))
            } catch let decodeError {
                print(decodeError.localizedDescription)
            }
        }.resume()
    }
    
    func registerUser(username:String, email:String, pw:String, addy:String, zip:UInt, state:String, city:String, geolocation:String, avi:Data, completion: @escaping (Result<Bool, SupportErrors>) -> ()) {
        let serverUrl = URL(string: "http://localhost:4000/users/register-user")
        var urlRequest = URLRequest(url: serverUrl!)
        // construct the multipart request with the image data
        let boundary = UUID().uuidString
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // add the image data to the raw http request data
        var requestData = Data()
        requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        requestData.append("Content-Disposition: form-data; name=\"avatar\"; filename=\"\(username).jpg\"\r\n".data(using: .utf8)!)
        requestData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        requestData.append(avi)
        
        // username
        requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        requestData.append("Content-Disposition: form-data; name=\"username\"\r\n\r\n".data(using: .utf8)!)
        requestData.append("\(username)\r\n".data(using: .utf8)!)
        
        // email
        requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        requestData.append("Content-Disposition: form-data; name=\"email\"\r\n\r\n".data(using: .utf8)!)
        requestData.append("\(email)\r\n".data(using: .utf8)!)
        
        //password
        requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        requestData.append("Content-Disposition: form-data; name=\"password\"\r\n\r\n".data(using: .utf8)!)
        requestData.append("\(pw)\r\n".data(using: .utf8)!)
        
        // address
        requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        requestData.append("Content-Disposition: form-data; name=\"address\"\r\n\r\n".data(using: .utf8)!)
        requestData.append("\(addy)\r\n".data(using: .utf8)!)
        
        // zipcode
        requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        requestData.append("Content-Disposition: form-data; name=\"zipcode\"\r\n\r\n".data(using: .utf8)!)
        requestData.append("\(zip)\r\n".data(using: .utf8)!)
        
        // state
        requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        requestData.append("Content-Disposition: form-data; name=\"state\"\r\n\r\n".data(using: .utf8)!)
        requestData.append("\(state)\r\n".data(using: .utf8)!)
        
        // city
        requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        requestData.append("Content-Disposition: form-data; name=\"city\"\r\n\r\n".data(using: .utf8)!)
        requestData.append("\(city)\r\n".data(using: .utf8)!)
        
        // geolocation
        requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        requestData.append("Content-Disposition: form-data; name=\"geolocation\"\r\n\r\n".data(using: .utf8)!)
        requestData.append("\(geolocation)\r\n".data(using: .utf8)!)
        
        // finish the request
        requestData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        // now send off the request
        URLSession.shared.uploadTask(with: urlRequest, from: requestData) { (_, res, error) in
            if error != nil {
                completion(.failure(.serverError))
            }
            
            guard let res = res as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }
            
            if res.statusCode == 200 {
                completion(.success(true))
            } else {
                completion(.success(false))
            }
            
        }.resume()
    }
    
    func login(username:String, pw: String, completion: @escaping (Result<ServiceUser, UserErrors>) -> ()) {

        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "http://localhost:4000/users/login", post: true)
        
        let session = URLSession.shared
        let body = ["username": username, "password": pw]
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)

        session.dataTask(with: request) { (data, response, err) in
            if err != nil {
                print("there was a big error: \(String(describing: err))")
                completion(.failure(.failure))
            }
            
            guard let data = data else {
                completion(.failure(.failure))
                return
            }

            do {
                let usrResponse = try JSONDecoder().decode(ResponseFromServer<ServiceUser>.self, from: data)
                completion(.success(usrResponse.data))
            } catch let decodeError {
                print(decodeError)
            }
        }.resume()
    }
    
    func saveAccessToken(accessToken: String) {
        // save the access token to the device in a set place
        let key = accessToken
        let addquery = [
            kSecClass: kSecClassKey,
            kSecAttrLabel: self.keyChainLabel,
            kSecValueData: Data(key.utf8)
        ] as CFDictionary
        
        let status = SecItemAdd(addquery, nil)
        print("Save operation finished with status: \(status)")
    }
    
    func saveUserToDevice(user: ServiceUser) {
        let defaults: UserDefaults = .standard
        // store the user's info
        defaults.set(user.username, forKey: "username")
        defaults.set(user.accountId, forKey: "accountId")
        defaults.set(user.avatarUrl, forKey: "avatarUrl")
    }
    
    func loadUserFromDevice() -> ServiceUser? {
        let defaults: UserDefaults = .standard
        let username = defaults.string(forKey: "username")
        let accountId = defaults.integer(forKey: "accountId")
        let avatarUrl = defaults.string(forKey: "avatarUrl")
        guard
            let username = username,
            let avatarUrl = avatarUrl
        else {
            return nil
        }

         let serviceUser: ServiceUser = ServiceUser(avatarUrl: avatarUrl, accountId: UInt(accountId), username: username, accessToken: "")
        
        return serviceUser
    }
    
    func updateAccessToken(newToken: String) {
        let findTokenQuery = [
            kSecClass: kSecClassKey,
            kSecAttrLabel: self.keyChainLabel
        ] as CFDictionary
        
        let updateQuery = [
            kSecValueData: Data(newToken.utf8)
        ] as CFDictionary
        
        let status = SecItemUpdate(findTokenQuery, updateQuery)
        print("Update Finished with a status of \(status)")
    }
    
    func deleteAccessToken() {
        let delquery = [
            kSecClass: kSecClassKey,
            kSecAttrLabel: self.keyChainLabel
        ] as CFDictionary
        let status = SecItemDelete(delquery)
        print("Delete operation finished with status: \(status)")
    }
    
    func loadAccessToken() -> String? {
        let getquery = [
            kSecClass: kSecClassKey,
            kSecAttrLabel: self.keyChainLabel,
            kSecReturnData: true,
            kSecReturnAttributes: true
        ] as CFDictionary
        
        var item: AnyObject?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        print("Load operation finished with status: \(status)")
        let dict = item as? NSDictionary
        if dict != nil {
            let keyData = dict![kSecValueData] as! Data
            let accessToken = String(data: keyData, encoding: .utf8)!
            print("Loaded access token: \(accessToken)")
            return accessToken
        } else {
            return nil
        }
    }
}


enum SupportErrors: String, Error {
    case tokenExpired = "The access token has expired. Time to issue a new one"
    case requestError = "There was a problem making the request."
    case serverError = "There was an error with the request on the server."
    case responseConversionError = "Unable to decode http response."
}

enum AccountDetailsErrors: String, Error {
    case serverError = "There was an error processing the request."
    case tokenExpired = "The access token has expired. Time to issue a new one."
    case dataDecodingError = "There was a problem decoding the data."
    case responseConversionError = "Unable to decode http response."
}
