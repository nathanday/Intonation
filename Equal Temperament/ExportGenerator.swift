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
	/*
	var		wordSize : WordSize = .size32;
	var		endianness : Endianness = .big;
	override func data() -> Data {
		let		theData : Data;


		switch wordSize {
		case .size32:
			let thePointer = UnsafeMutableRawPointer.allocate(bytes: everyInterval.count*MemoryLayout<Float32>.size, alignedTo: MemoryLayout<Float32>.alignment);
			for theInterval in everyInterval {
				let intPointer = Float32(theInterval.toDouble);
				let theBytes = UnsafeBufferPointer
			}
			theData = Data<Float32>(buffer:thePointer)
		case .size64:
			let thePointer = UnsafeMutableRawPointer.allocate(bytes: everyInterval.count*MemoryLayout<Float64>.size, alignedTo: MemoryLayout<Float32>.alignment);
			for theInterval in everyInterval {
				let intPointer = Float64(theInterval.toDouble);
			}
			theData = Data<Float64>(buffer:thePointer)
		}
		return Data(thePointer);
	}
	*/
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
		let	theArray = everyInterval.map { (aInterval : Interval) -> JSONEntry in
			let theName = aInterval.names?.first ?? aInterval.toString;
			return JSONEntry( name: theName, value:aInterval.toDouble );
		}
		return try JSONEncoder().encode(["intervals":theArray]);
	}
}
