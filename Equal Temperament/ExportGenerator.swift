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
	let		method : ExportMethod;
	var		delimiter : String = "\n";
	var		stringEncoding = String.Encoding.utf8;;
	var		wordSize : WordSize = .size32;
	var		endianness : Endianness = .big;
	var		everyInterval : [Interval];

	init(method aMethod : ExportMethod, everyInterval aIntervals : [Interval] ) {
		method = aMethod;
		everyInterval = aIntervals;
	}

	func saveTo(url aURL : URL ) -> Bool {
		switch method {
		case .text:
			return textSaveTo(url:aURL );
		case .binary:
			return binarySaveTo(url:aURL );
		}
	}

	func textSaveTo(url aURL : URL ) -> Bool {
		var		theText = "";
		for theInterval in everyInterval {
			if !theText.isEmpty {
				theText.append(delimiter);
			}
			theText.append("\(theInterval.toDouble)");
		}
		return (try? theText.write( to: aURL, atomically: true, encoding: stringEncoding )) != nil;
	}

	func binarySaveTo(url aURL : URL ) -> Bool {
		let		theData = NSMutableData();
		for theInterval in everyInterval {
			switch wordSize {
			case .size32:
				var		theValue = Float32(theInterval.toDouble);
				theData.append(&theValue, length: sizeof(Float32.self))
			case .size64:
				var		theValue = Float64(theInterval.toDouble);
				theData.append(&theValue, length: sizeof(Float64.self))
			}
		}
		return theData.write(to: aURL, atomically: true );
	}
}
