//
//  StackedIntervalsDataGenerator.swift
//  Intonation
//
//  Created by Nathan Day on 20/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Cocoa

class StackedIntervalsIntervalsData : IntervalsData {
	override init() {
		super.init();
	}
	override init?(propertyList aPropertyList: [String:Any] ) {
		super.init(propertyList:aPropertyList);
		if let theEntries = aPropertyList["stackedIntervals"] as? [[String:String]] {
			for theEntry in theEntries{
				if let theStackedInterval = StackedIntervalSet(propertyList: theEntry) {
					stackedIntervals.insert(theStackedInterval);
				}
			}
		}
	}
	override var propertyListValue : [String:Any] {
		var		theResult = super.propertyListValue;
		var		theStackedIntervalsPropertyList = [[String:String]]();
		for theEntry in stackedIntervals {
			theStackedIntervalsPropertyList.append(theEntry.propertyList);
		}
		theResult["stackedIntervals"] = theStackedIntervalsPropertyList;
		return theResult;
	}

	override var	documentType : DocumentType { return .stackedIntervals; }

	override func intervalsDataGenerator() -> IntervalsDataGenerator {
		return StackedIntervalsDataGenerator(intervalsData:self);
	}
	override func viewController( windowController aWindowController : MainWindowController ) -> GeneratorViewController? {
		return StackedIntervalsGeneratorViewController(windowController:aWindowController);
	}

	var		stackedIntervals = Set<StackedIntervalSet>();

	func insertStackedInterval( _ a : StackedIntervalSet ) {
        if let theIndex = stackedIntervals.index(of: a) {
            let theExisting = stackedIntervals[theIndex];
            a.steps = max(theExisting.steps, a.steps);
            a.octaves = max(theExisting.octaves,a.octaves);
            stackedIntervals.remove(theExisting);
        }
		stackedIntervals.insert(a);
	}

	func removeStackedInterval( _ a : StackedIntervalSet ) {
		stackedIntervals.remove(a);
	}
}

class StackedIntervalsDataGenerator: IntervalsDataGenerator {
	var	_everyIntervalEntry : [IntervalEntry]?;
	override var	everyEntry : [IntervalEntry] {
		return _everyIntervalEntry!;
	}
	init( intervalsData anIntervalsData : StackedIntervalsIntervalsData ) {
		super.init();
		var		theResult = Set<IntervalEntry>();
        for theStackInterval in anIntervalsData.stackedIntervals {
            for theInterval in theStackInterval.everyInterval {
                for theOctave in 0..<anIntervalsData.octavesCount {
                    let		theOctaveValue = 1<<theOctave;
					let		theEntry = IntervalEntry(interval: theInterval*theOctaveValue );
					theResult.insert(theEntry);
				}
			}
		}
		_everyIntervalEntry = theResult.sorted { return $0.toCents < $1.toCents; };
	}
}
