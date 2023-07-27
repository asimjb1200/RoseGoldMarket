//
//  User.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/2/22.
//

import Foundation

final class UserNetworking {
    private let networker: Networker = Networker()
    static let shared: UserNetworking = UserNetworking()
    private let keyChainLabel = "rose-gold-access-token"
    private let keyChainPwLabel = "rose-gold-user-password"
    private init(){}
    
    func getGeolocation(token:String, completion: @escaping (Result<ResponseFromServer<String>, UserErrors>) -> ()) {
        let request:URLRequest = networker.constructRequest(uri: "https://rosegoldgardens.com/api/users/user-geolocation", token: token, post: false)
        let session = URLSession.shared
        
        session.dataTask(with: request) {(data, response, error) in
            guard error == nil else {
                completion(.failure(.serverError))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }
            
            guard response.statusCode == 200 else {
                completion(.failure(.responseConversionError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.dataConversionError))
                return
            }
            
            do {
                let usrGeolocation = try JSONDecoder().decode(ResponseFromServer<String>.self, from: data)
                completion(.success(usrGeolocation))
            } catch let decodingError {
                print("[UserNetworking] tried to fetch user's geolocation \(decodingError)")
                completion(.failure(.failure))
            }
            
        }.resume()
    }
    
    func checkUsernameAvailability(newUsername:String, completion: @escaping (Result<String, UserErrors>) -> ()) {
        let queryItem: [URLQueryItem] = [URLQueryItem(name: "newUsername", value: newUsername)]
        
        let reqWithoutBody:URLRequest = networker.constructRequest(uri: "https://rosegoldgardens.com/api/users/check-username", queryItems: queryItem)
        //let reqWithoutBody:URLRequest = networker.constructRequest(uri: "http://localhost:4000/api/users/check-username?newUsername=\(newUsername)", token: accessToken, post: false)
        //let reqWithoutBody:URLRequest = networker.constructRequest(uri: "http://192.168.1.65:4000/api/users/check-username?newUsername=\(newUsername)", token: accessToken, post: false)
        
        URLSession.shared.dataTask(with: reqWithoutBody) { (data, response, err) in
            guard err == nil else {
                completion(.failure(.failure))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }
            
            guard response.statusCode == 200 else {
                completion(.failure(.serverError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.dataConversionError))
                return
            }
            
            do {
                let usernameFound = try JSONDecoder().decode(String.self, from: data)
                completion(.success(usernameFound))
            } catch let secCodeError {
                print(secCodeError.localizedDescription)
                completion(.failure(.dataConversionError))
            }
        }.resume()
    }
    
    func reportAUser(userToReport: UInt, reportingUser:UInt, reason: String, token: String, completion: @escaping (Result<Bool, UserErrors>) -> ()) {
        let reqWithoutBody:URLRequest = networker.constructRequest(uri: "https://rosegoldgardens.com/api/users/report-user", token: token, post: true)
        //let reqWithoutBody:URLRequest = networker.constructRequest(uri: "http://localhost:4000/api/users/report-user", token: token, post: true)
        //let reqWithoutBody:URLRequest = networker.constructRequest(uri: "http://192.168.1.65:4000/api/users/report-user", token: token, post: true)
        
        let body: [String:Any] = ["reportingUserId": reportingUser, "reportedUserId":userToReport, "reason":reason]
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
        
        let session = URLSession.shared
        session.dataTask(with: request) { ( _, response, error) in
            if error != nil {
                completion(.failure(.serverError))
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }
            
            let isOk = self.networker.checkOkStatus(res: response)
            if isOk {
                completion(.success(true))
            } else {
                completion(.success(false))
            }
        }.resume()
    }
    
