//
//  IntervalsData.swift
//  Intonation
//
//  Created by Nathan Day on 4/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

enum DocumentType {
	case Limits;
	case StackedIntervals;
	case EqualTemperament;
	case Preset;
	case AdHoc;
	static func fromString( aStringValue : String? ) -> DocumentType? {
		var		theResult : DocumentType? = nil;
		if aStringValue == "limits" {
			theResult = .Limits;
		} else if aStringValue == "stackedIntervals" {
			theResult = .StackedIntervals;
		} else if aStringValue == "equalTemperament" {
			theResult = .EqualTemperament;
		} else if aStringValue == "preset" {
			theResult = .Preset;
		} else if aStringValue == "adHoc" {
			theResult = .AdHoc;
		}
		return theResult;
	}
	func toString() -> String {
		switch self {
		case Limits:
			return "limits";
		case StackedIntervals:
			return "stackedIntervals";
		case EqualTemperament:
			return "equalTemperament";
		case Preset:
			return "preset";
		case AdHoc:
			return "adHoc";
		}
	}
}


class IntervalsData: NSObject {
	static let		minimumBaseFrequency = 16.0;
	static let		maximumBaseFrequency = 12_544.0;

	class func from(propertyList aPropertyList: [String:AnyObject] ) -> IntervalsData? {
		var		theResult : IntervalsData?
		if let theDocumentTypeString = aPropertyList["documentType"] as? String {
			if let theDocumentType = DocumentType.fromString(theDocumentTypeString) {
				switch theDocumentType {
				case .Limits:
					theResult = LimitsIntervalsData(propertyList:aPropertyList);
					break;
				case .StackedIntervals:
					theResult = StackedIntervalsIntervalsData(propertyList:aPropertyList);
					break;
				case .EqualTemperament:
					theResult = EqualTemperamentIntervalsData(propertyList:aPropertyList);
					break;
				case .Preset:
					theResult = PresetIntervalsData(propertyList:aPropertyList);
					break;
				case .AdHoc:
					theResult = AdHocIntervalsData(propertyList:aPropertyList);
					break;
				}
			}
		}
		return theResult;
	}

	class func from(documentType aDocumentType: DocumentType ) -> IntervalsData {
		switch aDocumentType {
		case .Limits: return LimitsIntervalsData();
		case .StackedIntervals: return StackedIntervalsIntervalsData();
		case .EqualTemperament: return EqualTemperamentIntervalsData();
		case .Preset: return PresetIntervalsData();
		case .AdHoc: return AdHocIntervalsData();
		}
	}

	override init() {
		octavesCount = min(max(UInt(NSUserDefaults.standardUserDefaults().integerForKey("octavesCount")),1),3);
		autoAnchor = NSUserDefaults.standardUserDefaults().boolForKey("autoAnchor");
		midiAnchor = Int(NSUserDefaults.standardUserDefaults().integerForKey("midiAnchor"));
	}

	init?(propertyList aPropertyList: [String:AnyObject] ) {
		if let theOctavesCount = aPropertyList["octavesCount"] as? UInt,
			theAutoAnchor = aPropertyList["autoAnchor"] as? Bool,
			theMidiAnchor = aPropertyList["midiAnchor"] as? Int,
			theTone = aPropertyList["tone"] as? [String:AnyObject]
		{
			octavesCount = theOctavesCount;
			autoAnchor = theAutoAnchor;
			midiAnchor = theMidiAnchor;
			if let theBaseFrequency = theTone["baseFrequency"] as? Double {
				baseFrequency = theBaseFrequency;
			}
			if let theAllOvertonesAmount = theTone["allOvertonesAmount"] as? Double,
				theEvenOvertonesAmount = theTone["evenOvertonesAmount"] as? Double {
				overtones = HarmonicsDescription(amount: theAllOvertonesAmount, evenAmount: theEvenOvertonesAmount);
			}
		}
	}

	func intervalsDataGenerator() -> IntervalsDataGenerator {
		preconditionFailure("The method intervalsDataGenerator is abstract and must be overriden");
	}

	func viewController( windowController aWindowController : MainWindowController ) -> GeneratorViewController? {		preconditionFailure("The method viewController is abstract and must be overriden");
	}

	var propertyListValue : [String:AnyObject] {
		let		theResult : [String:AnyObject] = [
			"autoAnchor":autoAnchor,
			"octavesCount":octavesCount,
			"midiAnchor":midiAnchor,
			"tone":[
				"baseFrequency":baseFrequency,
				"allOvertonesAmount":overtones.amount,
				"evenOvertonesAmount":overtones.evenAmount
			]
		];
		return theResult;
	}

	static var		primeNumber = UInt.primes(upTo: 100 );
	static func	indexForLargestPrimeLessThanOrEuqalTo( aPrime : UInt ) -> Int? {
		for i in 1...primeNumber.endIndex {
			if primeNumber[i] > aPrime { return i-1; }
		}
		return nil;
	}

	var		documentType : DocumentType {
		get { preconditionFailure("The property documentType is abstract and must be overriden"); }
	}

	var		octavesCount : UInt = 1 {
		didSet {
			NSUserDefaults.standardUserDefaults().setInteger(Int(octavesCount), forKey:"octavesCount");
		}
	}
	var		autoAnchor : Bool = false {
		didSet { NSUserDefaults.standardUserDefaults().setBool( autoAnchor, forKey:"autoAnchor"); }
	}
	dynamic var		midiAnchor : Int = 60 {
		didSet { NSUserDefaults.standardUserDefaults().setInteger(midiAnchor, forKey: "midiAnchor"); }
	}

	var		baseFrequency : Double = 220.0;

	var		overtones : HarmonicsDescription = HarmonicsDescription( amount : 0.5, evenAmount: 1.0 );
	var		arpeggioInterval : Double = 0.5;
}
