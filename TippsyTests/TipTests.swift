//
//  TipTests.swift
//  Tippsy
//
//  Created by Michael L Mehr on 3/5/16.
//  Copyright © 2016 Michael L. Mehr. All rights reserved.
//

import XCTest

class TipTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    let ZERO_RATE = 0.00
    let TYPICAL_RATE = 0.15
    let ACCURACY_RATE = 0.2345
    
    let ZERO_BILL = 0.0
    let TYPICAL_BILL = 100.0

    func testThatTipRetainsBill() {
        let tip = Tip(onBase: TYPICAL_BILL, atRate: TYPICAL_RATE)
        XCTAssertEqual(tip.baseAmount, TYPICAL_BILL)
    }
    
    func testThatTipRetainsBillWithZeroRate() {
        let tip = Tip(onBase: TYPICAL_BILL, atRate: ZERO_RATE)
        XCTAssertEqual(tip.baseAmount, TYPICAL_BILL)
    }
    
    func testThatTipRetainsRate() {
        let tip = Tip(onBase: TYPICAL_BILL, atRate: TYPICAL_RATE)
        XCTAssertEqual(tip.rate, TYPICAL_RATE)
    }
    
    func testThatTipRetainsRateWithZeroBill() {
        let tip = Tip(onBase: ZERO_BILL, atRate: TYPICAL_RATE)
        XCTAssertEqual(tip.rate, TYPICAL_RATE)
    }
    
    func testTipCalculation() {
        let tip = Tip(onBase: TYPICAL_BILL, atRate: TYPICAL_RATE)
        XCTAssertEqual(tip.tip, TYPICAL_BILL * TYPICAL_RATE)
    }
    
    func testTipAccuracyCalculation() {
        let tip = Tip(onBase: TYPICAL_BILL, atRate: ACCURACY_RATE)
        XCTAssertEqual(tip.tip, TYPICAL_BILL * ACCURACY_RATE)
    }
    
    func testTotalCalculation() {
        let tip = Tip(onBase: TYPICAL_BILL, atRate: TYPICAL_RATE)
        XCTAssertEqual(tip.total, TYPICAL_BILL + (TYPICAL_BILL * TYPICAL_RATE) )
    }
    
    func testTotalAccuracyCalculation() {
        let tip = Tip(onBase: TYPICAL_BILL, atRate: ACCURACY_RATE)
        XCTAssertEqual(tip.total, TYPICAL_BILL + (TYPICAL_BILL * ACCURACY_RATE) )
    }
}
