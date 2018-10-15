//
//  PianoKeyboardPopoverViewController.swift
//  Intonation
//
//  Created by Nathaniel Day on 26/08/18.
//  Copyright © 2018 Nathan Day. All rights reserved.
//

import Cocoa

class PianoKeyboardPopoverViewController: NSViewController, NSPopoverDelegate {

	@IBOutlet var	pianoKeyboardControl: PianoKeyboardControl!;
	var				popover: NSPopover?
	var				frequency: Double?;
	private var		completionHandler: ((Double?) -> Void)?;

	required init(  ) {
		super.init( nibName : "PianoKeyboardPopoverViewController", bundle: nil);
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		if let theFreq = frequency {
			pianoKeyboardControl.selection = [PianoKeyboardControl.midiNoteNumber(forFrequency:theFreq)];
		}
    }

	func show(withFrequency aFrequency: Double?, relativeTo aView: NSView, completionHandler aCompletion: @escaping (Double?) -> Void ) {
		frequency = aFrequency;
		let		thePopover = NSPopover();
		thePopover.contentViewController = self;
		thePopover.delegate = self;
		thePopover.behavior = .transient;
		thePopover.show(relativeTo: aView.bounds, of: aView, preferredEdge: .minX);
		popover = thePopover;
		completionHandler = aCompletion;
	}

	@IBAction func keySelectedAction( _ aSender: PianoKeyboardControl ) {
		if let thePopover = popover {
			frequency = aSender.selectedFrequency;
			thePopover.performClose(aSender);
		}
	}

	public func popoverShouldClose(_ popover: NSPopover) -> Bool {
		return true;
	}


	public func popoverShouldDetach(_ popover: NSPopover) -> Bool {
		return true;
	}


	public func popoverWillShow(_ notification: Notification) {
	}

	public func popoverDidShow(_ notification: Notification) {
	}

	public func popoverWillClose(_ notification: Notification) {
	}

	public func popoverDidClose(_ notification: Notification) {
		if let theCompletion = completionHandler {
			theCompletion(frequency);
		}
	}

}
