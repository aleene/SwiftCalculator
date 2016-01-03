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
    // Project 2.Extra.1 - inspiration by https://github.com/m2mtech/calculator-2015/tree/project2assignment2extratask1/Calculator
    private enum Op :CustomStringConvertible
    {
        case Getal(Double)
        // Project 2.Extras.2.Hint.3.d/e - add an extra function to report Errors
        case UnaryOperation(String, (Double -> Double), (Double -> String?)?)
        // The UnaryOperation consists of en enum with three elements:
        // - A string, which identifies the unary operation
        // - An Int which specifies the operator preference (higher number has more preference)
        // - A function implementing the unary operation, which takes a double and gives a double
        // - An optional error function, which takes a double and gives an optional string
        case BinaryOperation(String, Int, ((Double, Double) -> Double), ((Double, Double) -> String?)?)
        // The BinaryOperation consists of en enum with three elements:
        // - A string, which identifies the binary operation
        // - An Int which specifies the operator preference (higher number has more preference)
        // - A function implementing the binary operation, which takes two doubles and gives a double
        // - An optional error function, which takes two doubles and gives an optional string
        case Constant(String, Double)
        // - A string, which identifies the constant
        // - An Int which specifies the operator preference (higher number has more preference)
        // - A double, which is the value of the constant
        case Variable(String)
        
        var description: String {
            get {
                switch self {
                case .Getal(let getal):
                    return "\(getal)"
                case .UnaryOperation(let symbol, _, _):
                    return symbol
                case .BinaryOperation(let symbol, _, _, _):
                    return symbol
                case .Constant(let symbol, _):
                    return "\(symbol)"
                case .Variable(let variable):
                    return variable
                }
            }
        }
        
        // the variable precedence is used to determine the importance of the operation
        // the higher the value, the more important is the operation
        var precedence: Int {
            get {
                switch self {
                case .BinaryOperation(_, let precedence, _, _):
                    return precedence
                default:
                    // all the other operations have maximal precedence
                    return Int.max
                }
            }
        }

    }
    
    // Project 2.5
    var variableValues = Dictionary<String,Double?>() // Project 2.6 optional Double

    
    // Project 2.7
    private func evaluateDescription(ops: [Op]) -> (result: String?, remainingOps: [Op], previousPrecedence: Int) {
        let leftParenthesis = "("
        let rightParenthesis = ")"
        let questionMark = "?"
        if !ops.isEmpty {
            //  passed arrays are immutable and must be copies to work upon
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Getal(let getal):// Project 2.7.c
                return ("\(getal)", remainingOps, op.precedence)
            case .UnaryOperation(let operation, _, _): // Project 2.7.a
                let operandEvaluation = evaluateDescription(remainingOps)
// TBD gives double (( and ))
                let oplossing = operandEvaluation.result != nil ? operandEvaluation.result : questionMark
                return (operation+leftParenthesis+oplossing!+rightParenthesis, operandEvaluation.remainingOps, op.precedence)
            case .BinaryOperation(let operation, _, _, _):
                let op1Evaluation = evaluateDescription(remainingOps)
                var getal1 = op1Evaluation.result != nil ? op1Evaluation.result! : questionMark
                let op2Evaluation = evaluateDescription(op1Evaluation.remainingOps)
                var getal2 = op2Evaluation.result != nil ? op2Evaluation.result! : questionMark
// TBD sometimes ( and ) are not necessary, i.e. 3+4+5
                // check the precedence rules to determine whete
                getal1 = op1Evaluation.previousPrecedence < op.precedence ? leftParenthesis+getal1+rightParenthesis : getal1
                getal2 = op2Evaluation.previousPrecedence < op.precedence ? leftParenthesis+getal2+rightParenthesis : getal2
                // get the order of the variables right Project 2.7.b
                // we put getal2 before getal1
                return(getal2+operation+getal1, op2Evaluation.remainingOps, op.precedence)
            case .Constant(let constant, _):// Project 2.7.c
                return (constant, remainingOps, op.precedence)
                // is the next on the stack a variable?
            case .Variable(let variableName):// Project 2.7.c
                // return the corresponding variable name
                // what happens if variableName is unknown?
                return (variableName, remainingOps, op.precedence)
            }
        }
        return(nil, ops, Int.max)
    }

    var description: String? {
        // Note that description has been defined as an optional string
        get {
            let comma = ","
            // opStack will not be consumed and will still be available
            var (opStackDescription, remainder, _) = evaluateDescription(OpStack)
// print("\(OpStack) - \(opStackDescription) with \(remainder) left over")
            // the entire opStack should be consumed
            while remainder.count != 0 { // Project 2.7.f
                let evaluation = evaluateDescription(remainder)
                opStackDescription = evaluation.result != nil ? evaluation.result!+comma+opStackDescription! : opStackDescription // Project 2.Hint.8, separate trees with comma's
                remainder = evaluation.remainingOps
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
        learnOp(Op.BinaryOperation("+", 1, +, nil))
        learnOp(Op.BinaryOperation("−", 1, {$1-$0}, nil))
        learnOp(Op.BinaryOperation("×", 2, *,nil))
        learnOp(Op.BinaryOperation("÷", 2, {$1/$0}, {(s1,s2) in s1==0 ? "Divide by zero" : nil}))
        learnOp(Op.UnaryOperation("√",sqrt, {(s1) in s1<=0 ? "Sqrt of negative number" : nil}))
        learnOp(Op.UnaryOperation("sin",sin, nil))
        learnOp(Op.UnaryOperation("cos",cos, nil))
        learnOp(Op.Constant("π", M_PI)) // Project 2.Hint.5
    }
    
    func pushOperand(getal: Double) -> ResultOrError? {
        OpStack.append(Op.Getal(getal))
        return evaluateAndReportErrors()
    }
    
    // Project 2.5
    func pushOperand(symbol: String) -> ResultOrError? {
        // Note that the value of symbol should be set by the caller.
        // Would like to change symbol to String?
        if symbol != "" {
            OpStack.append(Op.Variable(symbol))
        }
        // does this work? Is there something to evaluate?
        return evaluateAndReportErrors()
    }
    
    func performOperation(symbol: String) -> ResultOrError? {
        if let operation = knownOps[symbol] {
            OpStack.append(operation)
        }
        return evaluateAndReportErrors()
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            //  passed arrays are immutable and must be copies to work upon
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Getal(let getal):
                return (getal, remainingOps)
            case .UnaryOperation(_, let operation, _):
                let operandEvaluation = evaluate(remainingOps)
                if let getal = operandEvaluation.result {
                    // merk op het gebruik van operation hier
                    return (operation(getal), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, _, let operation, _):
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
    
    // Project.2.Extra.2.Hint.3a
    enum ResultOrError {
        case Result(Double?)
        case Error(String?)
    }

    // Project.2.Extra.2
    private func evaluateWithErrors(ops: [Op]) -> (result: ResultOrError, remainingOps: [Op]) {
        let OperandMissing = "Do we ever get to this error?"
        if !ops.isEmpty {
            //  passed arrays are immutable and must be copies to work upon
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Getal(let getal):
                return (ResultOrError.Result(getal), remainingOps)
                
            case .UnaryOperation(_, let operation, let errorTest):
                // do the recursion first
                let operandEvaluation = evaluateWithErrors(remainingOps)
                // check if an error or result has been returned
                switch operandEvaluation.result {
                case .Result(let getal):
                    // now we can use the resut to perform the unaray operation
                    // first we need to check of the unary operation is allowed (and available)
                    // Project 2;Extras.2.Hint.3f suggestion - check existance op operands
                    if let waarde = getal {
                        if let failureDescription = errorTest?(waarde) {
                            // an failure has been found, so return that
                            return (ResultOrError.Error(failureDescription), operandEvaluation.remainingOps)
                        } else {
                            // merk op het gebruik van operation hier
                            return (ResultOrError.Result(operation(waarde)), operandEvaluation.remainingOps)
                        }
                    } else {
                            return (ResultOrError.Error(OperandMissing), operandEvaluation.remainingOps)
                    }
                case .Error(let failureDescription):
                    // an error description has been returned, pass it on
                    return (ResultOrError.Error(failureDescription), operandEvaluation.remainingOps)
                }
                
            case .BinaryOperation(_, _, let operation, let errorTest):
                let op1Evaluation = evaluateWithErrors(remainingOps)
                switch op1Evaluation.result {
                case .Result(let getal1):
                    if let waarde1 = getal1 {
                        let op2Evaluation = evaluateWithErrors(op1Evaluation.remainingOps)
                        switch op2Evaluation.result {
                        case .Result(let getal2):
                            if let waarde2 = getal2 {
                                // Project 2;Extras.2.Hint.3f suggestion
                                if let failureDescription = errorTest?(waarde1,waarde2) {
                                    // an failure has been found, so return that
                                    return (ResultOrError.Error(failureDescription), op2Evaluation.remainingOps)
                                } else {
                                    return(ResultOrError.Result(operation(waarde1, waarde2)), op2Evaluation.remainingOps)
                                }
                            } else {
                                return (ResultOrError.Error(OperandMissing), op1Evaluation.remainingOps)
                            }
                        case .Error(let failureDescription):
                            // an error description in operand 2 has been returned, pass it on
                            return (ResultOrError.Error(failureDescription), op2Evaluation.remainingOps)
                        }
                    } else {
                        return (ResultOrError.Error(OperandMissing), op1Evaluation.remainingOps)
                    }
                case .Error(let failureDescription):
                    // an error description in operand 1 has been returned, pass it on
                    return (ResultOrError.Error(failureDescription), op1Evaluation.remainingOps)
                }
                
            case .Constant(_, let constant):
                return (ResultOrError.Result(constant), remainingOps)
                // is the next on the stack a variable?
                
            case .Variable(let variableName): // Project 2.5
                // return the corresponding variable value
                // project 2.6 return nil if value does not exist
                if let variableValue = variableValues[variableName] {
                    
                    return (ResultOrError.Result(variableValue!), remainingOps)
                } else {
                    return (ResultOrError.Error("Variable "+variableName+" not yet set"), remainingOps)
                }
            }
        }
        return(ResultOrError.Error("Operand(s) missing"), ops)
    }

    // Project.2.Extra.2
    func evaluateAndReportErrors() -> ResultOrError {
        // opStack will not be consumed and will still be available
        let (result, _) = evaluateWithErrors(OpStack)
        return result
    }
    
    
    func removeLast() -> ResultOrError? {
        // Project 2.Extra.2
        // remove the last element in the Opstack
        OpStack.removeLast()
        return evaluateAndReportErrors()
    }
    
    func clearAll() { // Project 2.10 adjusted
        OpStack = []
        clearMemory() // Project 2.Hint.11 memory clear as separate function
    }
    
    func clearMemory() { // Project 2.11 remove existing variables;
        variableValues = [:]
    }
    
}