//
//  ItemService.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import Foundation
import Alamofire

struct ItemService {

    func postItemV2(itemData items: ItemForBackend, token: String) async throws -> ResponseFromServer<String> {
        let networker = Networker()
        guard let urlBase = networker.getUrlForEnv(appEnvironment: .Prod) else {
            print("not able to get url base")
            throw ItemErrors.urlError
        }
        let serverUrl = URL(string: "\(urlBase)/api/item-handler/add-items")
        var urlRequest = URLRequest(url: serverUrl!)
        
        let boundary = UUID().uuidString
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
          
        let requestData = networker.buildMultipartImageRequest(boundary: boundary, item: items)
        urlRequest.httpBody = requestData
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse else {
            throw ItemErrors.responseConversionError
        }
        
        guard response.statusCode != 403 else {
            throw ItemErrors.tokenExpired
        }
        
        let decoded = try JSONDecoder().decode(ResponseFromServer<String>.self, from: data)

        return decoded
    }
    
    func updateItemAvailabilityV2(itemId: UInt, itemIsAvailable: Bool, token: String) async throws -> ResponseFromServer<Bool> {
        let networker = Networker()
        guard let urlBase = networker.getUrlForEnv(appEnvironment: .Prod) else {
            print("not able to get url base")
            throw ItemErrors.urlError
        }
        let url = "\(urlBase)/api/item-handler/toggle-item-availability"
        let requestWithoutBody = networker.constructRequest(uri: url, token: token, post: true)
        let reqBody: [String: Any] = ["itemId": itemId, "itemIsAvailable": itemIsAvailable]
        let request = networker.buildReqBody(req: requestWithoutBody, body: reqBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw ItemErrors.responseConversionError
        }
        
        guard response.statusCode != 403 else {
            throw ItemErrors.tokenExpired
        }
        
        do {
            let decoder = JSONDecoder()
            let itemsResponse = try decoder.decode(ResponseFromServer<Bool>.self, from: data)
            return itemsResponse
        } catch let dataError {
            throw ItemErrors.dataConversionError
        }
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
    
    func retrieveItemByIdV2(itemId:UInt, token: String) async throws -> ResponseFromServer<Item> {
        let queryItem = [URLQueryItem(name: "itemId", value: "\(itemId)")]
        let networker = Networker()
        guard let urlBase = networker.getUrlForEnv(appEnvironment: .Prod) else {
            print("not able to get url base")
            throw ItemErrors.urlError
        }
        let req = networker.constructRequest(uri: "\(urlBase)/api/item-handler/item-details-for-edit", token: token, queryItems: queryItem)
        
        let (data, response) = try await URLSession.shared.data(for: req)
        
        guard let response = response as? HTTPURLResponse else {
            throw ItemErrors.responseConversionError
        }
        
        guard response.statusCode != 403 else {
            throw ItemErrors.tokenExpired
        }
        
        do {
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let itemData = try decoder.decode(ResponseFromServer<Item>.self, from: data)
            return itemData
        } catch let itemError {
            print(itemError.localizedDescription)
            throw ItemErrors.dataConversionError
        }
    }
    
    func deleteItemV2(itemId:UInt, itemName:String, token: String) async throws -> ResponseFromServer<Bool> {
        let queryItems = [URLQueryItem(name: "itemId", value: "\(itemId)"), URLQueryItem(name: "itemName", value: "\(itemName.replacingOccurrences(of: " ", with: "%20"))")]
        let networker = Networker()
        guard let urlBase = networker.getUrlForEnv(appEnvironment: .Prod) else {
            print("not able to get url base")
            throw ItemErrors.urlError
        }

        let url = URL(string: "\(urlBase)/api/item-handler/delete-item")!
        let finalURL = url.appending(queryItems: queryItems)
        var request = URLRequest(url: finalURL)
        
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw ItemErrors.responseConversionError
        }
        
        guard response.statusCode != 403 else {
            throw ItemErrors.tokenExpired
        }
        
        do {
            let dataPosted = try JSONDecoder().decode(ResponseFromServer<Bool>.self, from: data)
            return dataPosted
        } catch let apiErr {
            print(apiErr.localizedDescription)
            throw ItemErrors.dataConversionError
        }
    }
    
    func updateCategoriesV2(newCategories: [UInt], itemId: UInt, token: String) async throws -> ResponseFromServer<Bool> {
        let networker = Networker()
        guard let urlBase = networker.getUrlForEnv(appEnvironment: .Prod) else {
            print("not able to get url base")
            throw ItemErrors.urlError
        }
        let req = networker.constructRequest(uri: "\(urlBase)/api/item-handler/edit-item-categories", token: token, post: true)
        let body: [String: Any] = ["categories": newCategories, "itemId": itemId]
        let reqWithBody = networker.buildReqBody(req: req, body: body)
        
        let (data, response) = try await URLSession.shared.data(for: reqWithBody)
        
        guard let response = response as? HTTPURLResponse else {
            throw ItemErrors.responseConversionError
        }
        
        guard response.statusCode != 403 else {
            throw ItemErrors.tokenExpired
        }
        
        do {
            let decoded = try JSONDecoder().decode(ResponseFromServer<Bool>.self, from: data)
            return decoded
        } catch let err {
            print("\(err.localizedDescription)")
            throw ItemErrors.dataConversionError
        }
    }
    
    func updateItemV2(itemData items: ItemForBackend, itemId:UInt, token: String) async throws -> ResponseFromServer<String> {
        let networker = Networker()
        guard let urlBase = networker.getUrlForEnv(appEnvironment: .Prod) else {
            print("not able to get url base")
            throw ItemErrors.urlError
        }
        let serverUrl = URL(string: "\(urlBase)/api/item-handler/edit-item")
        var urlRequest = URLRequest(url: serverUrl!)
        
        let boundary = UUID().uuidString
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let requestData = networker.buildMultipartImageRequest(boundary: boundary, item: items, itemId: itemId)
        
        let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: requestData)
        
        guard let response = response as? HTTPURLResponse else {
            print("error unwrapping response")
            throw ItemErrors.responseConversionError
        }
        
        guard response.statusCode != 403 else {
            throw ItemErrors.tokenExpired
        }
        
        guard response.statusCode == 201 else {
            print("the request failed to update the item")
            throw ItemErrors.badStatusCode
        }
        
        do {
            let decoded = try JSONDecoder().decode(ResponseFromServer<String>.self, from: data)
            return decoded
        } catch let err {
            print("\(err.localizedDescription)")
            throw ItemErrors.dataConversionError
        }
        
    }
}
