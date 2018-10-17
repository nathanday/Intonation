//
//  ResultViewController.swift
//  Intonation
//
//  Created by Nathan Day on 6/12/15.
//  Copyright © 2015 Nathan Day. All rights reserved.
//

import Cocoa

class ResultViewController : NSViewController {

	@IBOutlet weak var	mainWindowController : MainWindowController!;

	override func awakeFromNib() {
		NotificationCenter.default.addObserver(forName: Document.selectionChangedNotification, object: mainWindowController.document, queue: OperationQueue.main, using: selectionChanged(notification:));
	}

	deinit {
		NotificationCenter.default.removeObserver(self);
	}

	func selectionChanged(notification aNotification: Notification ) {
		preconditionFailure("This method must be overridden")
	}

	//	func setIntervals( intervals anIntervals : [IntervalEntry], degree anIntervalCount : Int, enabled anEnable : Bool );
	func hideIntervalRelatedColumn( _ aHide : Bool ) {
		preconditionFailure("This method must be overridden")
	}
//	func setSelectionIntervals( _ aSelectionIntervals : [Interval]);

}

extension ResultViewController : ResultViewDataSource {
	var numberOfIntervals : Int {
		return mainWindowController.document?.everyInterval.count ?? 0;
	}
	var numberOfSelectedIntervals : Int {
		return mainWindowController.document?.selectedIndicies.count ?? 0;
	}
	var selectedCommonFactor : Int {
		return mainWindowController.document?.selectedCommonFactor ?? 1;
	}
	func interval(for anIndex: Int) -> Interval? {
		if let theEveryInterval = mainWindowController.document?.everyInterval {
			return theEveryInterval[anIndex].interval;
		} else {
			return nil;
		}
	}
	var selectedIndecies : IndexSet {
		return mainWindowController.document?.selectedIndicies ?? IndexSet();
	}
	var selectedInterval : [(index:Int,interval:Interval)] {
		var		theResult = [(index:Int,interval:Interval)]();
		guard let theIntervals = mainWindowController.document?.everyInterval else {
			return theResult;
		}
		guard let theSelectedIndices = mainWindowController.document?.selectedIndicies else {
			return theResult;
		}
		for theIndex in theSelectedIndices {
			theResult.append((index:theIndex,interval:theIntervals[theIndex].interval))
		}
		return theResult;
	}

	func enumerateIntervals( _ aBlock: (Int,Interval,Bool) -> Void ) {
		guard let theIntervals = mainWindowController.document?.everyInterval else {
			return;
		}
		let		theSelectedIndices = selectedIndecies;
		for (anIndex,anInterval) in theIntervals.enumerated() {
			aBlock(anIndex, anInterval.interval, theSelectedIndices.contains(anIndex));
		}
	}
	func enumerateSelectedIntervals( _ aBlock: (Int,Int,Interval) -> Void ) {
		guard let theIntervals = mainWindowController.document?.everyInterval else {
			return;
		}
		for (anIndex,aSelectedIndex) in selectedIndecies.enumerated() {
			aBlock( anIndex, aSelectedIndex, theIntervals[aSelectedIndex].interval );
		}
	}
}

