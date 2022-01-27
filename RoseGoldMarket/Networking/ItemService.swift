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
}

enum ItemErrors: String, Error {
    case genError = "error occurred"
}
