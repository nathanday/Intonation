//
//  WaveTable.swift
//  Intonation
//
//  Created by Nathaniel Day on 28/06/17.
//  Copyright © 2017 Nathan Day. All rights reserved.
//

import Foundation
import Accelerate

struct WaveTable {
	let		samples : [Float32];
	let		harmonicsDescription : HarmonicsDescription;
	var		length : Int { return samples.count; }

	init( _ aHarmonicsDescription : HarmonicsDescription) {
		harmonicsDescription = aHarmonicsDescription;
		vvsinf(UnsafeMutablePointer<Float>, <#T##UnsafePointer<Float>#>, <#T##UnsafePointer<Int32>#>)
	}
}
