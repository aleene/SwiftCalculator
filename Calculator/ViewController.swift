//
//  ViewController.swift
//  Calculator
//
//  Created by arnaud on 18/12/15.
//  Copyright © 2015 Hovering Above. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!

    @IBOutlet weak var inputLabel: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    
    var aDotHasBeenAddedToNumber = false
    
    var brain = CalculatorBrain()
    
    let space = " "
    
    @IBAction func digitPressed(sender: UIButton) {
        let digit = sender.currentTitle!
        let dot = "."
        let zero = "0"
        if (userIsInTheMiddleOfTypingANumber) {
            if digit == dot {
                if !aDotHasBeenAddedToNumber {
                    display.text = display.text! + digit
                    inputLabel.text = inputLabel.text! + digit
                    aDotHasBeenAddedToNumber = true
                } // else nothing happens
            } else {
                display.text = display.text! + digit
                inputLabel.text = inputLabel.text! + digit
            }
        }
        else {
            if digit == dot {
                // add a leading 0
                display.text = zero + dot
                inputLabel.text = inputLabel.text! + space + zero + digit
            } else {
                display.text! = digit
                inputLabel.text = inputLabel.text! + space + digit
            }
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func clearPressed() {
        brain.clear()
        display.text = "0"
        inputLabel.text = ""
    }
        
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            inputLabel.text = inputLabel.text! + space + sender.currentTitle!
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                // displayValue moet een optional worden
                displayValue = 0
            }
        }
    }
    
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        aDotHasBeenAddedToNumber = false
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            // displayValue moet een optional worden
            displayValue = 0
        }
    }
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
        }
    }
}

