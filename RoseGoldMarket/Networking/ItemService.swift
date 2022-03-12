//
//  ItemService.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import Foundation

struct ItemService {
    func postItem(itemData items: ItemForBackend, completion: @escaping (Result<String, ItemErrors>) -> ()) {
        let networker = Networker()
        let serverUrl = URL(string: "http://localhost:4000/item-handler/add-items")
        var urlRequest = URLRequest(url: serverUrl!)
        
        let boundary = UUID().uuidString
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let requestData = networker.buildMultipartImageRequest(boundary: boundary, item: items)
        
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
                let decoded = try JSONDecoder().decode(String.self, from: data)
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
    
    func retrieveItems(categoryIdFilters: [UInt], limit: UInt, offset: UInt, longAndLat: String, miles: UInt, searchTerm: String, completion: @escaping (Result<[Item], ItemErrors>) -> ()) {
        let networker = Networker()
        let urlRequest = networker.constructRequest(uri: "http://localhost:4000/item-handler/fetch-filtered-items", post: true)
        
        let body: [String:Any] = [
            "categories": categoryIdFilters,
            "limit": limit,
            "offset": offset,
            "longAndLat": longAndLat,
            "miles": miles,
            "searchTerm": searchTerm
        ]
        
        let request = networker.buildReqBody(req: urlRequest, body: body)
        
        URLSession.shared.dataTask(with: request) {(data, response, err) in
            guard err == nil else {
                completion(.failure(.genError))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.genError))
                return
            }
            
            guard response.statusCode != 404 else {
                completion(.success([]))
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
                completion(.success(itemsResponse.data))
                //return
            } catch let decodeError {
                print(decodeError.localizedDescription)
                completion(.failure(.genError))
                //return
            }
        }.resume()
    }
    
    func retrieveItemsForAccount(accountId: UInt, completion: @escaping (Result<[Item], ItemErrors>) -> ()) {
        let networker = Networker()
        let req = networker.constructRequest(uri: "http://localhost:4000/users/items?accountId=\(accountId)")
        
        URLSession.shared.dataTask(with: req) {(data, response, err) in
            guard err == nil else {
                completion(.failure(.genError))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.genError))
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
                completion(.success(itemsResponse.data))
            } catch let error {
                print(error)
            }

        }.resume()
    }
    
    func retrieveItemById(itemId:UInt, completion: @escaping (Result<Item, ItemErrors>) -> ()) {
        let req = Networker().constructRequest(uri: "http://localhost:4000/item-handler/item-details-for-edit?itemId=\(itemId)", post: false)
        
        URLSession.shared.dataTask(with: req) { (data, _, err) in
            if err != nil {
                completion(.failure(.genError))
            }
            
            guard let data = data else {
                completion(.failure(.genError))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let itemData = try decoder.decode(Item.self, from: data)
                completion(.success(itemData))
            } catch let itemError {
                print(itemError)
                completion(.failure(.genError))
            }
        }.resume()
    }
    
    func deleteItem(itemId:UInt, itemName:String, completion: @escaping (Result<Bool, ItemErrors>) -> ()) {
        let url = URL(string: "http://localhost:4000/item-handler/delete-item?itemId=\(itemId)&itemName=\(itemName.replacingOccurrences(of: " ", with: "%20"))")!
        var request = URLRequest(url: url)
        
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if error != nil {
                completion(.failure(.genError))
            }
            
            guard let data = data else {
                return
            }

            do {
                let dataPosted = try JSONDecoder().decode(Bool.self, from: data)
                completion(.success(dataPosted))
            } catch let apiErr {
                print(apiErr)
            }
        }.resume()
    }
    
    func updateItem(itemData items: ItemForBackend, itemId:UInt, completion: @escaping (Result<String, ItemErrors>) -> ()) {
        let networker = Networker()
        let serverUrl = URL(string: "http://localhost:4000/item-handler/edit-item")
        var urlRequest = URLRequest(url: serverUrl!)
        
        let boundary = UUID().uuidString
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
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
                let decoded = try JSONDecoder().decode(String.self, from: data)
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
}
