//
//  MessagingService.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/3/22.
//

import Foundation

struct MessagingService {
    let networker = Networker()
    
    func fetchLatestMessageInEachChat(userId: UInt, token:String, completion: @escaping (Result<ResponseFromServer<[ChatDataForPreview]>, MessageErrors>) -> ()) {
        //let url = "http://192.168.1.65:4000/api/chat-handler/latest-messages?accountId=\(userId)"
        let url = "https://rosegoldgardens.com/api/chat-handler/latest-messages?accountId=\(userId)"
        let request = networker.constructRequest(uri: url, token: token)
        
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
                
                let chatData = try decoder.decode(ResponseFromServer<[ChatDataForPreview]>.self, from: data)
                completion(.success(chatData))
            } catch let error {
                print(error)
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func fetchMessageThreadBetweenUsers(viewingAccountId:UInt, otherUserAccountId:UInt, token: String, completion: @escaping (Result<ResponseFromServer<[ChatData]>, MessageErrors>) -> ()) {
        let url = "https://rosegoldgardens.com/api/chat-handler/get-chat-thread?viewingAccount=\(viewingAccountId)&otherUserAccount=\(otherUserAccountId)"
        let request = networker.constructRequest(uri: url, token: token)
        
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
                
                let chatData = try decoder.decode(ResponseFromServer<[ChatData]>.self, from: data)
                completion(.success(chatData))
            } catch let error {
                print(error)
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func getOtherChatParticipantName(accountId: UInt, token: String, completion: @escaping (Result<String, UserErrors>) -> ()) {
        let url = "https://rosegoldgardens.com/api/chat-handler/get-username"
        let request = networker.constructRequest(uri: url, token: token)
        
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
        }.resume()
    }
}
