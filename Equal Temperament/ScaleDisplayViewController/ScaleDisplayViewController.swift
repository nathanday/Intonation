//
//  ScaleDisplayViewController.swift
//  Intonation
//
//  Created by Nathan Day on 6/12/15.
//  Copyright © 2015 Nathan Day. All rights reserved.
//

import Cocoa

protocol ScaleDisplayViewController {

	func setIntervals( intervals anIntervals : [IntervalEntry], degree anIntervalCount : UInt, enabled anEnable : Bool );
	func hideIntervalRelatedColumn( _ aHide : Bool );
	func setSelectionIntervals( _ aSelectionIntervals : [Interval]);

}
