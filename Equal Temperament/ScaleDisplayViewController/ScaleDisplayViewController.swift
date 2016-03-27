//
//  ScaleDisplayViewController.swift
//  Intonation
//
//  Created by Nathan Day on 6/12/15.
//  Copyright © 2015 Nathan Day. All rights reserved.
//

import Cocoa

protocol ScaleDisplayViewController {

	func setIntervals( intervals anIntervals : [EqualTemperamentEntry], degree anIntervalCount : UInt, enabled anEnable : Bool );
	func hideIntervalRelatedColumn( aHide : Bool );
	func setSelectionIntervals( aSelectionIntervals : [Interval]);

}
