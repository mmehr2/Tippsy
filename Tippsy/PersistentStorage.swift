//
//  PersistentStorage.swift
//  Tippsy
//
//  Created by Michael L Mehr on 3/10/16.
//  Copyright © 2016 Michael L. Mehr. All rights reserved.
//

import Foundation

private enum StorageKey: String {
    case RateIndex = "RateIndex"
    case Rates = "Rates"
    case BillAmount = "BillAmount"
    case BillStaleness = "BillStaleness"
    case DarkTheme = "DarkTheme"
    // this is always there to use as a key to see if something has been saved yet, and when
    case LastTime = "LastStorageTime"
}

class Storage {
    private let store = NSUserDefaults.standardUserDefaults()
    private var lastStorageTime: NSDate?
    
    var secondsSinceLastSave: NSTimeInterval {
        get {
            if let lastStorageTime = store.objectForKey(StorageKey.LastTime.rawValue) as? NSDate {
                let elapsed = NSDate().timeIntervalSinceDate(lastStorageTime)
                return elapsed
            } else {
                return NSTimeInterval(Double.infinity)
            }
        }
    }
    
    func restoreSettings( defaultSettings: Settings = Settings() ) -> Settings {
        let currentRateIndex = store.integerForKey(StorageKey.RateIndex.rawValue) ?? defaultSettings.rateIndex
        let currentBillAmount = store.doubleForKey(StorageKey.BillAmount.rawValue) ?? defaultSettings.billAmount
        let currentBillStaleness = store.doubleForKey(StorageKey.BillStaleness.rawValue) ?? defaultSettings.billStaleness
        let currentDarkTheme = store.boolForKey(StorageKey.DarkTheme.rawValue) ?? defaultSettings.darkTheme
        let currentRates = restoreRates(defaultSettings.rates)
        return Settings(index: currentRateIndex, rates: currentRates,
            bill: currentBillAmount, billStaleness: currentBillStaleness,
            darkTheme: currentDarkTheme)
    }
    
    func saveSettings( settings: Settings ) {
        store.setObject(NSDate(), forKey: StorageKey.LastTime.rawValue)
        store.setInteger(settings.rateIndex, forKey: StorageKey.RateIndex.rawValue)
        store.setBool(settings.darkTheme, forKey: StorageKey.DarkTheme.rawValue)
        store.setDouble(settings.billAmount, forKey: StorageKey.BillAmount.rawValue)
        store.setDouble(settings.billStaleness, forKey: StorageKey.BillStaleness.rawValue)
        saveRates(settings.rates)
        store.synchronize()
    }
    
    private func restoreRates( defaultRates: [Double] ) -> [Double] {
        guard let nsaRates = store.objectForKey(StorageKey.Rates.rawValue),
            nsnRates = nsaRates as? [NSNumber] else {
                return defaultRates
        }
        return nsnRates.flatMap{ $0.doubleValue }
    }
    
    private func saveRates( rates: [Double] ) {
        let nsnRates: [NSNumber] = rates.map{ NSNumber(double: $0) }
        store.setObject((nsnRates as NSArray), forKey: StorageKey.Rates.rawValue)
    }
}