//
//  IntervalsDataGenerator.swift
//  Intonation
//
//  Created by Nathan Day on 14/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation

class IntervalsDataGenerator : CustomStringConvertible {
	var averageError : Double {
		var		theAverageError : Double = 0.0;
		let		theCount = Double(everyEntry.count);
		for theEntry in everyEntry {
			theAverageError += abs(theEntry.error12ETCent);
		}
		return theAverageError/theCount
	}

	var smallestError : Set<EqualTemperamentEntry> {
		var		theResult = Set<EqualTemperamentEntry>();
		var		theError = 0.0;
		for theEntry in everyEntry {
			if !theEntry.isOctave && !theEntry.isUnison {
				if theResult.isEmpty {
					theError = abs(theEntry.error12ETCent);
					theResult = [theEntry];
				} else {
					if abs(theError.distance(to: abs(theEntry.error12ETCent))) < 0.000001 {
						theResult.insert(theEntry);
					}
					else if theError > abs(theEntry.error12ETCent) {
						theError = abs(theEntry.error12ETCent);
						theResult = [theEntry];
					}
				}
			}
		}
		return theResult;
	}

	var biggestError : Set<EqualTemperamentEntry> {
		var		theResult = Set<EqualTemperamentEntry>();
		var		theError = 0.0;
		for theEntry in everyEntry {
			if !theEntry.isOctave && !theEntry.isUnison {
				if theResult.isEmpty {
					theError = abs(theEntry.error12ETCent);
					theResult = [theEntry];
				} else {
					if abs(theError.distance(to: abs(theEntry.error12ETCent))) < 0.000001 {
						theResult.insert(theEntry);
					}
					else if theError < abs(theEntry.error12ETCent) {
						theError = abs(theEntry.error12ETCent);
						theResult = [theEntry];
					}
				}
			}
		}
		return theResult;
	}
	var everyEntry : [EqualTemperamentEntry] {
		get {
			preconditionFailure("The getter for the property everyEntry must be implemented" );
		}
	}
	var description: String {
		return "entries:\(everyEntry.debugDescription)";
	}
}

