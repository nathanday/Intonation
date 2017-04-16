//
//  Composite.swift
//  Intonation
//
//  Created by Nathaniel Day on 18/03/17.
//  Copyright © 2017 Nathan Day. All rights reserved.
//

import Foundation

struct Composite : CustomStringConvertible,  CustomDebugStringConvertible, Hashable {
    let         factors : [(factor:UInt,power:UInt)];
    let         value : Int64;
    init( factors anElements: [(factor:UInt,power:UInt)]) {
        factors = anElements;
        var theResult : UInt = 1;
        for (aFactor,aPower) in factors {
            theResult *= pow(aFactor,aPower);
        }
        value = Int64(theResult);
    }
    init( factors anElements: (factor:UInt,power:UInt)...) {
        self.init(factors:anElements);
    }
    init(factor aPrime: UInt, power anExponent: UInt ) {
        factors = [(factor:aPrime,power:anExponent)];
        value = Int64(pow(aPrime,anExponent));
    }

    public var description: String { return "\(value)"; }

    public var debugDescription: String {
        var     theResult : String? = nil;
        for (p,e) in factors {
            if let r = theResult {
                theResult = r + "*\(p)^\(e)"
            } else {
                theResult = "\(p)^\(e)";
            }
        }
        return theResult ?? "";
    }

    public var hashValue: Int { return value.hashValue; }

    public var primeFactors : [UInt] {
        var     r : [UInt] = [];
        for (p,_) in factors {
            r.append(p);
        }
        return r;
    }
}

extension Composite : ExpressibleByArrayLiteral {
    // MARK: ExpressibleByArrayLiteral
    init( arrayLiteral anElements: (factor:UInt,power:UInt)...) {
        self.init(factors:anElements);
    }
    
}

extension Composite : SignedInteger  {
    // MARK: ExpressibleByIntegerLiteral
    init(integerLiteral aValue: UInt) {
        self.init(factors:aValue.everyPrimeFactor );
    }

    // MARK: IntegerArithmetic
    static func addWithOverflow(_ lhs: Composite, _ rhs: Composite) -> (Composite, overflow: Bool) {
        let     r = UInt.addWithOverflow(UInt(lhs.value),UInt(rhs.value));
        return (Composite(integerLiteral:r.0), overflow: r.overflow);
    }

    static func divideWithOverflow(_ lhs: Composite, _ rhs: Composite) -> (Composite, overflow: Bool) {
        
    }

    static func multiplyWithOverflow(_ lhs: Composite, _ rhs: Composite) -> (Composite, overflow: Bool) {
        var     theResukt = [(factor:UInt,power:UInt)]();
        var     theLhsIndex = 0,
                theRhsIndex = 0;
        while( theLhsIndex < lhs.factors.count || theRhsIndex < rhs.factors.count ) {
            let     theLhsValue = lhs.factors[theLhsIndex],
                    theRhsValue = rhs.factors[theRhsIndex];
        }
    }

    static func remainderWithOverflow(_ lhs: Composite, _ rhs: Composite) -> (Composite, overflow: Bool) {
        
    }

    static func subtractWithOverflow(_ lhs: Composite, _ rhs: Composite) -> (Composite, overflow: Bool) {
        
    }

    static func %(lhs: Composite, rhs: Composite) -> Composite {
        
    }

    static func *(lhs: Composite, rhs: Composite) -> Composite {
        
    }
    
    static func +(lhs: Composite, rhs: Composite) -> Composite {
        
    }
    
    static func /(lhs: Composite, rhs: Composite) -> Composite {
        
    }

    static func <(lhs: Composite, rhs: Composite) -> Bool {
        
    }
    
    static func <=(lhs: Composite, rhs: Composite) -> Bool {
        
    }
    
    static func ==(lhs: Composite, rhs: Composite) -> Bool {
        return lhs.value == rhs.value;
    }
    
    static func >(lhs: Composite, rhs: Composite) -> Bool {
        
    }
    
    static func >=(lhs: Composite, rhs: Composite) -> Bool {
        
    }
    
    static func -(lhs: Composite, rhs: Composite) -> Composite {
        
    }

    func toIntMax() -> IntMax {
        
    }
}
