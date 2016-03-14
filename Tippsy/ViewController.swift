//
//  ViewController.swift
//  Tippsy
//
//  Created by Michael L Mehr on 3/4/16.
//  Copyright © 2016 Michael L. Mehr. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var billAmountField: UITextField!
    @IBOutlet weak var tipField: UILabel!
    @IBOutlet weak var totalField: UILabel!
    @IBOutlet weak var tipRateControl: UISegmentedControl!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet var screenElements: [UILabel]!
    @IBOutlet weak var separatorView: UIView!
    
    var storage = Storage()
    var model = TipCalcViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        billAmountField.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        title = "Tippsy the Tip Calculator"
        // BUG#1: this however is not visible - why?
        // Solution#1 - embed in NavigationController; title then is visible.
        //   BUG #2: This causes problems with the autolayout, where the field disappears under the title bar. We need a way to
        
        // this layout constraint controls an invisible spacer view that allows space for the keyboard
        bottomLayoutConstraint.constant = 0

        // restore settings as currently defined by storage object
        let settings = storage.restoreSettings()
        let since = storage.secondsSinceLastSave
        setupModel(settings, secondsSinceLastSave: since)
        
        // update the view
        refreshRates()

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

    // MARK: UI events
    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func onEditBillAmount(sender: AnyObject) {
        let currentBill = billAmountField.text!
        model.billAmount = currentBill
    }
    
    @IBAction func onEditingBillEnded(sender: AnyObject) {
        // convert editing form (numeric) back to currency for normal display
        let currentBill = billAmountField.text!
        if let amount = model.parseEditable(currentBill) {
            model.billAmount = model.formatAsCurrency(amount)
        }
        refreshAmounts()
        storage.saveSettings(model.settings)
    }
    
    @IBAction func onRateChange(sender: AnyObject) {
        let currentRateIndex = tipRateControl.selectedSegmentIndex
        model.defaultRateIndex = currentRateIndex
        refreshCurrentRate()
        view.endEditing(true)
    }

    // MARK: TextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let text: NSString = textField.text where textField === billAmountField {
            // apply the suggested change first
            let newtext = text.stringByReplacingCharactersInRange(range, withString: string)
            // prevent deleting the currency symbol during editing
            return model.isAllowableForEditing(newtext)
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // when editing, shut off display of thousands separator (only edit numeric part)
        let currentBill = textField.text!
        if let amount = model.parseCurrency(currentBill) {
            textField.text = model.formatAsEditable(amount)
        }
    }
    
    // MARK: refresh utilities
    private func refreshRates() {
        // configure the tip control with rates from the view model
        let rateStrings = model.getRateStrings()
        tipRateControl.removeAllSegments()
        for (index, rate) in rateStrings.enumerate() {
            tipRateControl.insertSegmentWithTitle(rate, atIndex: index, animated: false)
        }
        // also requires refreshing the current rate shown
        refreshCurrentRate()
    }
    
    private func refreshCurrentRate() {
        tipRateControl.selectedSegmentIndex = model.defaultRateIndex
        // also requires updating the amounts shown
        refreshAmounts()
    }
    
    private func refreshAmounts() {
        billAmountField.text = model.billAmount
        tipField.text = model.tipAmount
        totalField.text = model.totalAmount
    }

    // MARK: UI theme setup
    private func setUITheme( useDarkTheme: Bool ) {
        // set up the VM to do the coloring for us:

        // set up the screen elements that will be colored according to the theme
        var elements = screenElements.map { ($0 as Colorable) }
        elements.append(billAmountField)
        // NOTE: there is no need to add the tipRateController (segmented control)
        // This is because it inherits its coloring behavior from the main view
        // However, the separator view is a UIView that has the opposite color of the main view
        model.setupColoredElements(view, regularViews: elements, invertedViews: [separatorView])
        
        // get the color scheme from the current view as set up in IB
        model.setTheme(ViewModelTheme.fromView(view))
        
        // color the UI according to the saved setting
        model.updateColorScheme(useDarkTheme)
    }

    // MARK: restore settings
    private func setupModel( settings: Settings, secondsSinceLastSave: NSTimeInterval ) {
        // set some rates into the view model
        model.setRates(settings.rates)
        
        // set the default rate index
        model.defaultRateIndex = settings.rateIndex
        
        // also set up the initial bill
        // FEATURE: override bill with default if older than threshold
        let billAmount = settings.getOverrideBillAmount(secondsSinceLastSave)
        model.billAmount = model.formatAsCurrency(billAmount)
        
        // apply the proper color theme to UI elements
        let useDarkTheme = settings.darkTheme
        setUITheme(useDarkTheme)
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