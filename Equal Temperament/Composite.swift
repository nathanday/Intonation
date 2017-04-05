//
//  Composite.swift
//  Intonation
//
//  Created by Nathaniel Day on 18/03/17.
//  Copyright © 2017 Nathan Day. All rights reserved.
//

import Foundation

struct Composite : CustomStringConvertible,  CustomDebugStringConvertible, Hashable {
    let     factors : [(UInt,UInt)];
    let     value : UInt64;
    init(prime aPrime: UInt, exponent anExponent: UInt ) {
        var     theValue : UInt64 = 1;
        for _ in 0..<anExponent {
            theValue *= UInt64(aPrime);
        }
        value = theValue;
        factors = [(aPrime,anExponent)];
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
    public static func ==(lhs: Composite, rhs: Composite) -> Bool { return lhs.value == rhs.value; }

    public var primeFactors : [UInt] {
        var     r : [UInt] = [];
        for (p,_) in factors {
            r.append(p);
        }
        return r;
    }
}

extension Composite : ExpressibleByArrayLiteral, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {

    static func convertFromArrayLiteral( anElements: UInt...) -> Rational {
    }
    static func convertFromArrayLiteral( anElements: (UInt,UInt)...) -> Rational {
    }
}