    func saveNewUsername(newUsername:String, oldUsername:String, accessToken:String, completion: @escaping (Result<ResponseFromServer<Bool>, UserErrors>) -> ()) {
        let queryItems = [
        URLQueryItem(name: "newUsername", value: newUsername),
        URLQueryItem(name: "oldUsername", value: oldUsername)
        ]
        let reqWithoutBody:URLRequest = networker.constructRequest(uri: "https://rosegoldgardens.com/api/users/change-username", token: accessToken, queryItems: queryItems)
        //let reqWithoutBody:URLRequest = networker.constructRequest(uri: "http://localhost:4000/api/users/change-username", token: accessToken, post: false)
        //let reqWithoutBody:URLRequest = networker.constructRequest(uri: "http://192.168.1.65:4000/api/users/change-username", queryItems: queryItems)
        
        let session = URLSession.shared
        session.dataTask(with: reqWithoutBody) {(data, response, error) in
            if error != nil {
                completion(.failure(.phoneFailure))
            }
            
            guard let data = data else {
                completion(.failure(.dataConversionError))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }
            
            let isOK = self.networker.checkOkStatus(res: response)
            if isOK {
                do {
                    let serverResponse = try JSONDecoder().decode(ResponseFromServer<Bool>.self, from: data)
                    completion(.success(serverResponse))
                } catch let convErr {
                    print(convErr.localizedDescription)
                }
            } else {
                completion(.failure(.dataConversionError))
            }
        }.resume()
    }
    
    func sendUsernameAndEmailForPasswordRecovery(email:String, completion: @escaping (Result<ResponseFromServer<String>, UserErrors>) -> ()) {
        let reqWithoutBody:URLRequest = networker.constructRequest(uri: "https://rosegoldgardens.com/api/users/forgot-password-step-one", post: true)
        //let reqWithoutBody:URLRequest = networker.constructRequest(uri: "http://localhost:4000/api/users/forgot-password-step-one", post: true)
        //let reqWithoutBody:URLRequest = networker.constructRequest(uri: "http://192.168.1.65:4000/api/users/forgot-password-step-one", post: true)
        let session = URLSession.shared
        let body = ["emailAddress": email]
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
        session.dataTask(with: request) {(data, response, error) in
            if error != nil {
                print("there was an error with the request")
                completion(.failure(.serverError))
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.dataConversionError))
                return
            }
            
