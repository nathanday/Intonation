/*
	Envelope.swift
	Equal Temperament
	
	Created by Nathan Day on 16/08/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Foundation

struct Envelope {
	let		attack: Float32;
	var		hold: Float32?;
	let		release: Float32;

	init( attack anAttack: Float32, hold aHold: Float32?, release aRelease: Float32 ) {
		attack = anAttack;
		hold = aHold;
		release = aRelease;
	}

	init( attack anAttack: Float32, release aRelease: Float32 ) { self.init( attack: anAttack, hold: nil, release: aRelease ); }

	subscript( anX: Float32 ) -> (Bool,Float32) {
		get {
			let		theX = max(anX,0.0);
			var		theResult : Float32 = 1.0;
			var		theComplete = false;
			let		theHold = hold ?? theX+1000.0;
			if theX < theHold+attack {
				if anX < attack {
					theResult = theX/attack;
				}
				else {
					theResult = 1.0;
				}
			}
			else if theX < theHold+attack+release {
				theResult = 1.0-(theX-theHold-attack)/release;
			}
			else {
				theComplete = true;
			}
			return (theComplete,theResult);
		}
	}
}
