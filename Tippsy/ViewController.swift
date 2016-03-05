//
//  ViewController.swift
//  Tippsy
//
//  Created by Michael L Mehr on 3/4/16.
//  Copyright © 2016 Michael L. Mehr. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var billAmountField: UITextField!
    @IBOutlet weak var tipField: UILabel!
    @IBOutlet weak var totalField: UILabel!
    @IBOutlet weak var tipRateControl: UISegmentedControl!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    var model = TipCalcViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "Tippsy the Tip Calculator"
        // TBD: this however is not visible - why?
        
        // this layout constraint controls an invisible spacer view that allows space for the keyboard
        bottomLayoutConstraint.constant = 0

        // set some rates into the view model (later will use storage defaults)
        let defaultRates = [0.15, 0.20, 0.22]
        model.setRates(defaultRates)
        
        // set the default rate index (later will use storage defaults)
        model.defaultRateIndex = 0
        
        // also set up the initial bill (later will use storage defaults)
        model.billAmount = "$10.00"
        
        // update the view
        refresh()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func refreshRates() {
        // configure the tip control with rates from the view model
        let rateStrings = model.getRateStrings()
        tipRateControl.removeAllSegments()
        for (index, rate) in rateStrings.enumerate() {
            tipRateControl.insertSegmentWithTitle(rate, atIndex: index, animated: false)
        }
        tipRateControl.selectedSegmentIndex = model.defaultRateIndex
    }
    
    private func refreshAmounts() {
        billAmountField.text = model.billAmount
        tipField.text = model.tipAmount
        totalField.text = model.totalAmount
    }
    
    func refresh() {
        refreshRates()
        refreshAmounts()
    }

}

extension ViewController {
    // functions to move view around using keyboad notifications when shown or hidden
    // refer to Stack Overflow here: https://youtu.be/1rktrqZIQ8I?t=1m47s
    
    func addKeyboardObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObserver() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue) {
                bottomLayoutConstraint.constant = keyboardSize.CGRectValue().height
                view.setNeedsLayout()
        }
    }
    
    func keyboardWillHide(_: NSNotification) {
        bottomLayoutConstraint.constant = 0
        view.setNeedsLayout()
    }
}