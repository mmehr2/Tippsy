//
//  TipCalculator.swift
//  Tippsy
//
//  Created by Michael L Mehr on 3/4/16.
//  Copyright © 2016 Michael L. Mehr. All rights reserved.
//

import Foundation

/**
 This is the basic Tip entity. It encapsulates the basic result of calculating a tip.
 It is immutable after creation.
*/
struct Tip {
    let baseAmount: Double
    let rate: Double
    let tip: Double
    let total: Double
    
    init(onBase b: Double, atRate r: Double) {
        baseAmount = b
        rate = r
        tip = r * b
        total = b + tip
    }
}

/**
 This is the model class for calculating tips using a default rate selected from a managed set.
 It has been implemented in functional style with no mutable state as a struct.
*/
struct TipCalculator {
    let rates : [Double]
    let currentRateIndex: Int

    init(rates r: [Double] = [0.2], currentIndex idx:Int = 0) {
        rates = r
        currentRateIndex = idx
    }

    /// just change the rates
    func newRates(rates r: [Double]) -> TipCalculator {
        return TipCalculator(rates: r, currentIndex: currentRateIndex)
    }

    /// just change the default index
    func newDefault(index: Int) -> TipCalculator {
        return TipCalculator(rates: rates, currentIndex: index)
    }

    /// calculate a tip from a base amount using the current default rate
    func calculate(baseAmount: Double) -> Tip {
        return Tip(onBase: baseAmount, atRate: rates[currentRateIndex])
    }
}