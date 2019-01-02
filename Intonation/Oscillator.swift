//
//  Oscillator.swift
//  Intonation
//
//  Created by Nathaniel Day on 8/12/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import Foundation
import Accelerate;
import simd;

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
			Oscillator.rampedValues(x: &x, xc: x.count, value: 2.0*Float(aHarmonic))
			vvsinpif( &y1, x, &n );
			Oscillator.accumlateScaledFloats(y: &theValues, x: y1, yc: theValues.count, a: anAmplitude);
		}
		values = theValues
	}

	subscript(anX: Float) -> Float {
		get {
			let		theIndex = Int(anX);
			let		theX0 = floor(anX);
			let		theX1 = ceil(anX);
			let		theY0 = values[theIndex];
			let		theY1 = values[theIndex+1];
			return theY0*(anX-theX1)/(theX0-theX1)+theY1*(anX-theX0)/(theX1-theX0);
		}
	}

	static private func rampedValues(x: UnsafeMutablePointer<Float>, xc: Int, value aValue: Float) {
		assert( xc%4 == 0, "The length of the arrays must be multiples of 4" );
		if xc < 4 {
			return;
		}
		let		theXLen = xc>>2;
		let		thheDelta = aValue/Float(xc);
		let 	theDeltaV = simd_float4(4.0*thheDelta,4.0*thheDelta,4.0*thheDelta,4.0*thheDelta);
		x.withMemoryRebound(to: simd_float4.self, capacity: theXLen) { theX in
			var		p = simd_float4( 0.0, thheDelta, 2.0*thheDelta, 3.0*thheDelta );
			theX[0] = p;
			for t in 1..<theXLen {
				p = p+theDeltaV;
				theX[t] = p;
			}
		}
	}

	static private func accumlateScaledFloats(y: UnsafeMutablePointer<Float>, x: UnsafePointer<Float>, yc: Int, a: Float) {
		assert( yc%4 == 0, "The length of the arrays must be multiples of 4" );
		let theA = simd_float4(a, a, a, a)
		let	theYLen = yc>>2;
		y.withMemoryRebound(to: simd_float4.self, capacity: theYLen) { theY in
			x.withMemoryRebound(to: simd_float4.self, capacity: theYLen) { theX in
				for t in 0..<theYLen {
					theY[t] += theA * theX[t]
				}
			}
		}
	}
}

