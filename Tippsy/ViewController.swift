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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // this layout constraint controls an invisible view that allows space for the keyboard
        bottomLayoutConstraint.constant = 0 // testing!
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