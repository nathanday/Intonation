//
//  ExportGenerator.swift
//  Intonation
//
//  Created by Nathan Day on 16/05/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation

enum ExportMethod {
	case text
	case binary
	case JSON
	func exportGenerator(everyInterval aIntervals : [Interval]) -> ExportGenerator {
		switch self {
		case .text: return TextExportGenerator(everyInterval: aIntervals);
		case .binary: return BinaryExportGenerator(everyInterval: aIntervals);
		case .JSON: return JSONExportGenerator(everyInterval: aIntervals);
		}
	}
	var title : String {
		switch self {
		case .text: return "Text";
		case .binary: return "Binary";
		case .JSON: return "JSON";
		}
	}
	var fileType : String? {
		switch self {
		case .text: return "txt";
		case .binary: return nil;
		case .JSON: return "json";
		}
	}
}

enum Endianness {
	case little
	case big
}

enum WordSize {
	case size32
	case size64
}

class ExportGenerator {
	var		everyInterval : [Interval];

	init(everyInterval aIntervals : [Interval] ) {
		everyInterval = aIntervals;
	}
	func saveTo(url aURL : URL ) throws {
		if let theData = try data()  {
			try theData.write(to: aURL)
		}
	}

	func data() throws -> Data? { return nil; }
}

class TextExportGenerator : ExportGenerator {
	var		delimiter : String = "\n";
	var		stringEncoding = String.Encoding.utf8;
	override func data() -> Data? {
		var		theText = "";
		for theInterval in everyInterval {
			if !theText.isEmpty {
				theText.append(delimiter);
			}
			theText.append("\(theInterval.toDouble)");
		}
		return theText.data(using: stringEncoding, allowLossyConversion: true);
	}
}

class BinaryExportGenerator : ExportGenerator {
	var		wordSize : WordSize = .size32;
	var		endianness : Endianness = .big;
	override func data() -> Data {
		var		theArray : Array<Any>;
		switch wordSize {
		case .size32: theArray = everyInterval.map { return Float32($0.toDouble); }
		case .size64: theArray = everyInterval.map { return Float64($0.toDouble); }
		}
		return theArray.withUnsafeBytes  {  return Data($0); }
	}
}

class JSONExportGenerator : ExportGenerator {
	class JSONEntry : Encodable {
		var		name : String;
		var		value: Double;
		init( name aName : String, value aValue : Double) {
			name = aName;
			value = aValue;
		}

	}
	override func data() throws -> Data {
		let	theArray = everyInterval.map {
			return JSONEntry( name: $0.names!.first!, value:$0.toDouble );
		}
		return try JSONEncoder().encode(["intervals":theArray]);
	}
}
