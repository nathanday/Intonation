//
//  SpectrumView.swift
//  Equal Temperament
//
//  Created by Nathan Day on 17/04/15.
//  Copyright (c) 2015 Nathan Day. All rights reserved.
//

import Cocoa

enum SpectrumType {
	case triange
	case square
};

class SpectrumView: ResultView {
	var		spectrumType : SpectrumType = .triange;

	override func drawRect(dirtyRect: NSRect) {
		let		theBounds = NSInsetRect(self.bounds, 20.0, 20.0);
		super.drawRect(dirtyRect);
	}
}
