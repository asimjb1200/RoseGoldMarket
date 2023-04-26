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
        let queryItem = [URLQueryItem(name: "accountId", value: "\(userId)")]
        guard let urlBase = networker.getUrlForEnv(appEnvironment: .Prod) else {
            print("not able to get url base")
            return
        }
        let url = "\(urlBase)/api/chat-handler/latest-messages"
        let request = networker.constructRequest(uri: url, token: token, queryItems: queryItem)
        
        URLSession.shared.dataTask(with: request) { (data, response, err) in
            guard err == nil else {
                print(err?.localizedDescription ?? "couldn't get the error")
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
    
    func fetchUnreadMessagesForUser(viewingUserId: UInt, token: String, completion: @escaping (Result<ResponseFromServer<[UnreadMessage]>, MessageErrors>) -> ()) {
        guard let urlBase = networker.getUrlForEnv(appEnvironment: .Prod) else {
            print("not able to get url base")
            return
        }
        let url = "\(urlBase)/api/chat-handler/get-unread-messages"
        
        let request = networker.constructRequest(uri: url, token: token)
        
        URLSession.shared.dataTask(with: request) {(data, response, error) in
            guard error == nil else {
                print(error?.localizedDescription ?? "couldn't get the error")
                return
            }
            
            guard let data = data else {
                completion(.failure(.decodingError))
                return
            }

            do {
                let chatData = try JSONDecoder().decode(ResponseFromServer<[UnreadMessage]>.self, from: data)
                completion(.success(chatData))
            } catch let error {
                print(error)
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func deleteUnreadMessageRecordsForChat(senderId: UInt, token: String, completion: @escaping (Result<ResponseFromServer<Bool>, MessageErrors>) -> ()) {
        guard let urlBase = networker.getUrlForEnv(appEnvironment: .Prod) else {
            return
        }
        let url = "\(urlBase)/api/chat-handler/delete-from-unread"
        let requestWithoutBody = networker.constructRequest(uri: url, token: token, deleteReq: true)
        let request = networker.buildReqBody(req: requestWithoutBody, body: ["senderId": senderId])
        
        URLSession.shared.dataTask(with: request) { (data, response, err) in
            guard err == nil else {
                print("big error occurred: \(String(describing: err))")
                return
            }
            
            guard let data = data else {
                completion(.failure(.decodingError))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseDecodingError))
                return
            }
            
            if response.statusCode == 200 {
                do {
                    let chatDeletion = try JSONDecoder().decode(ResponseFromServer<Bool>.self, from: data)
                    completion(.success(chatDeletion))
                } catch let error {
                    print(error.localizedDescription)
                    completion(.failure(.decodingError))
                }
            } else {
                let resFromServer = ResponseFromServer<Bool>(data: false, error: [], newToken: nil)
                completion(.success(resFromServer))
            }
            
        }.resume()
        
    }
    
    func fetchMessageThreadBetweenUsers(viewingAccountId:UInt, otherUserAccountId:UInt, token: String, completion: @escaping (Result<ResponseFromServer<[ChatData]>, MessageErrors>) -> ()) {
        let queryItems = [
            URLQueryItem(name: "viewingAccount", value: "\(viewingAccountId)"),
            URLQueryItem(name: "otherUserAccount", value: "\(otherUserAccountId)")
        ]
        guard let urlBase = networker.getUrlForEnv(appEnvironment: .Prod) else {
            print("not able to get url base")
            return
        }
        let url = "\(urlBase)/api/chat-handler/get-chat-thread"
        let request = networker.constructRequest(uri: url, token: token, queryItems: queryItems)
        
        URLSession.shared.dataTask(with: request) { (data, response, err) in
            guard err == nil else {
                print("main err: \(String(describing: err))")
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
        guard let urlBase = networker.getUrlForEnv(appEnvironment: .Prod) else {
            print("not able to get url base")
            return
        }
        let url = "\(urlBase)/api/chat-handler/get-username"
        let request = networker.constructRequest(uri: url, token: token)
        
        URLSession.shared.dataTask(with: request) { (data, response, err) in
            guard err == nil else {
                print(String(describing: err))
                return
            }
            
            guard let data = data else {
                completion(.failure(.dataConversionError))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                
                let username = try decoder.decode(String.self, from: data)
                completion(.success(username))
            } catch let error {
                print(error)
                completion(.failure(.serverError))
            }
        }.resume()
    }
}
