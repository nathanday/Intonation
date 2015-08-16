/*
	Envelope.swift
	Equal Temperament
	
	Created by Nathan Day on 16/08/15.
	Copyright © 2015 Nathan Day. All rights reserved.
 */

import Foundation

struct Envelope {
	let		attack: Float32;
	var		hold: Float32;
	let		release: Float32;
	var		end = false;

	init( attack anAttack: Float32, hold aHold: Float32, release aRelease: Float32 ) {
		attack = anAttack;
		hold = aHold;
		release = aRelease;
	}

	init( attack anAttack: Float32, release aRelease: Float32 ) { self.init( attack: anAttack, hold: 1000000.0, release: aRelease ); }

	subscript( anX: Float32 ) -> Float32 {
		get {
			let		theX = max(anX,0.0);
			var		theResult : Float32 = 1.0;
			if theX < hold+attack {
				if anX < attack {
					theResult = theX/attack;
				}
				else {
					theResult = 1.0;
				}
			}
			else {
				theResult = 1.0-(theX-hold-attack)/release;
			}
			return theResult;
		}
	}
}
