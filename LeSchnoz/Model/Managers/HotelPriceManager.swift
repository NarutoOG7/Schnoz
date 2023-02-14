//
//  HotelPriceManager.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/2/22.
//

import Foundation
import SwiftUI

class HotelPriceManager {
    
    static let instance = HotelPriceManager()
    
    var hotelPriceURL: String = ""
    
    func getDates() -> [String] {
        
        let firstDate = Date().advanced(by: 86400)
        let secondDate = firstDate.advanced(by: 86400)
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        
        let checkIn = df.string(from: firstDate)
        let checkOut = df.string(from: secondDate)
        
        return [checkIn, checkOut]
    }
    
    func getPriceOfHotel(key: String, withCompletion completion: @escaping ((HotelPriceModel) -> (Void))) {
        
        if key != "" {
            
            let checkIn = getDates().first ?? ""
            let checkOut = getDates().last ?? ""
            
            let urlString = "\(hotelPriceURL)?hotel_key=\(key)&chk_in=\(checkIn)&chk_out=\(checkOut)"
            let url = URL(string: urlString)!
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                
                if let _ = error {
                    
                    completion(HotelPriceModel(prices: [0]))
                }
                
                guard let data = data else { return }
                
                do {
                    
                    let hotelPrice = try JSONDecoder().decode(HotelPriceData.self, from: data)
                    var prices = [Double]()
                    
                    for price in hotelPrice.result.rates {
                        
                        prices.append(price.rate)
                    }
                    
                    let hotelPriceModel = HotelPriceModel(prices: prices)
                    
                    completion(hotelPriceModel)
                    
                } catch {
                    
                    completion(HotelPriceModel(prices: [0]))
                }
            }
            task.resume()
        }
    }
}
