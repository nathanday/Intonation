//
//  HarmonicViewController.swift
//  Intonation
//
//  Created by Nathan Day on 6/12/15.
//  Copyright © 2015 Nathan Day. All rights reserved.
//

import Cocoa

class HarmonicViewController : ResultViewController {

	@IBOutlet var		harmonicView : HarmonicView?;

	override func awakeFromNib() {
		super.awakeFromNib();
		harmonicView?.dataSource = self;
	}

	func setIntervals( intervals anIntervals : [IntervalEntry], degree anIntervalCount : Int, enabled anEnable : Bool ) { }
	override func hideIntervalRelatedColumn( _ aHide : Bool ) { }

	override func selectionChanged(notification aNotification: Notification ) {
		harmonicView?.reloadData();
	}

}
