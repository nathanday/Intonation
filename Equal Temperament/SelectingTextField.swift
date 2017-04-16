//
//  SelectingTextField.swift
//  Intonation
//
//  Created by Nathaniel Day on 8/04/17.
//  Copyright © 2017 Nathan Day. All rights reserved.
//

import Cocoa

class SelectingTextField: NSTextField {

    override func mouseDown(with anEvent: NSEvent) {
        super.mouseDown(with:anEvent);
        selectText(nil);
    }
}
