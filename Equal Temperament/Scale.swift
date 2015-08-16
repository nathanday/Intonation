/*
	Scale.swift
	Equal Temperament

	Created by Nathan Day on 20/03/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Foundation

struct Scale : SequenceType {
	static let major : Scale = Scale(name:"major", element:Rational(1,1), Rational(9,8), Rational(5,4), Rational(4,3), Rational(3,2), Rational(5,3), Rational(15,8));
	static let minor : Scale = Scale(name:"minor", element:Rational(1,1), Rational(9,8), Rational(6,5), Rational(4,3), Rational(3,2), Rational(8,5), Rational(9,5));

	let		name : String;
	let		everyDegree : [Rational];
	var		numberOfDegrees : Int { get { return everyDegree.count; } }

	init(name aName: String, element anElements: Rational...) {
		name = aName;
		everyDegree = anElements.sort({ (a:Rational, b:Rational) -> Bool in return false; });
	}

	subscript(anIndex:Int) -> Rational! {
		get {
			return anIndex >= 0 ? everyDegree[anIndex%numberOfDegrees]*(anIndex/numberOfDegrees+1) : nil;
		}
	}

	func generate() -> AnyGenerator<Rational> {
		var		index = 0;
		return anyGenerator { return index < self.numberOfDegrees ? self[index++] : nil; }
	}

	func indexOf( aValue : Rational ) -> Int? {
		for i in 0..<numberOfDegrees {
			if self[i] == aValue {
				return i;
			}
		}
		return nil;
	}

	var description: String {
		var		theResult : String?;
		for r in self {
			if theResult == nil {
				theResult = r.ratioString;
			} else {
				theResult = ", \(r.ratioString)";
			}
		}
		return "\(name) = \(theResult)]";
	}

	static func degreeName( anIndex : Int ) -> String {
		var thePrefix : String
		switch anIndex % 10 {
		case 0 where anIndex%100 < 10:
			thePrefix = "st";
		case 1 where anIndex%100 < 10:
			thePrefix = "nd";
		case 2 where anIndex%100 < 10:
			thePrefix = "rd";
		default:
			thePrefix = "th";
		}
		return "\(anIndex+1)\(thePrefix)";
	}
}
