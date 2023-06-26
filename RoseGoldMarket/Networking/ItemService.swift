//
//  ItemService.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import Foundation
import Alamofire

struct ItemService {
    func postItem(itemData items: ItemForBackend, token: String, completion: @escaping (Result<ResponseFromServer<String>, ItemErrors>) -> ()) {
        let networker = Networker()
        let serverUrl = URL(string: "https://rosegoldgardens.com/api/item-handler/add-items")
        var urlRequest = URLRequest(url: serverUrl!)
        
        let boundary = UUID().uuidString
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
          
        let requestData = networker.buildMultipartImageRequest(boundary: boundary, item: items)
        urlRequest.httpBody = requestData
        
        URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
            guard error == nil else {
                completion(.failure(.genError))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                print("error unwrapping response")
                completion(.failure(.genError))
                return
            }

            guard response.statusCode != 403 else {
                completion(.failure(.tokenExpired))
                return
            }

            guard response.statusCode == 201 else {
                print("the request failed")
                completion(.failure(.genError))
                return
            }


            guard let data = data else {
                print("problem decoding data")
                completion(.failure(.genError))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(ResponseFromServer<String>.self, from: data)
                print("Data posted")
                completion(.success(decoded))
                return
            } catch let err {
                print("\(err.localizedDescription)")
                completion(.failure(.genError))
                return
            }
        }.resume()
    }
    
    func updateItemAvailability(itemId: UInt, itemIsAvailable: Bool, token: String, completion: @escaping (Result<ResponseFromServer<Bool>, ItemErrors>) -> ()) {
        let networker = Networker()
        guard let urlBase = networker.getUrlForEnv(appEnvironment: .Prod) else {
            print("not able to get url base")
            return
        }
        let url = "\(urlBase)/api/item-handler/toggle-item-availability"
        let requestWithoutBody = networker.constructRequest(uri: url, token: token, post: true)
        let reqBody: [String: Any] = ["itemId": itemId, "itemIsAvailable": itemIsAvailable]
        let request = networker.buildReqBody(req: requestWithoutBody, body: reqBody)
        
        URLSession.shared.dataTask(with: request) {(data, response, err) in
            guard err == nil else {
                completion(.failure(.genError))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.genError))
                return
            }
            
            guard response.statusCode != 403 else {
                completion(.failure(.tokenExpired))
                return
            }
            
            guard response.statusCode == 200 else {
                completion(.failure(.badStatusCode))
                return
            }
            
            guard let data = data else {
                print("couldn't unwrap the data")
                completion(.failure(.dataConversionError))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let itemsResponse = try decoder.decode(ResponseFromServer<Bool>.self, from: data)
                completion(.success(itemsResponse))
            } catch let dataError {
                print(dataError.localizedDescription)
            }
        }.resume()
    }
    
    func retrieveItemsV2(categoryIdFilters: [UInt], limit: UInt, offset: UInt, longAndLat: String, miles: UInt, searchTerm: String, token: String) async throws -> ResponseFromServer<[Item]> {
        
        let networker = Networker()
        let url = networker.getUrlForEnv(appEnvironment: .Prod)
        guard let url = url else { throw ItemErrors.urlError }
        let urlRequest = networker.constructRequest(uri: "\(url)/api/item-handler/fetch-filtered-items", token: token , post: true)
        
        let body: [String:Any] = [
            "categories": categoryIdFilters,
            "limit": limit,
            "offset": offset,
            "longAndLat": longAndLat,
            "miles": miles,
            "searchTerm": searchTerm
        ]
        
        let request = networker.buildReqBody(req: urlRequest, body: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw ItemErrors.responseConversionError
        }
        
        guard response.statusCode != 403 else {
            throw ItemErrors.tokenExpired
        }
        
        guard response.statusCode != 404 else {
            let resData = ResponseFromServer<[Item]>(data: [], error: [], newToken: nil)
            return resData
        }
        
        guard response.statusCode == 200 else {
            print("The status wasn't ok")
            throw ItemErrors.badStatusCode
        }

        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let itemsResponse = try decoder.decode(ResponseFromServer<[Item]>.self, from: data)
        return itemsResponse
    }
    
    func retrieveItemsForAccount(accountId: UInt, token: String, completion: @escaping (Result<ResponseFromServer<[Item]>, ItemErrors>) -> ()) {
        let networker = Networker()
        let queryItem = [URLQueryItem(name: "accountId", value: "\(accountId)")]
        let req = networker.constructRequest(uri: "https://rosegoldgardens.com/api/users/items", token: token, queryItems: queryItem)
        
        URLSession.shared.dataTask(with: req) {(data, response, err) in
            guard err == nil else {
                completion(.failure(.genError))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.genError))
                return
            }
            
            guard response.statusCode != 403 else {
                completion(.failure(.tokenExpired))
                return
            }
            
            guard response.statusCode == 200 else {
                print("The status wasn't ok")
                completion(.failure(.genError))
                return
            }
            
            guard let data = data else {
                print("couldn't unwrap the data")
                completion(.failure(.genError))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                let itemsResponse = try decoder.decode(ResponseFromServer<[Item]>.self, from: data)
                completion(.success(itemsResponse))
            } catch let error {
                print(error)
            }
        }.resume()
    }
    
    func retrieveItemsForAccountV2(accountId: UInt, token: String) async throws -> ResponseFromServer<[Item]> {
        let networker = Networker()
        let queryItem = [URLQueryItem(name: "accountId", value: "\(accountId)")]
        guard let baseUrl = networker.getUrlForEnv(appEnvironment: .Prod) else {throw ItemErrors.urlError}
        let req = networker.constructRequest(uri: "\(baseUrl)/api/users/items", token: token, queryItems: queryItem)
        
        let (data, response) = try await URLSession.shared.data(for: req)
        
        guard let response = response as? HTTPURLResponse else {
            throw ItemErrors.responseConversionError
        }
        
        guard response.statusCode != 403 else {
            throw ItemErrors.tokenExpired
        }
        
        guard response.statusCode != 404 else {
            let resData = ResponseFromServer<[Item]>(data: [], error: [], newToken: nil)
            return resData
        }
        
        guard response.statusCode == 200 else {
            throw ItemErrors.badStatusCode
        }
        
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let itemsResponse = try decoder.decode(ResponseFromServer<[Item]>.self, from: data)
        
        return itemsResponse
    }
    
    func retrieveItemById(itemId:UInt, token: String, completion: @escaping (Result<ResponseFromServer<Item>, ItemErrors>) -> ()) {
        let queryItem = [URLQueryItem(name: "itemId", value: "\(itemId)")]
        let req = Networker().constructRequest(uri: "https://rosegoldgardens.com/api/item-handler/item-details-for-edit", token: token, queryItems: queryItem)
        
        URLSession.shared.dataTask(with: req) { (data, response, err) in
            if err != nil {
                completion(.failure(.genError))
            }
            
            guard let data = data else {
                completion(.failure(.genError))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                return
            }
            
            guard response.statusCode != 403 else {
                completion(.failure(.tokenExpired))
                return
            }

            
            do {
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let itemData = try decoder.decode(ResponseFromServer<Item>.self, from: data)
                completion(.success(itemData))
            } catch let itemError {
                print(itemError)
                completion(.failure(.genError))
            }
        }.resume()
    }
    
    func deleteItem(itemId:UInt, itemName:String, token: String, completion: @escaping (Result<ResponseFromServer<Bool>, ItemErrors>) -> ()) {
        let queryItems = [URLQueryItem(name: "itemId", value: "\(itemId)"), URLQueryItem(name: "itemName", value: "\(itemName.replacingOccurrences(of: " ", with: "%20"))")]
        let url = URL(string: "https://rosegoldgardens.com/api/item-handler/delete-item")!
        let finalURL = url.appending(queryItems: queryItems)
        var request = URLRequest(url: finalURL)
        
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(.failure(.genError))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                return
            }
            
            guard response.statusCode != 403 else {
                completion(.failure(.tokenExpired))
                return
            }

            
            guard let data = data else {
                return
            }

            do {
                let dataPosted = try JSONDecoder().decode(ResponseFromServer<Bool>.self, from: data)
                completion(.success(dataPosted))
            } catch let apiErr {
                print(apiErr)
            }
        }.resume()
    }
    
    func updateCategories(newCategories: [UInt], itemId: UInt, token: String, completion: @escaping (Result<ResponseFromServer<Bool>, ItemErrors>) -> ()) {
        let networker = Networker()
        //let serverUrl = URL(string: "https://rosegoldgardens.com/api/item-handler/edit-item-categories")
        
        let req = networker.constructRequest(uri: "https://rosegoldgardens.com/api/item-handler/edit-item-categories", token: token, post: true)
        let body: [String: Any] = ["categories": newCategories, "itemId": itemId]
        let reqWithBody = networker.buildReqBody(req: req, body: body)
        
        URLSession.shared.dataTask(with: reqWithBody) {(data, response, err) in
            guard err == nil else {
                completion(.failure(.genError))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.genError))
                return
            }
            
            guard response.statusCode != 403 else {
                completion(.failure(.tokenExpired))
                return
            }
            
            guard response.statusCode == 200 else {
                print("the request failed")
                completion(.failure(.genError))
                return
            }

            
            guard let data = data else {
                print("problem decoding data")
                completion(.failure(.genError))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(ResponseFromServer<Bool>.self, from: data)
                print("Data posted")
                completion(.success(decoded))
                return
            } catch let err {
                print("\(err.localizedDescription)")
                completion(.failure(.genError))
                return
            }
        }.resume()
    }
    
    func updateItem(itemData items: ItemForBackend, itemId:UInt, token: String, completion: @escaping (Result<ResponseFromServer<String>, ItemErrors>) -> ()) {
        let networker = Networker()
        let serverUrl = URL(string: "https://rosegoldgardens.com/api/item-handler/edit-item")
        var urlRequest = URLRequest(url: serverUrl!)
        
        let boundary = UUID().uuidString
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let requestData = networker.buildMultipartImageRequest(boundary: boundary, item: items, itemId: itemId)
        
        URLSession.shared.uploadTask(with: urlRequest, from: requestData) {(data, response, error) in
            guard error == nil else {
                completion(.failure(.genError))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("error unwrapping response")
                completion(.failure(.genError))
                return
            }
            
            guard response.statusCode != 403 else {
                completion(.failure(.tokenExpired))
                return
            }
            
            guard response.statusCode == 201 else {
                print("the request failed")
                completion(.failure(.genError))
                return
            }

            
            guard let data = data else {
                print("problem decoding data")
                completion(.failure(.genError))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(ResponseFromServer<String>.self, from: data)
                print("Data posted")
                completion(.success(decoded))
                return
            } catch let err {
                print("\(err.localizedDescription)")
                completion(.failure(.genError))
                return
            }
        }.resume()
    }
}

enum ItemErrors: String, Error {
    case genError = "error occurred"
    case urlError = "couldnt get url"
    case tokenExpired = "The access token has expired. Time to issue a new one"
    case responseConversionError = "could not convert the response object to an HTTPResponse"
    case dataConversionError = "was not able to convert the data object to a known type"
    case badStatusCode = "the status code indicated that there was a big problem"
}
