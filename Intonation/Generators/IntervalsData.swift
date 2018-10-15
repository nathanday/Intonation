//
//  IntervalsData.swift
//  Intonation
//
//  Created by Nathan Day on 4/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

enum DocumentType {
	case limits;
	case stackedIntervals;
	case equalTemperament;
	case harmonicSeries;
	case preset;
	case adHoc;

	static func fromString( _ aStringValue : String? ) -> DocumentType? {
		switch aStringValue {
		case "limits": return .limits;
		case "stackedIntervals": return .stackedIntervals;
		case "equalTemperament": return .equalTemperament;
		case "harmonicSeries": return .harmonicSeries;
		case "preset": return .preset;
		case "adHoc": return .adHoc;
		default: return nil;
		}
	}
	func toString() -> String {
		switch self {
		case .limits: return "limits";
		case .stackedIntervals: return "stackedIntervals";
		case .equalTemperament: return "harmonicSeries";
		case .harmonicSeries: return "equalTemperament";
		case .preset: return "preset";
		case .adHoc: return "adHoc";
		}
	}
	var title: String {
        switch self {
        case .limits: return NSLocalizedString("Limits",comment:"Document Type Title");
        case .stackedIntervals: return NSLocalizedString("Stacked Intervals",comment:"Document Type Title");
		case .equalTemperament: return NSLocalizedString("Equal Temperament",comment:"Document Type Title");
		case .harmonicSeries: return NSLocalizedString("Natural Harmonic Series",comment:"Document Type Title");
        case .preset: return NSLocalizedString("Preset",comment:"Document Type Title");
        case .adHoc: return NSLocalizedString("AdHoc",comment:"Document Type Title");
        }
    }

	func instance() -> IntervalsData {
		switch self {
		case .limits: return LimitsIntervalsData();
		case .stackedIntervals: return StackedIntervalsIntervalsData();
		case .equalTemperament: return EqualTemperamentIntervalsData();
		case .harmonicSeries: return HarmonicSeriesIntervalsData();
		case .preset: return PresetIntervalsData();
		case .adHoc: return AdHocIntervalsData();
		}
	}
	static func instance(fromPropertyList aPropertyList: [String:Any] ) -> IntervalsData? {
		var		theResult : IntervalsData?
		if let theDocumentTypeString = aPropertyList["documentType"] as? String {
			switch DocumentType.fromString(theDocumentTypeString) {
			case .limits?: theResult = LimitsIntervalsData(propertyList:aPropertyList);
			case .stackedIntervals?: theResult = StackedIntervalsIntervalsData(propertyList:aPropertyList);
			case .equalTemperament?: theResult = EqualTemperamentIntervalsData(propertyList:aPropertyList);
			case .harmonicSeries?: theResult = HarmonicSeriesIntervalsData(propertyList:aPropertyList);
			case .preset?: theResult = PresetIntervalsData(propertyList:aPropertyList);
			case .adHoc?: theResult = AdHocIntervalsData(propertyList:aPropertyList);
			case nil: theResult = nil;
			}
		}
		return theResult;
	}
}

class IntervalsData: NSObject {

	override init() {
		octavesCount = min(max(UserDefaults.standard.integer(forKey: "octavesCount"),1),3);
		autoAnchor = UserDefaults.standard.bool(forKey: "autoAnchor");
		midiAnchor = Int(UserDefaults.standard.integer(forKey: "midiAnchor"));
	}

	init?(propertyList aPropertyList: [String:Any] ) {
		if let theOctavesCount = aPropertyList["octavesCount"] as? Int,
			let theAutoAnchor = aPropertyList["autoAnchor"] as? Bool,
			let theMidiAnchor = aPropertyList["midiAnchor"] as? Int,
			let theTone = aPropertyList["tone"] as? [String:Any]
		{
			octavesCount = theOctavesCount;
			autoAnchor = theAutoAnchor;
			midiAnchor = theMidiAnchor;
			if let theBaseFrequency = theTone["baseFrequency"] as? Double {
				baseFrequency = theBaseFrequency;
			}
			if let theAllOvertonesAmount = theTone["allOvertonesAmount"] as? Double,
				let theEvenOvertonesAmount = theTone["evenOvertonesAmount"] as? Double {
				overtones = HarmonicsDescription(amount: theAllOvertonesAmount, evenAmount: theEvenOvertonesAmount );
			}
		}
	}

	func intervalsDataGenerator() -> IntervalsDataGenerator {
		preconditionFailure("The method intervalsDataGenerator is abstract and must be overriden");
	}

	var propertyListValue : [String:Any] {
		let		theResult : [String:Any] = [
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

	static func	indexForLargestPrimeLessThanOrEuqalTo( _ aValue : UInt ) -> Int? {
		var		i = 0;
		guard aValue >= 2 else {
			return nil;
		}
		for p in PrimesSequence(end: aValue ) {
			if p >= aValue { return i; }
			i += 1;
		}
		return nil;
	}

    var     documentTypeTitle : String {
        return documentType.title;
    }

	var		documentType : DocumentType {
		get { preconditionFailure("The property documentType is abstract and must be overriden"); }
	}

	@objc dynamic var		octavesCount : Int = 1 {
		didSet {
			UserDefaults.standard.set(octavesCount, forKey:"octavesCount");
		}
	}
	@objc dynamic var		autoAnchor : Bool = false {
		didSet { UserDefaults.standard.set( autoAnchor, forKey:"autoAnchor"); }
	}
	@objc dynamic var		midiAnchor : Int = 60 {
		didSet { UserDefaults.standard.set(midiAnchor, forKey: "midiAnchor"); }
	}

	@objc dynamic var		baseFrequency : Double = 220.0;

	var		overtones : HarmonicsDescription = HarmonicsDescription( );
	@objc dynamic var		arpeggioInterval : Double = 0.5;
}
