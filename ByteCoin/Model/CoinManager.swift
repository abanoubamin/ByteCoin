//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(_ coinManager: CoinManager, price: Double, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {

    // CoinGecko – free, no API key required
    let baseURL = "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies="

    var delegate: CoinManagerDelegate?

    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)\(currency.lowercased())"
        performRequest(urlString: urlString, currency: currency)
    }

    func performRequest(urlString: String, currency: String) {
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                delegate?.didFailWithError(error: error)
                return
            }
            if let safeData = data {
                if let price = parseJSON(safeData, currency: currency) {
                    delegate?.didUpdatePrice(self, price: price, currency: currency)
                }
            }
        }
        task.resume()
    }

    // Response shape: { "bitcoin": { "usd": 68000 } }
    func parseJSON(_ data: Data, currency: String) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode([String: [String: Double]].self, from: data)
            if let price = decodedData["bitcoin"]?[currency.lowercased()] {
                return price
            }
        } catch {
            delegate?.didFailWithError(error: error)
        }
        return nil
    }
}
