/*
	Scale.swift
	Equal Temperament

	Created by Nathan Day on 20/03/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Foundation

struct Interval : Hashable {
	private static let	rationNames : [Rational:[String]] = [Rational(1,1):["unison"],
		Rational(81,80):["syntonic comma"],
		Rational(128,125):["diesis", "diminished second"],
		Rational(25,24):["lesser chromatic semitone", "minor semitone", "augmented unison"],
		Rational(256,243):["Pythagorean minor second", "Pythagorean limma"],
		Rational(135,128):["greater chromatic semitone", "wide augmented unison"],
		Rational(16,15):["major semitone", "limma", "minor second"],
		Rational(27,25):["large limma", "acute minor second"],
		Rational(800,729):["grave tone", "grave major second"],
		Rational(10,9):["minor tone", "lesser major second"],
		Rational(9,8):["major tone", "Pythagorean major second", "greater major second"],
		Rational(256,225):["diminished third"],
		Rational(125,108):["semi-augmented second"],
		Rational(75,64):["augmented second"],
		Rational(32,27):["Pythagorean minor third"],
		Rational(6,5):["minor third"],
		Rational(243,200):["acute minor third"],
		Rational(100,81):["grave major third"],
		Rational(5,4):["major third"],
		Rational(81,64):["Pythagorean major third"],
		Rational(32,25):["classic diminished fourth"],
		Rational(125,96):["classic augmented third"],
		Rational(675,512):["wide augmented third"],
		Rational(4,3):["perfect fourth"],
		Rational(27,20):["acute fourth[1]"],
		Rational(25,18):["classic augmented fourth"],
		Rational(45,32):["augmented fourth"],
		Rational(64,45):["diminished fifth"],
		Rational(36,25):["classic diminished fifth"],
		Rational(40,27):["grave fifth[1]"],
		Rational(3,2):["perfect fifth"],
		Rational(1024,675):["narrow diminished sixth"],
		Rational(192,125):["classic diminished sixth"],
		Rational(25,16):["classic augmented fifth"],
		Rational(128,81):["Pythagorean minor sixth"],
		Rational(8,5):["minor sixth"],
		Rational(81,50):["acute minor sixth"],
		Rational(5,3):["major sixth"],
		Rational(27,16):["Pythagorean major sixth"],
		Rational(128,75):["diminished seventh"],
		Rational(225,128):["augmented sixth"],
		Rational(16,9):["Pythagorean minor seventh"],
		Rational(9,5):["minor seventh"],
		Rational(729,400):["acute minor seventh"],
		Rational(50,27):["grave major seventh"],
		Rational(15,8):["major seventh"],
		Rational(256,135):["narrow diminished octave"],
		Rational(243,128):["Pythagorean major seventh"],
		Rational(48,25):["diminished octave"],
		Rational(125,64):["augmented seventh"],
		Rational(160,81):["semi-diminished octave"],
		Rational(2,1):["octave"],

		Rational(20,9):["minor ninth"],
		Rational(9,4):["major ninth"],
		Rational(12,5):["minor tenth"],
		Rational(5,2):["major tenth"],
		Rational(8,3):["major eleventh"],
		Rational(3,1):["perfect twelfth"],
		Rational(16,5):["minor thirteenth"],
		Rational(10,3):["major thirteenth"],
	];
	let		ratio: Rational;
	let		names: [String]?;
	func	equalTemperamentValue( forIntervalCount anIntervals: UInt ) -> Double {
		return floor(Double(anIntervals)*log2(justInternation)+0.5);
	}
	func	equalTemperamentRatio( forIntervalCount anIntervals: UInt ) -> Double {
		return pow(2.0,equalTemperamentValue(forIntervalCount:anIntervals)/Double(anIntervals));
	}
	var		justInternation : Double { get { return ratio.toDouble; } }
	var		numerator: Int { get { return ratio.numerator; } }
	var		denominator: Int { get { return ratio.denominator; } }
	init( ratio aRatio: Rational, names aNames: [String]? ) { ratio = aRatio; names = aNames; }
	init( ratio aRatio: Rational ) {
		let		theNames = Interval.rationNames[aRatio];
		self.init( ratio:aRatio, names:theNames );
	}
	var hashValue: Int { get { return ratio.hashValue; } }
}

func == (a: Interval, b: Interval) -> Bool { return a.ratio==b.ratio; }


class IntervalSet : SequenceType {
	let		name : String;
	let		everyInterval : [Rational];
	var		numberOfDegrees : Int { get { return everyInterval.count; } }

	init(name aName: String, element anElements: [Rational]) {
		name = aName;
		everyInterval = anElements.sort { (a:Rational, b:Rational) -> Bool in return a < b; };
	}

	subscript(anIndex:Int) -> Rational! {
		get {
			return anIndex >= 0 ? everyInterval[anIndex%numberOfDegrees]*(anIndex/numberOfDegrees+1) : nil;
		}
	}

	func generate() -> AnyGenerator<Rational> {
		var		index = 0;
		return AnyGenerator {
			var		theResult : Rational? = nil;
			if index < self.numberOfDegrees {
				theResult = self[index];
				index += 1;
			}
			return theResult;
		}
	}

	func indexOf( aValue : Rational ) -> Int? {
		for i in 0..<numberOfDegrees {
			if self[i] == aValue {
				return i;
			}
		}
		return nil;
	}

	func intervalClosestTo( aValue : Double ) -> Rational? {
		var		theResult : Rational? = nil;
		var		thePrevious : Rational? = nil;
		for theInterval in everyInterval {
			if theInterval.toDouble > aValue {
				if let thePreviousValue = thePrevious {
					if abs(thePreviousValue.toDouble-aValue) < abs(theInterval.toDouble-aValue) {
						theResult = thePreviousValue;
						break;
					}
					else {
						theResult = theInterval;
						break;
					}
				}
				else {
					theResult = theInterval;
					break;
				}
			}
			thePrevious = theInterval;
		}
		return theResult;
	}

	func sortedByDifferentsTo( aValue : Double ) -> [Rational] {
		return everyInterval.sort { (a:Rational, b:Rational) -> Bool in return abs(a.toDouble-aValue) < abs(b.toDouble-aValue); };
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
}

class Chord  : IntervalSet {
}

class Scale : IntervalSet {
	static let major : Scale = Scale(name:"major", element:[Rational(1,1), Rational(9,8), Rational(5,4), Rational(4,3), Rational(3,2), Rational(5,3), Rational(15,8)]);
	static let minor : Scale = Scale(name:"minor", element:[Rational(1,1), Rational(9,8), Rational(6,5), Rational(4,3), Rational(3,2), Rational(8,5), Rational(9,5)]);

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
