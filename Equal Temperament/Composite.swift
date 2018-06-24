//
//  Composite.swift
//  Intonation
//
//  Created by Nathaniel Day on 18/03/17.
//  Copyright © 2017 Nathan Day. All rights reserved.
//

import Foundation

struct Composite : CustomStringConvertible,  CustomDebugStringConvertible, Hashable {
    let         factors : [(factor:UInt,power:Int)];
	let			negative : Bool;
	init( factors anElements: [(factor:UInt,power:Int)], negative aNegative : Bool = false ) {
		factors = anElements.sorted { (a, b) -> Bool in a.power > b.power; }
		negative = aNegative;
    }
    init( factors anElements: (factor:UInt,power:Int)...) {
        self.init(factors:anElements);
    }
    init(factor aPrime: Int, power anExponent: Int ) {
        factors = [(factor:UInt(aPrime),power:anExponent)];
		negative = aPrime < 0;
    }

	var		toInt : Int { return toRational.toInt; }
	var		toFloat : Float { return toRational.toFloat; }
	var		toRational : Rational {
		var		theResultNumerator = 1,
		theResultDenominator = 1;
		for theElement in factors.reversed() {
			if theElement.power > 0 {
				theResultNumerator *= pow(theElement.factor,theElement.power);
			} else {
				theResultDenominator *= pow(theElement.factor,theElement.power);
			}
		}
		return Rational(theResultNumerator,theResultDenominator);
	}

    public var description: String { return toRational.description; }

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

	func hash(into aHasher: inout Hasher) {
		aHasher.combine(value)
	}

    public var primeFactors : [UInt] {
		return factors.map { $0.factor; };
    }
}

extension Composite : ExpressibleByArrayLiteral {
    // MARK: ExpressibleByArrayLiteral
    init( arrayLiteral anElements: (factor:UInt,power:Int)...) {
        self.init(factors:anElements);
    }
    
}

extension Composite : SignedInteger  {
	init?<T>(exactly source: T) where T : BinaryFloatingPoint {
		<#code#>
	}

	init<T>(_ source: T) where T : BinaryFloatingPoint {
		<#code#>
	}

	init<T>(_ source: T) where T : BinaryInteger {
		<#code#>
	}

	var words: [UInt] {
		<#code#>
	}

	var bitWidth: Int {
		<#code#>
	}

	var trailingZeroBitCount: Int {
		<#code#>
	}

	typealias Words = [UInt]

	typealias Magnitude = UInt

    // MARK: ExpressibleByIntegerLiteral
    init(integerLiteral aValue: Int) {
        self.init(factors:aValue.everyPrimeFactor );
    }

    // MARK: IntegerArithmetic
    func addingReportingOverflow(_ rhs: Composite) -> (Composite, overflow: Bool) {
        let     r = self.value.addingReportingOverflow(rhs.value);
        return (Composite(integerLiteral:r.partialValue), overflow: r.overflow);
    }

    static func divideWithOverflow(_ lhs: Composite, _ rhs: Composite) -> (Composite, overflow: Bool) {
        
    }

    static func multiplyWithOverflow(_ lhs: Composite, _ rhs: Composite) -> (Composite, overflow: Bool) {
        var     theResult = [(factor:UInt,power:Int)]();
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
		var		theResult = [(factor:UInt,power:Int)]();
		var		theLHSIndex = 0;
		var		theRHSIndex = 0;
		while theLHSIndex < lhs.factors.count || theRHSIndex < rhs.factors.count {
			if lhs.factors[theLHSIndex].factor < rhs.factors[theRHSIndex].factor {
				theResult.append(lhs.factors[theLHSIndex]);
				theLHSIndex += 1;
			} else if lhs.factors[theLHSIndex].factor > rhs.factors[theRHSIndex].factor {
				theResult.append(rhs.factors[theRHSIndex]);
				theRHSIndex += 1;
			} else {
				theResult.append( (factor:lhs.factors[theLHSIndex].factor, power:lhs.factors[theLHSIndex].power+rhs.factors[theRHSIndex].power) );
				theLHSIndex += 1;
				theRHSIndex += 1;
			}
		}
		return Composite(factors:theResult);
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

	func toIntMax() -> Int64 {
        
    }

	static func /= (lhs: inout Composite, rhs: Composite) {
		<#code#>
	}

	static func %= (lhs: inout Composite, rhs: Composite) {
		<#code#>
	}

	static func *= (lhs: inout Composite, rhs: Composite) {
		<#code#>
	}

	init?<T>(exactly source: T) where T : BinaryInteger {
		<#code#>
	}

	var magnitude: UInt {
		<#code#>
	}

	static func *= (lhs: inout Composite, rhs: Composite) {
		<#code#>
	}

}
