//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by arnaud on 21/12/15.
//  Copyright © 2015 Hovering Above. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    // is in Swift 2 gewijzigd van Printable naar CustomStringConvertable
    private enum Op :CustomStringConvertible
    {
        case Getal(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Constant(String, Double)
        
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
                }
            }
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
        learnOp(Op.Constant("π", M_PI))
    }
    
    func pushOperand(getal: Double) -> Double? {
        OpStack.append(Op.Getal(getal))
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
    
    func clear() {
        OpStack = []
    }
}