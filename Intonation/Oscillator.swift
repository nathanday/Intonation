//
//  Oscillator.swift
//  Intonation
//
//  Created by Nathaniel Day on 8/12/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import Foundation
import Accelerate;

struct Oscillator {
	static let	length = 2048;
	let			harmonicsDescription: HarmonicsDescription;
	let			values : [Float32];

	init( harmonicsDescription aHarmonicsDescription: HarmonicsDescription ) {
		harmonicsDescription = aHarmonicsDescription;
		var	theValues = [Float32](repeating: 0.0, count: Oscillator.length );
		var x = [Float](repeating: 0, count: Oscillator.length );
		var y1 = [Float](repeating: 0, count: Oscillator.length );
		var n = Int32( Oscillator.length );
		harmonicsDescription.enumerateHarmonics { (aHarmonic: Int, anAmplitude: Float32) in
			for t in 0..<Oscillator.length {
				x[t] = Float(aHarmonic)*Float(t)/Float(Oscillator.length>>1);
			}

			vvsinpif( &y1, x, &n );
			for t in 0..<Oscillator.length {
				theValues[t] += anAmplitude*y1[t];
			}
		}
		values = theValues
	}
}
