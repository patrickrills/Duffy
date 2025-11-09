//
//  TipService.swift
//  Duffy
//
//  Created by Patrick Rills on 5/15/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import Foundation
import StoreKit

@available(watchOS 8.0, iOS 15.0, *)
public class TipService {
    
    private static let instance: TipService = TipService()
    
    private var transactionListenerTask: Task<Void, Never>?
    
    public init() {
        transactionListenerTask = listenForTransactions()
    }
    
    deinit {
        transactionListenerTask?.cancel()
    }
    
    public class func getInstance() -> TipService {
        return instance
    }
    
    public func initialize() {
        Task {
            await loadProducts()
        }
    }
    
    private lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    private var productCache: [TipIdentifier : Product] = [:]
    private var options: [TipOption] {
        return productCache.map { key, value in
            currencyFormatter.locale = value.priceFormatStyle.locale
            return TipOption(identifier: key, formattedPrice: value.displayPrice, price: value.price)
        }
    }
    
    public func tipOptions(_ completionHandler: @escaping (Result<[TipOption], StoreKitError>) -> ()) {
        Task {
            do {
                if productCache.isEmpty {
                    try await loadProducts()
                }
                completionHandler(.success(options))
            } catch {
                completionHandler(.failure(.wrapped(error)))
            }
        }
    }
    
    public func tip(productId: TipIdentifier, completionHandler: @escaping (Result<TipIdentifier, StoreKitError>) -> ()) {
        Task {
            guard let tipProduct = productCache[productId] else {
                completionHandler(.failure(.productDownloadFailed))
                return
            }
            
            do {
                let result = try await tipProduct.purchase()
                
                switch result {
                case .success(let verification):
                    let transaction = try checkVerified(verification)
                    await transaction.finish()
                    archiveTip(productId)
                    completionHandler(.success(productId))
                    
                case .userCancelled:
                    completionHandler(.failure(.purchaseFailed))
                    
                case .pending:
                    completionHandler(.failure(.purchaseFailed))
                    
                @unknown default:
                    completionHandler(.failure(.purchaseFailed))
                }
            } catch {
                completionHandler(.failure(.wrapped(error)))
            }
        }
    }
    
    private func loadProducts() async throws {
        let products = try await Product.products(for: TipIdentifier.allCases.map { $0.rawValue })
        
        guard !products.isEmpty else {
            throw StoreKitError.productDownloadFailed
        }
        
        productCache = products.reduce(into: [:]) { result, product in
            if let tipId = TipIdentifier(rawValue: product.id) {
                result[tipId] = product
            }
        }
    }
    
    private func listenForTransactions() -> Task<Void, Never> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    if let tipId = TipIdentifier(rawValue: transaction.productID) {
                        self.archiveTip(tipId)
                    }
                    
                    await transaction.finish()
                } catch {
                    LoggingService.log(error: error)
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.purchaseFailed
        case .verified(let safe):
            return safe
        }
    }
    
    private static let ARCHIVE_KEY: String = "tipArchive"
    
    public func archive() -> [TipArchiveEntry] {
        guard let archiveData = UserDefaults.standard.data(forKey: Self.ARCHIVE_KEY),
              let archiveEntries = try? PropertyListDecoder().decode([TipArchiveEntry].self, from: archiveData)
        else {
            return []
        }
        
        return archiveEntries
    }
    
    public func archiveTip(_ identifier: TipIdentifier) {
        var newArchive = [TipArchiveEntry]()
        newArchive.append(contentsOf: archive())
        newArchive.append(TipArchiveEntry(date: Date(), identifier: identifier))
        
        if let newData = try? PropertyListEncoder().encode(newArchive) {
            UserDefaults.standard.set(newData, forKey: Self.ARCHIVE_KEY)
        }
    }
}
