//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by arnaud on 21/12/15.
//  Copyright © 2015 Hovering Above. All rights reserved.
//

import Foundation

// Project 2.1 Class added as presented in lecture
class CalculatorBrain {
    
    // is in Swift 2 gewijzigd van Printable naar CustomStringConvertable
    // Project 2.2 enum unchanged
    private enum Op :CustomStringConvertible
    {
        case Getal(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Constant(String, Double)
        case Variable(String)
        
        var description: String {
            get {
                switch self {
                case .Getal(let getal):
                    return "\(getal)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .Constant(let symbol, _):
                    return "\(symbol)"
                case .Variable(let variable):
                    return variable
                }
            }
        }
    }
    
    // Project 2.5
    var variableValues = Dictionary<String,Double?>() // Project 2.6 optional Double

    
    // Project 2.7
    private func evaluateDescription(ops: [Op]) -> (result: String?, remainingOps: [Op]) {
        let leftParenthesis = "("
        let rightParenthesis = ")"
        let questionMark = "?"
        if !ops.isEmpty {
            //  passed arrays are immutable and must be copies to work upon
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Getal(let getal):// Project 2.7.c
                return ("\(getal)", remainingOps)
            case .UnaryOperation(let operation, _): // Project 2.7.a
                let operandEvaluation = evaluateDescription(remainingOps)
                // TBD gives double (( and ))
                if let oplossing = operandEvaluation.result {
                    // merk op het gebruik van operation hier
                    return (operation+leftParenthesis+oplossing+rightParenthesis, operandEvaluation.remainingOps)
                } else {
                    return (operation+leftParenthesis+questionMark+rightParenthesis, operandEvaluation.remainingOps)
                }
            case .BinaryOperation(let operation, _):
                let op1Evaluation = evaluateDescription(remainingOps)
                if let getal1 = op1Evaluation.result {
                    let op2Evaluation = evaluateDescription(op1Evaluation.remainingOps)
                    if let getal2 = op2Evaluation.result {
                        // TBD sometimes ( and ) are not necessary, i.e. 3+4+5
                        // get the order of the variable right Project 2.7.b
                        return(leftParenthesis+getal2+operation+getal1+rightParenthesis, op2Evaluation.remainingOps)
                    }
                    else {
                        return(leftParenthesis+questionMark+operation+getal1+rightParenthesis, op2Evaluation.remainingOps)
                    }
                } else {
                    let op2Evaluation = evaluateDescription(op1Evaluation.remainingOps)
                    if let getal2 = op2Evaluation.result {
                        // TBD sometimes ( and ) are not necessary, i.e. 3+4+5
                        // get the order of the variable right Project 2.7.b
                        return(leftParenthesis+getal2+operation+questionMark+rightParenthesis, op2Evaluation.remainingOps)
                    } else {
                        return(leftParenthesis+questionMark+operation+questionMark+rightParenthesis, op2Evaluation.remainingOps)
                    }
                }
            case .Constant(let constant, _):// Project 2.7.c
                return (constant, remainingOps)
                // is the next on the stack a variable?
            case .Variable(let variableName):// Project 2.7.c
                // return the corresponding variable name
                // what happens if variableName is unknown?
                return (variableName, remainingOps)
            }
        }
        return(nil, ops)
    }

    var description: String? {
        // Note that is has been defined as an optional string
        set {
            // is this OK to suppress the setter?
        }
        get {
            let comma = ","
            // opStack will not be consumed and will still be available
            var (opStackDescription, remainder) = evaluateDescription(OpStack)
            // print("\(OpStack) - \(opStackDescription) with \(remainder) left over")
            // the entire opStack should be consumed
            while remainder.count != 0 { // Project 2.7.f
                let evaluation = evaluateDescription(remainder)
                if let resultaat = evaluation.result {
                    opStackDescription = resultaat+comma+opStackDescription! // Project 2.Hint.8, separate trees with comma's
                    remainder = evaluation.remainingOps
                } else {
                    
                }
            }
            return opStackDescription
        }
    }
    

    private var OpStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    init() {
        // let op functie zit in de functie
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("+",+))
        learnOp(Op.BinaryOperation("−") {$1-$0})
        learnOp(Op.BinaryOperation("×",*))
        learnOp(Op.BinaryOperation("÷") {$1/$0})
        learnOp(Op.UnaryOperation("√",sqrt))
        learnOp(Op.UnaryOperation("sin",sin))
        learnOp(Op.UnaryOperation("cos",cos))
        learnOp(Op.Constant("π", M_PI)) // Project 2.Hint.5
    }
    
    func pushOperand(getal: Double) -> Double? {
        OpStack.append(Op.Getal(getal))
        return evaluate()
    }
    
    // Project 2.5
    func pushOperand(symbol: String) -> Double? {
        // Note that the value of symbol should be set by the caller.
        // Would like to change symbol to String?
        if symbol != "" {
            OpStack.append(Op.Variable(symbol))
        }
        // does this work? Is there something to evaluate?
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            OpStack.append(operation)
        }
        return evaluate()
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            //  passed arrays are immutable and must be copies to work upon
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Getal(let getal):
                return (getal, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let getal = operandEvaluation.result {
                    // merk op het gebruik van operation hier
                    return (operation(getal), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let getal1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let getal2 = op2Evaluation.result {
                        return(operation(getal1, getal2), op2Evaluation.remainingOps)
                    }
                }
            case .Constant(_, let constant):
                    return (constant, remainingOps)
            // is the next on the stack a variable?
            case .Variable(let variableName): // Project 2.5
                // return the corresponding variable value
                // project 2.6 return nil if value does not exist
                if let variableValue = variableValues[variableName] {
                    return (variableValue, remainingOps)
                } else {
                    return (nil, remainingOps)
                }
            }
        }
        return(nil, ops)
    }
    
    func evaluate() -> Double? {
        // opStack will not be consumed and will still be available
        let (result, remainder) = evaluate(OpStack)
        print("\(OpStack) - \(result) with \(remainder) left over")
        return result
    }
    
    func clearAll() { // Project 2.10 adjusted
        OpStack = []
        clearMemory() // Project 2.Hint.11 memory clear as separate function
    }
    
    func clearMemory() { // Project 2.11 remove existing variables;
        variableValues = [:]
    }
    
}