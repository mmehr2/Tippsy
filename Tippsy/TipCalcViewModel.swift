//
//  TipCalcViewModel.swift
//  Tippsy
//
//  Created by Michael L Mehr on 3/4/16.
//  Copyright © 2016 Michael L. Mehr. All rights reserved.
//

import Foundation

class TipCalcViewModel {
    private var model: TipCalculator
    private let fmt = NSNumberFormatter()
    
    private var currentTip: Tip // this is maintains the current baseAmount as well as the tip and total at the default rate
    
    var defaultRateIndex: Int {
        get{
            return model.currentRateIndex
        }
        
        set{
            guard newValue >= 0 && newValue < model.rates.count else {
                return
            }
            model = model.newDefault(newValue)
            currentTip = model.calculate(currentTip.baseAmount)
        }
    }
    
    var billAmount: String {
        get {
            return formatAsCurrency(currentTip.baseAmount)
        }
        set {
            // parse new value from typical output string (gathered as input)
            let newBase = parseCurrency(newValue)
            // if successful, get a new currentTip using the new base amount and default rate
            currentTip = model.calculate(newBase)
        }
    }
    
    var tipAmount: String {
        get {
            return formatAsCurrency(currentTip.tip)
        }
    }
    
    var totalAmount: String {
        get {
            return formatAsCurrency(currentTip.total)
        }
    }
    
    init(bill: Double = 0.0) {
        model = TipCalculator(rates: [0.15, 0.20, 0.25], currentIndex: 0)
        currentTip = model.calculate(bill)
    }
    
    func getRates() -> [Double] {
        return model.rates
    }
    
    func setRates(rates: [Double]) {
        model = model.newRates(rates: rates)
    }
    
    func getRateStrings() -> [String] {
        return (0..<model.rates.count).map{ getRateString($0) }
    }
    
    func getRateString(index: Int) -> String {
        return formatAsPercent(model.rates[index])
    }
    
    func formatAsPercent(input: Double) -> String {
        fmt.configureForPercent()
        let result = fmt.stringFromNumber(input) ?? fmt.stringFromNumber(0.0)!
        return result
    }
    
    func formatAsCurrency(input: Double) -> String {
        fmt.configureForCurrency()
        let result = fmt.stringFromNumber(input) ?? fmt.stringFromNumber(0.0)!
        return result
    }
    
    func parseCurrency(input: String) -> Double {
        fmt.configureForCurrency()
        let result = fmt.numberFromString(input)?.doubleValue ?? 0.00
        return result
    }
}

extension NSNumberFormatter {
    
    func configureForPercent() {
        // use a number formatter for percent conversion to/from string using current locale
        self.numberStyle = .PercentStyle
        self.alwaysShowsDecimalSeparator = false
        self.maximumFractionDigits = 2
        self.minimumFractionDigits = 0
        self.roundingMode = .RoundHalfEven
    }
    
    func configureForCurrency() {
        // use a number formatter for currency conversion to/from string using current locale
        self.numberStyle = .CurrencyStyle
        self.alwaysShowsDecimalSeparator = true
        self.maximumFractionDigits = 2
        self.minimumFractionDigits = 2
        self.roundingMode = .RoundHalfEven
    }
    
}
