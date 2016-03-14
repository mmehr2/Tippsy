//
//  Settings.swift
//  Tippsy
//
//  Created by Michael L Mehr on 3/11/16.
//  Copyright © 2016 Michael L. Mehr. All rights reserved.
//

import Foundation

private let defaultRateIndex = 0
private let defaultRates = [0.15, 0.18, 0.20, 0.22]
private let defaultRate = 0.20
private let defaultBillAmount = 0.0
private let defaultDarkTheme = false
private let defaultBillStaleness = 10.0 * 60.0 // time in seconds to allow persistent bill amount

struct Settings {
    let rateIndex: Int
    let rates: [Double]
    let billAmount: Double
    let billStaleness: Double
    let darkTheme: Bool
    
    init(index: Int = defaultRateIndex,
        rates r: [Double] = defaultRates,
        bill: Double = defaultBillAmount,
        billStaleness bs: Double = defaultBillStaleness,
        darkTheme d: Bool = defaultDarkTheme) {
            rateIndex = index
            rates = r
            billAmount = bill
            darkTheme = d
            billStaleness = bs
    }
    
    func getOverrideBillAmount(secsSinceLastSave: NSTimeInterval) -> Double {
        var result = billAmount
        let defAmount = Settings().billAmount
        // if the persistent bill amount is stale, replace it with its default
        if secsSinceLastSave > billStaleness {
            result = defAmount
        }
        return result
    }
}