            let isOK = self.networker.checkOkStatus(res: response)
            if isOK {
                do {
                    let securityCode = try JSONDecoder().decode(ResponseFromServer<String>.self, from: data)
                    completion(.success(securityCode))
                } catch let secCodeError {
                    print(secCodeError.localizedDescription)
                    completion(.failure(.dataConversionError))
                }
            } else {
                if response.statusCode == 404 {
                    completion(.failure(.userNotFound))
                } else {
                    completion(.failure(.serverError))
                }
            }
        }.resume()
    }
    
    func checkSecurityCode(email:String, securityCode: String, completion: @escaping (Result<Bool, UserErrors>) -> ()) {
        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "https://rosegoldgardens.com/api/users/check-sec-code", post: true)
        //let reqWithoutBody: URLRequest = networker.constructRequest(uri: "http://localhost:4000/api/users/check-sec-code", post: true)
        //let reqWithoutBody: URLRequest = networker.constructRequest(uri: "http://192.168.1.65:4000/api/users/check-sec-code", post: true)
        
        let session = URLSession.shared
        let body = ["emailAddress": email, "securityCode": securityCode]
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
        session.dataTask(with: request) {(data, response, error) in
            if error != nil {
                print("error occurred")
                completion(.failure(.failure))
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }
            let isOK = self.networker.checkOkStatus(res: response)
            if isOK {
                completion(.success(true))
            } else {
                completion(.success(false))
            }
        }.resume()
    }
    
    func deleteUser(token:String, completion: @escaping (Result<Bool, DeleteUserErrrors>) -> ()) {
        let url = URL(string: "https://rosegoldgardens.com/api/users/delete-user")!
        var request = URLRequest(url: url)
        
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            guard error == nil else {
                completion(.failure(.serverError))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }
            
            guard response.statusCode == 200 else {
                completion(.failure(.serverError))
                return
            }
            
            completion(.success(true))

        }.resume()
    }
    
    func saveNewAddress(newAddress:String, newCity:String, newState:String, newZipCode:UInt, newGeoLocation:String, token: String, completion: @escaping (Result<ResponseFromServer<Bool>, SupportErrors>) -> ()) {
        let request = networker.constructRequest(uri: "https://rosegoldgardens.com/api/users/change-address", token: token, post: true)
        let body:[String:Any] = ["newAddress":newAddress, "newCity":newCity, "newState":newState, "newZip":newZipCode, "newGeolocation":newGeoLocation]
        let req = networker.buildReqBody(req: request, body: body)
        
        URLSession.shared.dataTask(with: req) {[weak self] (_, response, error) in
            if error != nil {
                let resFromServer = ResponseFromServer<Bool>(data: false, error: [], newToken: nil)
                completion(.success(resFromServer))
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }
            
            let isOK = self?.networker.checkOkStatus(res: response)
            
            if let isOK = isOK {
                if isOK {
                    let resFromServer = ResponseFromServer<Bool>(data: true, error: [], newToken: nil)
                    completion(.success(resFromServer))
                } else if response.statusCode ~= 403 {
                    completion(.failure(.tokenExpired))
                } else {
                    completion(.failure(.serverError))
                }
            }
        }.resume()
    }
    
    func fetchCurrentAddress(accountId: UInt, token: String, completion: @escaping (Result<ResponseFromServer<AddressInfo>, AccountDetailsErrors>) -> ()) {
        let queryItem = [URLQueryItem(name: "accountId", value: "\(accountId)")]
        let request = networker.constructRequest(uri: "https://rosegoldgardens.com/api/users/address-details", token: token, queryItems: queryItem)
        
        URLSession.shared.dataTask(with: request) {(data, response, err) in
            if err != nil {
                completion(.failure(.serverError))
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }
            
            guard response.statusCode != 403 else {
                completion(.failure(.tokenExpired))
                return
            }
            
            guard (200...299).contains(response.statusCode) else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let addy = try JSONDecoder().decode(ResponseFromServer<AddressInfo>.self, from: data)
                completion(.success(addy))
            } catch let acctErr {
                print(acctErr)
                completion(.failure(.dataDecodingError))
            }
        }.resume()
    }
    
    func fetchUsersItems(accountId: UInt, token: String, completion: @escaping (Result<ResponseFromServer<[ItemNameAndId]>, AccountDetailsErrors>) -> ()) {
        let queryItem = [URLQueryItem(name: "accountId", value: "\(accountId)")]
        let req = networker.constructRequest(uri: "https://rosegoldgardens.com/api/users/user-items", token: token, queryItems: queryItem)
        
        URLSession.shared.dataTask(with: req) { (data, response, error) in
            if error != nil {
                completion(.failure(.serverError))
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }
            
            guard response.statusCode != 403 else {
                completion(.failure(.tokenExpired))
                return
            }

            guard let data = data else {
                completion(.failure(.dataDecodingError))
                return
            }
            
            do {
                let itemData = try JSONDecoder().decode(ResponseFromServer<[ItemNameAndId]>.self, from: data)
                completion(.success(itemData))
            } catch let decodeError {
                print(decodeError.localizedDescription)
            }
        }.resume()
    }
    
    func changeAvatar(imgJpgData:Data, username:String, token:String, completion: @escaping (Result<ResponseFromServer<Bool>, UserErrors>) -> ()) {
        let serverUrl = URL(string: "https://rosegoldgardens.com/api/users/change-avatar")
        var urlRequest = URLRequest(url: serverUrl!)
        // construct the multipart request with the image data
        let boundary = UUID().uuidString
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // add the image data to the raw http request data
        var requestData = Data()
        requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        requestData.append("Content-Disposition: form-data; name=\"avatar\"; filename=\"\(username).jpg\"\r\n".data(using: .utf8)!)
        requestData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        requestData.append(imgJpgData)
        
        // finish the request
        requestData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        // now send off the request
        URLSession.shared.uploadTask(with: urlRequest, from: requestData) { (data, res, error) in
            if error != nil {
                completion(.failure(.serverError))
            }
          
            guard let res = res as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }
//            
            guard res.statusCode != 403, res.statusCode != 401 else {
                completion(.failure(.tokenExpired))
                return
            }
            
            guard let data = data else {
                completion(.failure(.responseConversionError))
                return
            }
//            
            do {
                let usrResponse = try JSONDecoder().decode(ResponseFromServer<Bool>.self, from: data)
                completion(.success(usrResponse))
            } catch let decodeErr {
                print(decodeErr)
                completion(.failure(.responseConversionError))
            }
            
        }.resume()
    }
    
    func registerUser(firstName: String, lastName: String, username:String, email:String, phone:String, pw:String, addy:String, zip:UInt, state:String, city:String, geolocation:String, avi:Data, defaultAvi:Bool = false, completion: @escaping (Result<Bool, RegistrationErrors>) -> ()) {
        let serverUrl = URL(string: "https://rosegoldgardens.com/api/users/register-user")
        //let serverUrl = URL(string: "http://localhost:4000/api/users/register-user")
        //let serverUrl = URL(string: "http://192.168.1.65:4000/api/users/register-user")
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
        
        // first name
        requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        requestData.append("Content-Disposition: form-data; name=\"firstName\"\r\n\r\n".data(using: .utf8)!)
        requestData.append("\(firstName)\r\n".data(using: .utf8)!)
        
        // last name
        requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        requestData.append("Content-Disposition: form-data; name=\"lastName\"\r\n\r\n".data(using: .utf8)!)
        requestData.append("\(lastName)\r\n".data(using: .utf8)!)
        
        // username
        requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        requestData.append("Content-Disposition: form-data; name=\"username\"\r\n\r\n".data(using: .utf8)!)
        requestData.append("\(username)\r\n".data(using: .utf8)!)
        
        // phone
        requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        requestData.append("Content-Disposition: form-data; name=\"phone\"\r\n\r\n".data(using: .utf8)!)
        requestData.append("\(phone)\r\n".data(using: .utf8)!)
        
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
            
            guard res.statusCode != 409 else {
                completion(.failure(.usernameTaken))
                return
            }
            
            guard res.statusCode != 410 else {
                completion(.failure(.emailTaken))
                return
            }
            
            if res.statusCode == 200 {
                completion(.success(true))
            } else {
                completion(.success(false))
            }
            
        }.resume()
    }
    
    func verifyAccount(userEmailAddress:String, userInformationHash:String, completion: @escaping (Result<Bool, AccountVerificationErrors>) -> ()) {
        let reqWithoutBody:URLRequest = networker.constructRequest(uri: "https://rosegoldgardens.com/api/users/confirm-account", post: true)
        //let reqWithoutBody:URLRequest = networker.constructRequest(uri: "http://localhost:4000/api/users/confirm-account", post: true)
        //let reqWithoutBody:URLRequest = networker.constructRequest(uri: "http://192.168.1.65:4000/api/users/confirm-account", post: true)
        
        // put the email address and the information hash into a request body
        let session = URLSession.shared
        let body = ["usersEmail": userEmailAddress, "userInformationHash": userInformationHash]
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(.failure(.failure))
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }
            
            switch(response.statusCode) {
                case 201:
                    print("account verified")
                    completion(.success(true))
                    break
                case 401:
                    print("attempted code was invalid")
                    completion(.failure(.wrongCode))
                    break
                case 404:
                    print("that user wasn't in the unverified table")
                    completion(.failure(.userNotFound))
                    break
                case 500:
                    print("the server had a problem")
                    completion(.failure(.serverSideError))
                    break
                default:
                    print("an unknown error occurred")
                    completion(.failure(.unknownError))
                    break
            }
        }.resume()
    }
    
    func login(username:String, pw: String, completion: @escaping (Result<ResponseFromServer<ServiceUser>, UserErrors>) -> ()) {

        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "https://rosegoldgardens.com/api/users/login", post: true)
        
        let session = URLSession.shared
        let body = ["username": username, "password": pw]
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)

        session.dataTask(with: request) { (data, response, err) in
            if err != nil {
                print("there was a big error: \(String(describing: err))")
                completion(.failure(.failure))
            }

            guard let response = response as? HTTPURLResponse else {
                return
            }

            guard response.statusCode == 200 else {
                completion(.failure(.badPassword))
                return
            }
            
            guard let data = data else {
                completion(.failure(.failure))
                return
            }

            do {
                let usrResponse = try JSONDecoder().decode(ResponseFromServer<ServiceUser>.self, from: data)
                completion(.success(usrResponse))
            } catch let decodeError {
                print(decodeError)
            }
        }.resume()
    }
    
    func loginWithEmail(email:String, pw:String, completion: @escaping (Result<ResponseFromServer<ServiceUser>, UserErrors>) -> ()) {
        let reqWithoutBody:URLRequest = networker.constructRequest(uri: "https://rosegoldgardens.com/api/users/login", post: true)
        //let reqWithoutBody:URLRequest = networker.constructRequest(uri: "http://192.168.1.65:4000/api/users/login", post: true)
        
        let session = URLSession.shared
        let body = ["email": email, "password": pw]
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
        
        session.dataTask(with: request) { (data, response, err) in
            if err != nil {
                print("there was a big error: \(String(describing: err))")
                completion(.failure(.failure))
            }
            
            guard let response = response as? HTTPURLResponse else {
                return
            }
            
            guard response.statusCode == 200 else {
                completion(.failure(.badCreds))
                return
            }
            
            guard let data = data else {
                print("was not able to safely unwrap the data response object: \(String(describing: data))")
                completion(.failure(.dataConversionError))
                return
            }
            
            do {
                let usrResponse = try JSONDecoder().decode(ResponseFromServer<ServiceUser>.self, from: data)
                completion(.success(usrResponse))
            } catch let decodeError {
                print(decodeError)
                completion(.failure(.dataConversionError))
            }
        }.resume()
    }
    
    func postNewPassword(securityCode:String, newPassword:String, completion: @escaping(Result<String, UserErrors>) -> ()) {
        let reqWithoutBody:URLRequest = networker.constructRequest(uri: "https://rosegoldgardens.com/api/users/forgot-password-reset", post: true)
        //let reqWithoutBody:URLRequest = networker.constructRequest(uri: "http://localhost:4000/api/users/forgot-password-reset", post: true)
        let session = URLSession.shared
        let body = ["securityCode": securityCode, "newPassword": newPassword]
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
        session.dataTask(with: request) {(data, response, error) in
            if error != nil {
                completion(.failure(.serverError))
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }
            
            if response.statusCode == 200 {
                completion(.success("OK"))
            } else {
                completion(.success("Failed"))
            }
        }.resume()
    }
    
    func logout() {
        self.deleteAccessToken()
        self.deleteUserFromDevice()
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
        
        if status == -25299 { // key already exists, so update it with new one
            updateAccessToken(newToken: accessToken)
        }
        // print("Save access token operation finished with status: \(status)")
    }
    
    func saveUserPassword(password: String, username: String) {
        let passwordData = password.data(using: String.Encoding.utf8)!
        let addQuery = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrLabel as String: self.keyChainPwLabel,
            kSecValueData as String: passwordData,
            kSecAttrAccount as String: username
        ] as CFDictionary
        
        let status = SecItemAdd(addQuery, nil)
        print("Save password operation finished with status: \(status)")
    }
    
    func loadUserPassword() -> String {
        let getquery = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrLabel as String: self.keyChainPwLabel,
            kSecReturnData: true,
            kSecReturnAttributes: true
        ] as CFDictionary
        
        var item: AnyObject?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        if status == errSecItemNotFound {
            print("no password in the keychain: \(status)")
        }
        print("Load password operation finished with status: \(status)")
        let dict = item as? NSDictionary

        if dict != nil {
            let keyData = dict![kSecValueData] as! Data
            //let username = dict![kSecAttrAccount] as! String
            let passwordData = String(data: keyData, encoding: .utf8)!

            return passwordData
        } else {
            return ""
        }
    }
    
    func updateUserPassword(newPassword:String) {
        let passwordData = newPassword.data(using: String.Encoding.utf8)!
        let searchQuery = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrLabel as String: self.keyChainPwLabel,
        ] as CFDictionary
        
        let changesQuery = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrLabel as String: self.keyChainPwLabel,
            kSecValueData as String: passwordData,
        ] as CFDictionary
        
        // execute the update
        let status = SecItemUpdate(searchQuery, changesQuery)
        
        print("update password operation finished with status: \(status)")
    }
    
    func saveUserToDevice(user: ServiceUser) {
        let defaults: UserDefaults = .standard
        // store the user's info
        defaults.set(user.username, forKey: "rg-username")
        defaults.set(user.accountId, forKey: "rg-accountId")
        defaults.set(user.avatarUrl, forKey: "rg-avatarUrl")
    }
    
    func deleteUserFromDevice() {
        let defaults: UserDefaults = .standard
//        defaults.removeObject(forKey: "rg-username")
        defaults.removeObject(forKey: "rg-accountId")
        defaults.removeObject(forKey: "rg-avatarUrl")
    }
    
    func sendDeviceTokenToServer(deviceToken: String, accessToken: String) async throws -> String {
        if let baseUrl = networker.getUrlForEnv(appEnvironment: .Prod) {
            let url = "\(baseUrl)/api/users/store-device-token"
            let requestBody: [String: String] = ["deviceToken": deviceToken]
            let requestWithoutBody = networker.constructRequest(uri: url, token: accessToken, post: true)
            let request = networker.buildReqBody(req: requestWithoutBody, body: requestBody)
            let session = URLSession.shared
            
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw DeviceTokenErrors.responseConversionError
            }
            
            if httpResponse.statusCode == 200 {
                return DeviceTokenErrors.success.rawValue
            } else {
                return DeviceTokenErrors.serverError.rawValue
            }
        } else {
            throw DeviceTokenErrors.badURL
        }
    }
    
