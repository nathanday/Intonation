//
//  ButterworthFilter.swift
//  Intonation
//
//  Created by Nathaniel Day on 31/12/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import Foundation

struct ButterworthFilter {

	let		coefficient: (Float,Float,Float,Float,Float,Float);
	var		xv : (Float,Float,Float,Float,Float,Float,Float) = (0.0,0.0,0.0,0.0,0.0,0.0,0.0);
	var		yv : (Float,Float,Float,Float,Float,Float,Float) = (0.0,0.0,0.0,0.0,0.0,0.0,0.0);

	init( ) {
		self.init(coefficients:(-0.9976320693 ,5.9881575406 ,-14.9763094670 ,19.9763038520 ,-14.9881491170 ,5.9976292614));
	}

	init( coefficients aCoefficients: (Float,Float,Float,Float,Float,Float) ) {
		coefficient = aCoefficients;
	}

	mutating func butterworthFilter( _ anInput: Float) -> Float {
		xv.0 = xv.1;
		xv.1 = xv.2;
		xv.2 = xv.3;
		xv.3 = xv.4;
		xv.4 = xv.5;
		xv.5 = xv.6;
		xv.6 = anInput;
		yv.0 = yv.1;
		yv.1 = yv.2;
		yv.2 = yv.3;
		yv.3 = yv.4;
		yv.4 = yv.5;
		yv.5 = yv.6;
		yv.6 = (xv.0 + xv.6) + 6 * (xv.1 + xv.5) + 15 * (xv.2 + xv.4) + 20 * xv.3
				+ (coefficient.0 * yv.0) + (coefficient.1 * yv.1) + (coefficient.2 * yv.2)
				+ (coefficient.3 * yv.3) + (coefficient.4 * yv.4) + (coefficient.5 * yv.5);
		return yv.6;
	}

}
