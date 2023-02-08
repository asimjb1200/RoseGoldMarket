//
//  MessagingService.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/3/22.
//

import Foundation

struct MessagingService {
    let networker = Networker()
    
    func fetchAllThreadsForUser(userId: UInt, token: String, completion: @escaping (Result<ResponseFromServer<[String: [ChatData]]>, MessageErrors>) -> ()) {
        let request = networker.constructRequest(uri: "https://rosegoldgardens.com/api/chat-handler/chat-history?accountId=\(userId)", token: token, post: false)
        
        URLSession.shared.dataTask(with: request) {(data, response, err) in
            guard err == nil else {
                completion(.failure(.genError))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.decodingError))
                return
            }
            
            guard response.statusCode != 403 else {
                completion(.failure(.tokenExpired))
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
                completion(.success(chatData))
            } catch let error {
                print(error)
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func fetchLatestMessageInEachChat(userId: UInt, completion: @escaping (Result<[ChatDataForPreview], MessageErrors>) -> ()) {
        let url = "http://192.168.1.65:4000/api/chat-handler/latest-messages?accountId=\(userId)"
        let request = networker.constructRequest(uri: url)
        
        URLSession.shared.dataTask(with: request) { (data, response, err) in
            guard err == nil else {
                print(err)
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
                
                let chatData = try decoder.decode([ChatDataForPreview].self, from: data)
                completion(.success(chatData))
            } catch let error {
                print(error)
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func fetchMessageThreadBetweenUsers(viewingAccountId:UInt, otherUserAccountId:UInt, completion: @escaping (Result<[ChatData], MessageErrors>) -> ()) {
        let url = "http://192.168.1.65:4000/api/chat-handler/get-chat-thread?viewingAccount=\(viewingAccountId)&otherUserAccount=\(otherUserAccountId)"
        let request = networker.constructRequest(uri: url)
        
        URLSession.shared.dataTask(with: request) { (data, response, err) in
            guard err == nil else {
                print("main err: \(err)")
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
                
                let chatData = try decoder.decode([ChatData].self, from: data)
                completion(.success(chatData))
            } catch let error {
                print(error)
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func getOtherChatParticipantName(accountId: UInt, completion: @escaping (Result<String, UserErrors>) -> ()) {
        let url = "http://192.168.1.65:4000/api/chat-handler/get-username"
        let request = networker.constructRequest(uri: url)
        
        URLSession.shared.dataTask(with: request) { (data, response, err) in
            guard err == nil else {
                print(err)
                return
            }
            
            guard let data = data else {
                completion(.failure(.dataConversionError))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                
                let username = try decoder.decode(String.self, from: data)
                completion(.success(username))
            } catch let error {
                print(error)
                completion(.failure(.serverError))
            }
        }
    }
}
