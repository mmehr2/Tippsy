//
//  TipModelTests.swift
//  Tippsy
//
//  Created by Michael L Mehr on 3/5/16.
//  Copyright © 2016 Michael L. Mehr. All rights reserved.
//

import XCTest

class TipModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    let TYPICAL_BILL = 100.0
    let DUAL_RATES = [ 0.1, 0.2 ]
    let SINGLE_RATES = [ 0.15 ]
    
    func inconsistentModel(name: String) {
        print("\(name) Model cannot be created.")
    }
    
    func testDefaultModelIsConsistent() {
        let model = TipCalculator()
        XCTAssertNotNil(model)
    }
    
    func testDefaultModelHasNonemptyRateTable() {
        guard let model = TipCalculator() else { return }
        XCTAssertNotEqual(model.rates.count, 0)
    }
    
    func testDefaultModelUsesNonzeroRate() {
        guard let model = TipCalculator() else { return }
        let tip = model.calculate(TYPICAL_BILL)
        XCTAssertNotEqual(tip.rate, 0.0)
    }
    
    func testDefaultChangeChangesDefault() {
        let originalRates = DUAL_RATES
        let originalIndex = 1
        guard let model = TipCalculator(rates: originalRates, currentIndex: originalIndex)
            else { return }
        guard let model2 = model.newDefault(0)
            else { return }
        XCTAssertNotEqual(model2.currentRateIndex, originalIndex)
    }
    
    func testDefaultChangePreservesRateTable() {
        let originalRates = DUAL_RATES
        guard let model = TipCalculator(rates: originalRates)
            else { return }
        guard let model2 = model.newDefault(1)
            else { return }
        XCTAssertEqual(model2.rates, originalRates)
    }
    
    func testConsistencyForShrinkRateTable() {
        let originalRates = DUAL_RATES
        let originalIndex = 1
        guard let model = TipCalculator(rates: originalRates, currentIndex: originalIndex)
            else { return }
        // this should fail, since the index is no longer valid
        let model2 = model.newRates(SINGLE_RATES)
        XCTAssertNotNil(model)
        XCTAssertNil(model2)
    }
    
}
