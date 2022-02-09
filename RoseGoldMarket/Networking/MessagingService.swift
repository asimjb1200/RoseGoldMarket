//
//  MessagingService.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/3/22.
//

import Foundation

struct MessagingService {
    let networker = Networker()
    
    func fetchMessagesFromUser(senderId: UInt, receiverId: UInt) {
        
    }
    
    func fetchAllThreadsForUser(userId: UInt, completion: @escaping (Result<[String: [ChatData]], MessageErrors>) -> ()) {
        let request = networker.constructRequest(uri: "http://localhost:4000/chat-handler/chat-history?accountId=\(userId)", post: false)
        
        URLSession.shared.dataTask(with: request) {(data, response, err) in
            guard err == nil else {
                completion(.failure(.genError))
                return
            }
            
            guard let _ = response as? HTTPURLResponse else {
                completion(.failure(.decodingError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.decodingError))
                return
            }

            do {
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                
                // handle the UTC date type that will be coming through the wire
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let chatData = try decoder.decode(ResponseFromServer<[String: [ChatData]]>.self, from: data)
                completion(.success(chatData.data))
            } catch let error {
                print(error)
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}
