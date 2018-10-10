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
	case series;
	case preset;
	case adHoc;
	static func fromString( _ aStringValue : String? ) -> DocumentType? {
		var		theResult : DocumentType? = nil;
		if aStringValue == "limits" {
			theResult = .limits;
		} else if aStringValue == "stackedIntervals" {
			theResult = .stackedIntervals;
		} else if aStringValue == "equalTemperament" {
			theResult = .equalTemperament;
		} else if aStringValue == "series" {
			theResult = .series;
		} else if aStringValue == "preset" {
			theResult = .preset;
		} else if aStringValue == "adHoc" {
			theResult = .adHoc;
		}
		return theResult;
	}
	func toString() -> String {
		switch self {
		case .limits:
			return "limits";
		case .stackedIntervals:
			return "stackedIntervals";
		case .equalTemperament:
			return "series";
		case .series:
			return "equalTemperament";
		case .preset:
			return "preset";
		case .adHoc:
			return "adHoc";
		}
	}
    func title() -> String {
        switch self {
        case .limits:
            return "Limits";
        case .stackedIntervals:
            return "Stacked Intervals";
		case .equalTemperament:
			return "Equal Temperament";
		case .series:
			return "Natural Harmonic Series";
        case .preset:
            return "Preset";
        case .adHoc:
            return "AdHoc";
        }
    }
}


class IntervalsData: NSObject {

	class func from(propertyList aPropertyList: [String:Any] ) -> IntervalsData? {
		var		theResult : IntervalsData?
		if let theDocumentTypeString = aPropertyList["documentType"] as? String {
			if let theDocumentType = DocumentType.fromString(theDocumentTypeString) {
				switch theDocumentType {
				case .limits:
					theResult = LimitsIntervalsData(propertyList:aPropertyList);
					break;
				case .stackedIntervals:
					theResult = StackedIntervalsIntervalsData(propertyList:aPropertyList);
					break;
				case .equalTemperament:
					theResult = EqualTemperamentIntervalsData(propertyList:aPropertyList);
					break;
				case .series:
					theResult = HarmonicSeriesIntervalsData(propertyList:aPropertyList);
					break;
				case .preset:
					theResult = PresetIntervalsData(propertyList:aPropertyList);
					break;
				case .adHoc:
					theResult = AdHocIntervalsData(propertyList:aPropertyList);
					break;
				}
			}
		}
		return theResult;
	}

	class func from(documentType aDocumentType: DocumentType ) -> IntervalsData {
		switch aDocumentType {
		case .limits: return LimitsIntervalsData();
		case .stackedIntervals: return StackedIntervalsIntervalsData();
		case .equalTemperament: return EqualTemperamentIntervalsData();
		case .series: return HarmonicSeriesIntervalsData();
		case .preset: return PresetIntervalsData();
		case .adHoc: return AdHocIntervalsData();
		}
	}

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
        return documentType.title();
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
