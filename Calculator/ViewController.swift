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
    
    // change this to use another part of the app
    let appWithErrorReporting = true
    
    var userIsInTheMiddleOfTypingANumber = false
    var userEnteredAFormula = false
    var aDotHasBeenAddedToNumber = false
    
    var brain = CalculatorBrain()
    
    let space = " "
    let variableName = "M"
    let zero = "0"
    let equal = "="
    
    enum ResultOrError {
        case Result(Double?)
        case Error(String?)
    }
    
    var displayValue: Double? { // Project 2.9.4 optional double
        get {
            // Project 2.Hint.1 use optional chaining
            // http://cs193p.m2m.at/cs193p-project-2-assignment-2-task-4-winter-2015/
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
            display.text = newValue != nil ? "\(newValue!)" : (userEnteredAFormula ? space : zero) // Project 2.9.F blank
        }
    }

    // Project 2.8 inputLabel based on brain.description
    // Project.2.Hint.9 single knothole?
    func updateInputLabel() {
        if let description: String = brain.description {
            inputLabel.text = description
        } else {
            inputLabel.text = space // Project 2.Hint.6
        }
    }
    
    func extensiveEvaluate() {
        if appWithErrorReporting {
            switch brain.evaluateAndReportErrors() {
            case .Result(let waarde):
                displayValue = waarde
            case .Error(let failureDescription):
                display.text = failureDescription != nil ? failureDescription! : "No error defined"
            }
        } else {
            displayValue = brain.evaluate()
        }
    }
    
    @IBAction func digitPressed(sender: UIButton) {
        let digit = sender.currentTitle!
        let dot = "."
        if (userIsInTheMiddleOfTypingANumber) {
            // do we have two dots?
            if (display.text!.rangeOfString(dot) == nil) || digit != dot {
                display.text = display.text! + digit
            }
        }
        else {
            display.text! = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func changeSign() {
        displayValue = -1 * displayValue!
        // the actual sign of a operand is only pushed to the brain upon enter
    }
    
    @IBAction func clearErrorPressed() {
        if userIsInTheMiddleOfTypingANumber {
            // Project 1.Extra.1
            // the last entered number should be removed
            display.text!.removeAtIndex(display.text!.endIndex.predecessor())
            // check if any digit is left and whether there rests something to delete
            if display.text!.characters.count == 0 {
                userIsInTheMiddleOfTypingANumber = false
                extensiveEvaluate()
            }
        } else {
            // Project 2.Extra.2
            // This should allow to edit the stack in the calculator brain
            brain.removeLast()
            updateInputLabel()
            extensiveEvaluate()
        }
    }
    
    // Project 2.10 updated
    @IBAction func clearPressed() {
        userEnteredAFormula = false
        userIsInTheMiddleOfTypingANumber = false
        brain.clearAll()
        displayValue = nil
        updateInputLabel()
    }
        
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
//            if inputLabel.text!.characters.last! == "=" {
//                _ = inputLabel.text!.characters.dropLast()
//            }
//            inputLabel.text = inputLabel.text! + space + sender.currentTitle! + "="
            //if let result = brain.performOperation(operation) {
              //  displayValue! = result
            //} else {
            //    displayValue = nil
            //}
            if appWithErrorReporting {
                switch brain.performOperation(operation)! {
                case .Result(let waarde):
                    displayValue = waarde
                case .Error(let failureDescription):
                    display.text = failureDescription != nil ? failureDescription! : "No error defined"
                }
            } else {
                displayValue = brain.evaluate()
            }

        }
        updateInputLabel()
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        aDotHasBeenAddedToNumber = false
        
        //if let result = brain.pushOperand(displayValue!) {
        //    displayValue! = result
        //} else {
        //    displayValue = nil
        //}
        if appWithErrorReporting {
            switch brain.pushOperand(displayValue!)! {
            case .Result(let waarde):
                displayValue = waarde
            case .Error(let failureDescription):
                display.text = failureDescription != nil ? failureDescription! : "No error defined"
            }
        } else {
            displayValue = brain.evaluate()
        }
        updateInputLabel()
    }
    
    // Project 2.9, 2.9.e
    @IBAction func setMemoryVariable() {
        if userIsInTheMiddleOfTypingANumber {
           enter()
        }
        userEnteredAFormula = true
        // corresponds to the M button and adds a variable to the brain stack
        brain.pushOperand(variableName) // Project 2.9.c
        updateInputLabel()
        extensiveEvaluate()
    }

    // Project 2.9, 2.9.e
    @IBAction func setMemoryValue() {
        // corresponds to the >M button and adds the variable value to the brain stack
        brain.variableValues[variableName] = displayValue // Project 2.9.a
        userIsInTheMiddleOfTypingANumber = false // Project 2.9.b
        extensiveEvaluate()
    }
}