//    func loadUserFromDevice() -> ServiceUser? {
//        let defaults: UserDefaults = .standard
//        let username = defaults.string(forKey: "rg-username")
//        let accountId = defaults.integer(forKey: "rg-accountId")
//        let avatarUrl = defaults.string(forKey: "rg-avatarUrl")
//        guard
//            let username = username,
//            let avatarUrl = avatarUrl
//        else {
//            return nil
//        }
//
//         let serviceUser: ServiceUser = ServiceUser(avatarUrl: avatarUrl, accountId: UInt(accountId), username: username, accessToken: "")
//
//        return serviceUser
//    }
    
    func loadUsernameFromDevice() -> String {
        let defaults: UserDefaults = .standard
        let username = defaults.string(forKey: "rg-username")
        guard let username = username else {
            return ""
        }
        
        return username
    }
    
    func loadUserFromWebStore() {}
    
    func loadAccountId() -> UInt {
        let defaults: UserDefaults = .standard
        let accountId = defaults.integer(forKey: "rg-accountId")
        
        return UInt(accountId)
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

enum RegistrationErrors: String, Error {
    case tokenExpired = "The access token has expired. Time to issue a new one"
    case requestError = "There was a problem making the request."
    case serverError = "There was an error with the request on the server."
    case usernameTaken = "That username isn't available"
    case emailTaken = "That email address isn't available"
    case responseConversionError = "Unable to decode http response."
}

enum AccountDetailsErrors: String, Error {
    case serverError = "There was an error processing the request."
    case tokenExpired = "The access token has expired. Time to issue a new one."
    case dataDecodingError = "There was a problem decoding the data."
    case responseConversionError = "Unable to decode http response."
}

enum DeleteUserErrrors: String, Error {
    case serverError = "There was an error processing the request."
    case tokenExpired = "The access token has expired. Time to issue a new one."
    case dataDecodingError = "There was a problem decoding the data."
    case responseConversionError = "Unable to decode http response."
}
