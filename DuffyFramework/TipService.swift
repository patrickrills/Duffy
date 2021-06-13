//
//  TipService.swift
//  Duffy
//
//  Created by Patrick Rills on 5/15/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import Foundation
import StoreKit

@available(watchOSApplicationExtension 6.2, *)
public class TipService: NSObject {
    
    private static let instance: TipService = TipService()
    
    public override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    public class func getInstance() -> TipService {
        return instance
    }
    
    public func initialize() {
        downloadAndCacheProducts(nil)
    }
    
    private lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    private var productCache: [TipIdentifier : SKProduct] = [:]
    private var options: [TipOption] {
        return productCache.map { key, value in
            currencyFormatter.locale = value.priceLocale
            return TipOption(identifier: key, formattedPrice: currencyFormatter.string(for: value.price) ?? "??")
        }
    }
    
    private var pendingProductsRequest: SKProductsRequest?
    private var pendingProductsRequestHandler: ((Result<[TipOption], StoreKitError>) -> ())?
    
    public func tipOptions(_ completionHandler: @escaping (Result<[TipOption], StoreKitError>) -> ()) {
        guard !productCache.isEmpty else {
            downloadAndCacheProducts(completionHandler)
            return
        }
        
        completionHandler(.success(options))
    }
    
    private var pendingProductsPurchaseHandler: ((Result<TipIdentifier, StoreKitError>) -> ())?
    
    public func tip(productId: TipIdentifier, completionHandler: @escaping (Result<TipIdentifier, StoreKitError>) -> ()) {
        guard let tipProduct = productCache[productId] else {
            return
        }
        
        pendingProductsPurchaseHandler = completionHandler
        
        let payment = SKPayment(product: tipProduct)
        SKPaymentQueue.default().add(payment)
    }
    
    private func downloadAndCacheProducts(_ completionHandler: ((Result<[TipOption], StoreKitError>) -> ())?) {
        guard pendingProductsRequest == nil else {
            return
        }
        
        let request = SKProductsRequest(productIdentifiers: Set(TipIdentifier.allCases.map({ $0.rawValue })))
        request.delegate = self
        request.start()
        pendingProductsRequest = request
        pendingProductsRequestHandler = completionHandler
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

@available(watchOSApplicationExtension 6.2, *)
extension TipService: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard response.products.count > 0 else {
            pendingProductsRequestHandler?(.failure(.productDownloadFailed))
            pendingProductsRequest = nil
            return
        }
        
        productCache = response.products.reduce(into: [:]) { result, product in
            if let tipId = TipIdentifier(rawValue: product.productIdentifier) {
                result[tipId] = product
            }
        }
        
        pendingProductsRequestHandler?(.success(options))
        pendingProductsRequest = nil
    }
    
}

@available(watchOSApplicationExtension 6.2, *)
extension TipService: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { trans in
            switch trans.transactionState {
            case .purchased:
                finishTransaction(trans, in: queue, wasSuccessful: true)
            case .failed:
                finishTransaction(trans, in: queue, wasSuccessful: false)
            default:
                break
            }
        }
    }
    
    private func finishTransaction(_ transaction: SKPaymentTransaction, in queue: SKPaymentQueue, wasSuccessful: Bool) {
        queue.finishTransaction(transaction)
        
        guard let tipId = TipIdentifier(rawValue: transaction.payment.productIdentifier),
              let handler = pendingProductsPurchaseHandler
        else {
            return
        }
        
        let purchaseResult: Result<TipIdentifier, StoreKitError>
        
        if wasSuccessful {
            purchaseResult = .success(tipId)
            archiveTip(tipId)
        } else if let purchaseError = transaction.error {
            purchaseResult = .failure(.wrapped(purchaseError))
        } else {
            purchaseResult = .failure(.purchaseFailed)
        }
        
        handler(purchaseResult)
        pendingProductsPurchaseHandler = nil
    }
}
