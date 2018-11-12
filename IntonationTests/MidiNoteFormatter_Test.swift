//
//  MidiNoteFormatter_Test.swift
//  IntonationTests
//
//  Created by Nathaniel Day on 6/06/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import XCTest

class MidiNoteFormatter_Test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testToString() {
		let		theMidiNoteFormatter = MidiNoteFormatter();
		theMidiNoteFormatter.accentStyle = [];
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:0), "C-1", "got “C-1” for 0" );
		theMidiNoteFormatter.accentStyle = [.natural];
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:0+(0+1)*12), "C♮0", "got “C♮0” for 0+(0+1)*12" );
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:4+(1+1)*12), "E♮1", "got “E♮1” for 4+(1+1)*12" );
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:5+(3+1)*12), "F♮3", "got “F♮3” for 5+(3+1)*12" );
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:9+(-1+1)*12), "A♮-1", "got “A♮-1” for 9+(-1+1)*12" );
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:11+(4+1)*12), "B♮4", "got “B♮4” for 1+(4+1)*12" );

		theMidiNoteFormatter.accentStyle = [.flat];
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:0+(1+1)*12), "C1", "got “C1” for 0+(1+1)*12" );
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:3+(5+1)*12), "E♭5", "got “E♭5” for 3+(5+1)*12" );
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:8+(3+1)*12), "A♭3", "got “A♭3” for 8+(3+1)*12" );
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:1+(0+1)*12), "D♭0", "got “D♭0” for 1+(0+1)*12" );

		theMidiNoteFormatter.accentStyle = [.sharp];
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:0+(2+1)*12), "C2", "got “C2” for 0+(2+1)*12" );
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:1+(5+1)*12), "C♯5", "got “C♯5” for 1+(5+1)*12" );
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:6+(4+1)*12), "F♯4", "got “F♯4” for 6+(4+1)*12" );
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:8+(2+1)*12), "G♯2", "got “G♯2” for 8+(2+1)*12" );
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:10+(0+1)*12), "A♯0", "got “A♯0” for 1+(0+1)*12" );

		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:0+(3+1)*12), "C3", "got “C3” for 0+(3+1)*12" );
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:2+(2+1)*12), "D2", "got “D2” for 2+(2+1)*12" );
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:4+(0+1)*12), "E0", "got “E0” for 4+(0+1)*12" );
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:5+(2+1)*12), "F2", "got “F2” for 5+(2+1)*12" );

		theMidiNoteFormatter.accentStyle = [.natural,.flat,.sharp];
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:3+(-1+1)*12), "D♯/E♭-1", "got “D♯/E♭-1” for 3+(-1+1)*12" );
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:1+(1+1)*12), "C♯/D♭1", "got “C♯/D♭1” for 1+(1+1)*12" );
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:0+(4+1)*12), "C♮4", "got “C♮4” for 0+(4+1)*12" );

		theMidiNoteFormatter.accentStyle = [.sharp,.natural];
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:1+(-1+1)*12), "C♯-1", "got “C♯-1” for 1+(-1+1)*12" );

		theMidiNoteFormatter.accentStyle = [.flat,.sharp];
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:6+(-1+1)*12), "F♯/G♭-1", "got “F♯/G♭-1” for 6+(-1+1)*12" );
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:10+(2+1)*12), "A♯/B♭2", "got “A♯/B♭2” for 1+(2+1)*12" );
		XCTAssertEqual( theMidiNoteFormatter.string(forMidiNote:11+(3+1)*12), "B3", "got “B3” for 1+(3+1)*12" );
    }

	func testFromString() {
		let		theMidiNoteFormatter = MidiNoteFormatter();
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"C-1").value!, 0, "got \(0) for “C-1”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"C♮0").value!, 0+(0+1)*12, "got \(0+(0+1)*12) for “C♮0”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"E♮1").value!, 4+(1+1)*12, "got \(4+(1+1)*12) for “E♮1”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"F♮3").value!, 5+(3+1)*12, "got \(5+(3+1)*12) for “F♮3”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"A♮-1").value!, 9+(-1+1)*12, "got \(9+(-1+1)*12) for “A♮-1”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"B♮4").value!, 11+(4+1)*12, "got \(11+(4+1)*12) for “B♮4”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"C1").value!, 0+(1+1)*12, "got \(0+(1+1)*12) for “C1”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"E♭5").value!, 3+(5+1)*12, "got \(3+(5+1)*12) for “E♭5”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"Ab3").value!, 8+(3+1)*12, "got \(8+(3+1)*12) for “Ab3”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"D♭0").value!, 1+(0+1)*12, "got \(1+(0+1)*12) for “D♭0”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"C2").value!, 0+(2+1)*12, "got \(0+(2+1)*12) for “C2”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"C♯5").value!, 1+(5+1)*12, "got \(1+(5+1)*12) for “C♯5”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"F#4").value!, 6+(4+1)*12, "got \(6+(4+1)*12) for “F♯4”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"G#2").value!, 8+(2+1)*12, "got \(8+(2+1)*12) for “G#2”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"A♯0").value!, 10+(0+1)*12, "got \(10+(0+1)*12) for “A♯0”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"C3").value!, 0+(3+1)*12, "got \(0+(3+1)*12) for “C3”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"D2").value!, 2+(2+1)*12, "got \(2+(2+1)*12) for “D2”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"E0").value!, 4+(0+1)*12, "got \(4+(0+1)*12) for “E0”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"F2").value!, 5+(2+1)*12, "got \(5+(2+1)*12) for “F2”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"xxx").error!, "invalid string", "got \(3+(-1+1)*12) for “D♯/E♭-1”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"C").value!, 60, "got \(60) for “C”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"C♮4").value!, 0+(4+1)*12, "got \(0+(4+1)*12) for “C♮4”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"C♯-1").value!, 1+(-1+1)*12, "got \(1+(-1+1)*12) for “C♯-1”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"B3").value!, 11+(3+1)*12, "got \(11+(3+1)*12) for “B3”" );

		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"60").value!, 60, "got \(60) for “60”" );

		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"129").error!, "out of bounds value 129", "got “out of bounds value” error for “129”" );

		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"B#3").value!, 12+(3+1)*12, "got \(12+(3+1)*12) for “B#3”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"Cb3").value!, -1+(3+1)*12, "got \(-1+(3+1)*12) for “B#3”" );

		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"A4").value!, 69, "got \(69) for “A4”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:" A4").value!, 69, "got \(69) for “A4”" );
		XCTAssertEqual( theMidiNoteFormatter.midiNoteValue(for:"A4 ").value!, 69, "got \(69) for “A4”" );
	}

	func testOverridenAPI() {
		let		theMidiNoteFormatter = MidiNoteFormatter();
		let		theString = theMidiNoteFormatter.string(for: NSNumber(integerLiteral: 60));
		XCTAssertNotNil( theString, "\(String(describing: theString)) is not nil" );
		XCTAssertEqual( theString!, "C4", "\(String(describing: theString)) == C4" );

		var		theValue : AnyObject?
		var		theError : NSString?
		XCTAssertEqual( theMidiNoteFormatter.getObjectValue(&theValue, for: theString!, errorDescription: &theError), true,
						   "\(String(describing:theString)) got value" );
		XCTAssertNotNil( theValue, "\(String(describing: theString)) got value" );
		XCTAssertEqual( (theValue as? NSNumber)?.intValue, 60, "\(String(describing: theString)) is equal to 60" );
	}
}
