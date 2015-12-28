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
    
    
    var displayValue: Double? {
        get {
            if let x = NSNumberFormatter().numberFromString(display.text!) {
                return x.doubleValue
            } else {
                return nil
            }
        }
        
        set {
            if newValue != nil {
                display.text = "\(newValue!)"
            } else {
                display.text = "0"
            }
        }
    }

    @IBAction func digitPressed(sender: UIButton) {
        let digit = sender.currentTitle!
        let dot = "."
        if (userIsInTheMiddleOfTypingANumber) {
            // do we have two dots?
            if (display.text!.rangeOfString(dot) == nil) || digit != dot {
                display.text = display.text! + digit
                inputLabel.text = inputLabel.text! + digit
            }
        }
        else {
            display.text! = digit
            if let lastChar = inputLabel.text {
                if lastChar.characters.last == "=" {
                    inputLabel.text!.removeAtIndex(inputLabel.text!.endIndex.predecessor())
                }
            }
            inputLabel.text = inputLabel.text! + space + digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func changeSign() {
        displayValue = -1 * displayValue!
        inputLabel.text = inputLabel.text! + "-"
    }
    
    @IBAction func clearErrorPressed() {
        if userIsInTheMiddleOfTypingANumber {
            // remove the last character on the display
            display.text!.removeAtIndex(display.text!.endIndex.predecessor())
            inputLabel.text!.removeAtIndex(inputLabel.text!.endIndex.predecessor())
            // check if any digit is left and whether there rests something to delete
            if display.text!.characters.count == 0 {
                userIsInTheMiddleOfTypingANumber = false
                displayValue = nil
            }
        } // else nothing happens
    }
    
    @IBAction func clearPressed() {
        brain.clear()
        displayValue = nil
        inputLabel.text = ""
    }
        
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if inputLabel.text!.characters.last! == "=" {
                _ = inputLabel.text!.characters.dropLast()
            }
            inputLabel.text = inputLabel.text! + space + sender.currentTitle! + "="
            if let result = brain.performOperation(operation) {
                displayValue! = result
            } else {
                displayValue = nil
            }
        }
    }
    
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        aDotHasBeenAddedToNumber = false
        if let result = brain.pushOperand(displayValue!) {
            displayValue! = result
        } else {
            displayValue = nil
        }
    }
}

