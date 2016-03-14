//
//  TipCalcViewModel.swift
//  Tippsy
//
//  Created by Michael L Mehr on 3/4/16.
//  Copyright © 2016 Michael L. Mehr. All rights reserved.
//

import UIKit

class TipCalcViewModel {
    private var model: TipCalculator
    private var currentSettings: Settings
    private let fmt = NSNumberFormatter()
    private var foregroundColor: UIColor
    private var backgroundColor: UIColor
    private var mainView: UIView!
    private var mainItems: [Colorable]
    private var oppositeItems: [UIView]
    private var currentTip: Tip // this is maintains the current baseAmount as well as the tip and total at the default rate
    
    init(settings s: Settings = Settings()) {
        // NOTE: it is safe to force unwrap the optional since the default model is consistent
        // CONVERSE: if default model is inconsistent, the app will crash
        model = TipCalculator(rates: s.rates, currentIndex: s.rateIndex)!
        currentTip = model.calculate(s.billAmount)
        currentSettings = s
        foregroundColor = UIColor.blackColor()
        backgroundColor = UIColor.whiteColor()
        mainItems = []
        oppositeItems = []
    }
    
    var defaultRateIndex: Int {
        get{
            return model.currentRateIndex
        }
        
        set{
            guard let newModel = model.newDefault(newValue) else {
                return
            }
            model = newModel
            currentTip = model.calculate(currentTip.baseAmount)
        }
    }
    
    var billAmount: String {
        get {
            return formatAsCurrency(currentTip.baseAmount)
        }
        set {
            // parse new value from typical output string (gathered as input)
            if let newBase = parseCurrency(newValue) {
                // if successful, get a new currentTip using the new base amount and default rate
                currentTip = model.calculate(newBase)
            }
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
    
    func totalAmountSplit(persons: Int) -> String {
        let amount = currentTip.total / Double(persons)
        return formatAsCurrency(amount)
    }
    
    var settings: Settings {
        get {
            return Settings(index: defaultRateIndex,
                rates: model.rates,
                bill: currentTip.baseAmount,
                billStaleness: currentSettings.billStaleness,
                darkTheme: currentSettings.darkTheme)
        }
        set {
            currentSettings = newValue
            updateWithSettings(currentSettings)
        }
    }

    private func updateWithSettings(sss: Settings) {
        model = TipCalculator(rates: sss.rates, currentIndex: sss.rateIndex)!
        currentTip = model.calculate(sss.billAmount)
    }
    
    func isAllowableForEditing(input: String) -> Bool  {
        /* DISCUSSION
        We actually want to prevent the case of a blank field when editing currency, since the
        ViewModel can only convert from currency output back to double.
        
        Alternatively, we could implement changes during editing mode such that all strings are allowed, but then we have the issue of any call to refreshAmounts() (such as from changing the rate while editing) can cause it to redisplay the current amount as edited.
        DISCOVERED BUGS WITH THIS APPROACH:
        If the user enters an amount that introduces a thousands separator, and then edits the amount to delete a few digits, the result is NOT parseable, and thus is disallowed.
        This cannot be corrected in any fashion, due to persisting the current bill amount. One must wait for the 10-minute clear and refuse to enter any more amounts using the separator.
        
        The cure seems to be to implement the alternative mentioned above, and only display as a number in editing mode, testing only for its validity as a number, and not as a currency value. Perhaps if we just test the amount as a value? No, we are passed a string. Hmmm...
        
        Consider the sequence during editing:
        $1,234.56 <del>
        $1,234.5 <del>
        $1,234. <del>
        $1,234 <del>
        $1,23 <== THIS IS NOT A VALID CURRENCY INPUT
        */
        // first, check if the string is parseable as currency
        // if ok, then it passes
        let parsed = parseEditable(input)
        if parsed != nil {
            return true
        }
        // if not, it must be the entire currency symbol in order to pass
        return input == fmt.currencySymbol
    }
    
    func getRates() -> [Double] {
        return model.rates
    }
    
    func setRates(rates: [Double]) {
        guard let newmodel = model.newRates(rates) else { return }
        model = newmodel
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
    
    func parseCurrency(input: String) -> Double? {
        fmt.configureForCurrency()
        let result = fmt.numberFromString(input)?.doubleValue
        return result
    }
    
    func formatAsEditable(input: Double) -> String {
        fmt.configureForCurrency(true)
        let result = fmt.stringFromNumber(input) ?? fmt.stringFromNumber(0.0)!
        return result
    }
    
    func parseEditable(input: String) -> Double? {
        fmt.configureForCurrency(true)
        let result = fmt.numberFromString(input)?.doubleValue
        return result
    }

    // MARK: theme coloring
    func setTheme(theme: ViewModelTheme) {
        foregroundColor = theme.fgColor
        backgroundColor = theme.bgColor
    }
    
    func setupColoredElements(main: UIView, regularViews: [Colorable], invertedViews: [UIView]) {
        mainView = main
        mainItems = regularViews
        oppositeItems = invertedViews
    }
    
    func updateColorScheme(useDarkTheme: Bool = false) {
        let foreColor = useDarkTheme ? backgroundColor : foregroundColor
        let backColor = useDarkTheme ? foregroundColor : backgroundColor
        mainView.tintColor = foreColor
        mainView.backgroundColor = backColor
        for var item in mainItems {
            item.foreColor = foreColor
            item.backColor = backColor
        }
        for item in oppositeItems {
            item.backgroundColor = foreColor
            item.tintColor = backColor
        }
    }
}

extension NSNumberFormatter {
    
    func configureForPercent() {
        // use a number formatter for percent conversion to/from string using current locale
        self.numberStyle = .PercentStyle
        self.alwaysShowsDecimalSeparator = false
        self.usesGroupingSeparator = false
        self.maximumFractionDigits = 2
        self.minimumFractionDigits = 0
        self.roundingMode = .RoundHalfEven
    }
    
    func configureForCurrency(editable: Bool = false) {
        // use a number formatter for currency conversion to/from string using current locale
        // editable form has no grouping separator, and only displays fractions as needed
        self.numberStyle = .CurrencyStyle
        self.alwaysShowsDecimalSeparator = !editable
        self.usesGroupingSeparator = !editable
        self.maximumFractionDigits = 2
        self.minimumFractionDigits = editable ? 0 : 2
        self.roundingMode = .RoundHalfUp
    }
    
}
