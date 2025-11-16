//
//  TipService.swift
//  Duffy
//
//  Created by Patrick Rills on 5/15/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import Foundation
import StoreKit

@available(watchOS 8.0, *)
public class TipService {
    
    private static let instance: TipService = TipService()
    
    public init() {
        
    }
    
    deinit {
        
    }
    
    public class func getInstance() -> TipService {
        return instance
    }
    
    public func initialize() {
        Task {
            do {
                try await loadProducts()
            } catch {
                LoggingService.log(error: error)
            }
        }
    }
    
    private var productCache: [TipIdentifier : Product] = [:]
    private var options: [TipOption] {
        return productCache.map { key, value in
            return TipOption(identifier: key, formattedPrice: value.displayPrice, price: value.price)
        }
    }
    
    public func tipOptions() async throws -> [TipOption] {
        if productCache.isEmpty {
            try await loadProducts()
        }
        
        return options
    }
    
    public func tip(productId: TipIdentifier) async throws -> TipIdentifier {
        guard let tipProduct = productCache[productId] else {
            throw StoreKitError.productDownloadFailed
        }
        
        let result = try await tipProduct.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            archiveTip(productId)
            return productId
        default:
            throw StoreKitError.purchaseFailed
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
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.purchaseFailed
        case .verified(let transaction):
            return transaction
        }
    }
}
