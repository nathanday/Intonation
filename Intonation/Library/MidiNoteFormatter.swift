//
//  MidiNoteFormatter.swift
//  Intonation
//
//  Created by Nathaniel Day on 6/06/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import Cocoa

class MidiNoteFormatter: Formatter {

	enum AccentStyle : CustomStringConvertible {
		case flat;
		case sharp;
		case natural;
		var description: String {
			switch self {
			case .flat: return "♭";
			case .sharp: return "♯";
			case .natural: return "♮";
			}
		}
	}

	public var		accentStyle : Set<AccentStyle> = [.sharp];

	private func noteString( note aNote: Int, accentStyle aAccentStyle : AccentStyle? ) -> String {
		let		flatNoteNames = ["C", "D", "D", "E", "E", "F", "G", "G", "A", "A", "B", "B"];
		let		shartNoteNames = ["C", "C", "D", "D", "E", "F", "F", "G", "G", "A", "A", "B"];
		let		noteNames = aAccentStyle == .sharp ? shartNoteNames : flatNoteNames;
		return "\(noteNames[aNote])\(aAccentStyle?.description ?? "")";
	}

	open func string(forMidiNote anMidiNote: Int) -> String {
		var		theResult = "";
		let		theNoteNumber = anMidiNote%12;
		let		theOctave = anMidiNote/12 - 1;
		let		theAccidental = (theNoteNumber%2 == 1) != (theNoteNumber>4);
		if theAccidental {
			if accentStyle.isSuperset(of:[.flat,.sharp]) {
				theResult = noteString(note: theNoteNumber, accentStyle: .sharp) + "/" + noteString(note: theNoteNumber, accentStyle: .flat) + "\(theOctave)";
			} else if accentStyle.contains(.flat) {
				theResult = noteString(note: theNoteNumber, accentStyle: .flat) + "\(theOctave)";
			} else if accentStyle.contains(.sharp) {
				theResult = noteString(note: theNoteNumber, accentStyle: .sharp) + "\(theOctave)";
			}
		}
		else if accentStyle.contains(.natural) {
			theResult = noteString(note: theNoteNumber, accentStyle: .natural) + "\(theOctave)";
		} else {
			theResult = noteString(note: theNoteNumber, accentStyle: nil) + "\(theOctave)";
		}
		return theResult;
	}
	open override func string(for anObj: Any?) -> String? {
		guard let theObj = anObj as? NSNumber  else {
			return nil;
		}
		return string(forMidiNote:theObj.intValue);
	}

	open func midiNoteValue(for aString: String ) -> (value:Int?,error:String?) {
		let		theScanner = Scanner(string:aString);
		var		theNoteNameOut : NSString?;
		let		theValidNoteCharacters = "cdefgabCDEFGAB";
		if( theScanner.scanCharacters(from:CharacterSet(charactersIn:theValidNoteCharacters), into:&theNoteNameOut) ) {
			guard let theNoteName = theNoteNameOut as String? else {
				return (nil,"internal error")
			}
			let				theChar = theNoteName.first;
			var				theNoteNumber = (theValidNoteCharacters.firstIndex(of: theChar!)?.encodedOffset)!%7*2;
			var				theArgOut : NSString?;
			var				theOctave = 0;
			if theNoteNumber > 4 {		// no e sharp/ f flat
				theNoteNumber -= 1;
			}
			if theNoteName.count > 1 {	// should only have dealt with first character
				theScanner.scanLocation = theScanner.scanLocation - theNoteName.count + 1;
			}
			if( theScanner.scanCharacters(from:CharacterSet(charactersIn:"#b♯♭♮"), into:&theArgOut) ) {
				guard let theArg = theArgOut as String? else {
					return (nil,"internal error")
				}
				switch theArg {
				case "#", "♯":
					theNoteNumber += 1;
				case "b", "♭":
					theNoteNumber -= 1;
				default:
					break;
				}
			}

			if( theScanner.scanInt(&theOctave) ) {
				if theNoteNumber >= 12 {
					theNoteNumber = theNoteNumber%12;
					theOctave += 1;
				}
				while theNoteNumber < 0 {
					theNoteNumber += 12;
					theOctave -= 1;
				}
			} else {
				theOctave = 4;
			}
			return (value:theNoteNumber+(theOctave+1)*12,error:nil);
		}
		else {
			guard let theIntegerValue = Int(aString) else {
				return (nil,"invalid string")
			}
			if theIntegerValue < 0 || theIntegerValue > 127 {
				return (value:theIntegerValue,error:"out of bounds value \(theIntegerValue)");
			}
			return (value:theIntegerValue,error:nil);
		}
	}

	open override func getObjectValue(_ anObj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for aString: String, errorDescription anError: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
		let theResult = midiNoteValue(for: aString );

		if let theValue = theResult.value {
			anObj?.pointee = NSNumber(value:theValue);
		}
		if let theError = theResult.error {
			anError?.pointee = NSString(string:theError);
		}
		return theResult.error == nil;
	}

}
