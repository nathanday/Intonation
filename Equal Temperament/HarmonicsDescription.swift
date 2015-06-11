//
//  HarmonicsDescription.swift
//  Equal Temperament
//
//  Created by Nathan Day on 19/05/15.
//  Copyright (c) 2015 Nathan Day. All rights reserved.
//

import Cocoa

struct HarmonicsDescription {
	init( amount anAmount : Double, evenAmount anEvenAmount : Double ) {
		amount = anAmount;
		evenAmount = anEvenAmount;
	}
	var		amount : Double;
	var		evenAmount : Double;
}
