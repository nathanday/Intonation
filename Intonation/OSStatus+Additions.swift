//
//  OSStatus+Additions.swift
//  Intonation
//
//  Created by Nathaniel Day on 11/11/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import Foundation

extension OSStatus {

	var error: NSError? {
		guard self != errSecSuccess && self != noErr else {
			return nil;
		}

		var		theUserInfo : [String:String]? = nil;

		if let theMessage = SecCopyErrorMessageString(self, nil) as String? {
			theUserInfo = [NSLocalizedDescriptionKey: theMessage];
		}

		return NSError(domain: NSOSStatusErrorDomain, code: Int(self), userInfo:theUserInfo)
	}
}
