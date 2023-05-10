//
//  SubscriptionHandler.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 5/8/23.
//

import Foundation
import StoreKit
import SwiftUI

@MainActor
final class SubscriptionHandler: ObservableObject {
    private let productIds = ["tier_1_users", "tier_2_users"]
    private var updates: Task<Void, Never>? = nil
    static let userDefaults = UserDefaults(suiteName: "RoseGoldMarket")
    
    @AppStorage("FirstInstallation", store: userDefaults) var installationDate: String = ""
    
    @Published private(set) var purchasedProductIDs = Set<String>()
    @Published var products: [Product] = []
    @Published var subExpirationDate: Date? = nil
    @Published var subPurchaseLoading = false
    
    var isSubscribed:Bool {
        return !self.purchasedProductIDs.isEmpty
    }
    
    init() {
        updates = observeTransactionUpdates()
        
        // set the first date that the app was installed
        if installationDate.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            self.installationDate = dateFormatter.string(from: Date())
        }
    }
    
    deinit {
        updates?.cancel()
    }
                      
    func fetchSubscriptions() async throws {
        let subs = try await Product.products(for: self.productIds)
        self.products = subs
    }
    
    func checkSubscriptionStatus() async {
        // get an array of transactions that are active for the usr
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                print("not verified")
                continue
            }
            
            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
            
            if let expirationDate = transaction.expirationDate {
                self.subExpirationDate = expirationDate
            }
        }
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in Transaction.updates {
                await self.checkSubscriptionStatus()
            }
        }
    }
    
    func subscriptionOverWithinFiveDays() -> Bool? {
        guard let subExpirationDate = self.subExpirationDate else {
            print("expiration date not set")
            return nil
        }
        
        let hoursUntilExpiration = subExpirationDate.timeIntervalSince(Date()) / 3600 // divide by how many secs are in an hour to get hours
        
        if hoursUntilExpiration <  120 {
            return true
        } else {
            return false
        }
    }
    
    func firstMonthOver() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        if let date = dateFormatter.date(from: self.installationDate) {
            let daysFromInstallation = date.timeIntervalSinceNow / 86400 // secs in a day to get days
            
            if daysFromInstallation > 30 {
                return true
            } else {
                return false
            }
        } else {
            print("invalid date format")
            return false
        }
    }
    
    func purchase(_ product: Product) async throws {
        self.subPurchaseLoading = true
        let result = try await product.purchase()
        
        switch result {
            case let .success(.verified(transaction)):
                // Successful purhcase
                await transaction.finish()
                await self.checkSubscriptionStatus() // update product array with new purchase
            case let .success(.unverified(_, error)):
                // Successful purchase but transaction/receipt can't be verified
                // Could be a jailbroken phone
                break
            case .pending:
                // Transaction waiting on SCA (Strong Customer Authentication) or
                // approval from Ask to Buy
                break
            case .userCancelled:
                // ^^^
                break
            @unknown default:
                break
        }
        self.subPurchaseLoading = false
    }
}
