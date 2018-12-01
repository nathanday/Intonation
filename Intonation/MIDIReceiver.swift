//
//  MIDIReceiver.swift
//  Intonation
//
//  Created by Nathan Day on 6/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation
import CoreMIDI

protocol MIDIChannelVoiceMessagesObserver {
	func midiReceiver( _ aReceiver: MIDIReceiver, channel aChannel: UInt8, noteOff aNoteOff: UInt8, velocity aVelocity: UInt8 );			// Note Off event.
	func midiReceiver( _ aReceiver: MIDIReceiver, channel aChannel: UInt8, noteOn aNoteOn: UInt8, velocity aVelocity: UInt8 );				// Note On event.
	func midiReceiver( _ aReceiver: MIDIReceiver, channel aChannel: UInt8, note aNote: UInt8, polyphonicKeyPressure aPressure: UInt8 );		// Polyphonic Key Pressure.
	func midiReceiver( _ aReceiver: MIDIReceiver, channel aChannel: UInt8, controllerNumber aControllerNumber: UInt8, controllerValue aValue: UInt8 ); // Control Change.
	func midiReceiver( _ aReceiver: MIDIReceiver, channel aChannel: UInt8, progamChange aProgam: UInt8 );									// Program Change.
	func midiReceiver( _ aReceiver: MIDIReceiver, channel aChannel: UInt8, pressure aPressure: UInt8 );										// Channel Pressure.
	func midiReceiver( _ aReceiver: MIDIReceiver, channel aChannel: UInt8, pitchBendChange aPitchBendChange: UInt16 );						// Pitch Bend Change.
}

//protocol MIDISystemCommonMessagesObserver {
//	func midiReceiver( _ aReceiver: MIDIReceiver, manufacturerId anID: (UInt8,UInt8,UInt8), systemExclusiveData aData: [UInt8]] );	// System Exclusive.
//	func midiReceiver(_ aReceiver: MIDIReceiver, timeCodeQuarterType aType: UInt8, quarterFrame aValue: UInt8 );					// MIDI Time Code Quarter Frame.
//	func midiReceiver(_ aReceiver: MIDIReceiver, songPositionPointer aSongPositionPointer: UInt16 );								// Song Position Pointer.
//	func midiReceiver(_ aReceiver: MIDIReceiver, songSelect aSongSelect: UInt8 );													// Song Select.
//	func midiReceiverTuneRequest(_ aReceiver: MIDIReceiver );																		// Tune Request.
//	func midiReceiverEndOfExclusive(_ aReceiver: MIDIReceiver );																	// End of Exclusive.
//}

//protocol MIDISystemRealTimeMessagesObserver {
//	func midiReceiverTimingClock(_ aReceiver: MIDIReceiver );				// Timing Clock.
//	func midiReceiverStart(_ aReceiver: MIDIReceiver );						// Start.
//	func midiReceiverContinue(_ aReceiver: MIDIReceiver );					// Continue.
//	func midiReceiverStop(_ aReceiver: MIDIReceiver );						// Stop.
//	func midiReceiverActiveSensing(_ aReceiver: MIDIReceiver );				// Active Sensing.
//	func midiReceiverReset(_ aReceiver: MIDIReceiver );						// Reset.
//}

class MIDIReceiver {
	final private func sevenBits( _ aByte : UInt8 ) -> UInt8 {
		return aByte&0b0111_1111;
	}
	final private func fourteenBits( _ aByteL : UInt8, _ aByteH : UInt8 ) -> UInt16 {
		return UInt16(sevenBits(aByteL)) | UInt16((sevenBits(aByteH)) << 7);
	}

	var			midiClientRef = MIDIClientRef();
	var			inputPortRef : UInt32 = 0;
	var			clientName : String;
	var			channelVoiceMessagesObserver: MIDIChannelVoiceMessagesObserver?;

	init( clientName aClientName: String ) {
		clientName = aClientName;
		setUp();
	}

	func setUp() {
		var		theStatus = noErr;
		var		theEndPointRef: [UInt32] = [0]
		var		theEndPointName: [String] = [""]
		var		theSourcePointRef: [UInt32] = [0];

		func isStatusByte(_ aByte: UInt8) -> Bool {
			let statusByteMask = UInt8(0b10000000)
			return aByte & statusByteMask == statusByteMask
		}

		func midiNotifyBlock(_ midiNotification: UnsafePointer<MIDINotification>) {
			setUp();
		}

		func midiInputBlock(_ packetList: UnsafePointer<MIDIPacketList>, srcConnRefCon: UnsafeMutableRawPointer?) -> Swift.Void {
			let packets: MIDIPacketList = packetList.pointee
			var packet: MIDIPacket = packets.packet
			for _ in 0..<packets.numPackets {
				let		thePacketBytes = Mirror(reflecting: packet.data).children.map({$0.value}) as! [UInt8];
				var		thePacket = thePacketBytes.prefix(upTo:Int(packet.length));
				var		theIndex = 0;

				var currentMessage = [UInt8]();

				while theIndex < thePacket.count {
					currentMessage.append(thePacket[theIndex]);
					theIndex += 1
					// are we at the end of a message
					if theIndex == thePacket.count || isStatusByte(thePacket[theIndex]) {
						postEvent( bytes:currentMessage);
						currentMessage.removeAll();
					}
				}
				packet = MIDIPacketNext( &packet ).pointee
			}
		}

		func convertCfTypeToString(_ cfValue: Unmanaged<CFString>!) -> String? {
			/* Coded by Vandad Nahavandipoor */
			let value = Unmanaged.fromOpaque(
				cfValue.toOpaque()).takeUnretainedValue() as CFString
			if CFGetTypeID(value) == CFStringGetTypeID(){
				return value as String
			} else {
				return nil
			}
		}

//		let		theMidiNumberOfSources = MIDIGetNumberOfDevices() // devices registered on the system
		let		theMidiNumberOfSources = MIDIGetNumberOfSources() // now online devices

		for i in 0..<theMidiNumberOfSources {
			let thePointRef = MIDIGetSource(i)
			var theName: Unmanaged<CFString>?

			theStatus = MIDIObjectGetStringProperty(thePointRef, kMIDIPropertyDisplayName, &theName)
			if theStatus == noErr {
				theEndPointRef.append(thePointRef)
				theEndPointName.append(convertCfTypeToString(theName)!)
				theName?.release()
			}
		}
		if theEndPointRef.count > 0 {
			theEndPointRef.remove(at: 0)
			theEndPointName.remove(at: 0)
		}

		theStatus = MIDIClientCreateWithBlock(clientName as CFString, &midiClientRef, midiNotifyBlock);
		assert( theStatus == noErr, "Status \(theStatus) \(String(describing:theStatus.error))" );
		theStatus = MIDIInputPortCreateWithBlock( midiClientRef, "\(clientName) port" as CFString, &inputPortRef, midiInputBlock );
		assert( theStatus == noErr, "Status \(theStatus) \(String(describing:theStatus.error))" );

		for i in 0..<theMidiNumberOfSources {
			theSourcePointRef.append(MIDIGetSource(i))
			if i == 0 {
				// avoid appending to empty array.
				theSourcePointRef.remove(at: 0)
			}

			theStatus = MIDIPortConnectSource(inputPortRef, theSourcePointRef[i], nil);
			assert( theStatus == noErr, "Status \(theStatus) \(String(describing:theStatus.error))" );
		}
	}

	func postEvent(bytes aBytes : [UInt8] ) {
		switch aBytes[0] {
		case 0b1000_0000..<0b1111_0000:
			let		theEvent = aBytes[0]>>4;
			let		theChannel = aBytes[0]&0xF;
			switch theEvent {
			case 0b1000: channelVoiceMessagesObserver?.midiReceiver( self, channel: theChannel, noteOff: sevenBits(aBytes[1]), velocity: sevenBits(aBytes[2]) );
			case 0b1001: channelVoiceMessagesObserver?.midiReceiver( self, channel: theChannel, noteOn: sevenBits(aBytes[1]), velocity: sevenBits(aBytes[2]) );
			case 0b1010: channelVoiceMessagesObserver?.midiReceiver( self, channel: theChannel, note: sevenBits(aBytes[1]), polyphonicKeyPressure: sevenBits(aBytes[2]) );
			case 0b1011: channelVoiceMessagesObserver?.midiReceiver( self, channel: theChannel, controllerNumber: sevenBits(aBytes[1]), controllerValue: sevenBits(aBytes[2]) );
			case 0b1100: channelVoiceMessagesObserver?.midiReceiver( self, channel: theChannel, progamChange: sevenBits(aBytes[1]) );
			case 0b1101: channelVoiceMessagesObserver?.midiReceiver( self, channel: theChannel, pressure: sevenBits(aBytes[1]) );
			case 0b1110: channelVoiceMessagesObserver?.midiReceiver( self, channel: theChannel, pitchBendChange: fourteenBits(aBytes[1], aBytes[2]));
			default: assert(false, "Not a event byte, (\(theEvent))" );
			}
		case 0b1111_0000..<0b1111_1000:			// System Common Messages
			//	case 0b1111_0000:		// System Exclusive.
			//	case 0b1111_0001:		// MIDI Time Code Quarter Frame.
			//	case 0b1111_0010:		// Song Position Pointer.
			//	case 0b1111_0011:		// Song Select.
			//	case 0b1111_0100:		// Undefined.
			//	case 0b1111_0101:		// Undefined.
			//	case 0b1111_0110:		// Tune Request.
			//	case 0b1111_0111:		// End of Exclusive.
			break;
		case 0b1111_1000..<0b1111_1111:			// System Real-Time Messages
			//		case 0b1111_1000:	// Timing Clock.
			//		case 0b1111_1001:	// Undefined.
			//		case 0b1111_1010:	// Start.
			//		case 0b1111_1011:	// Continue.
			//		case 0b1111_1100:	// Stop.
			//		case 0b1111_1101:	// Undefined.
			//		case 0b1111_1110:	// Active Sensing.
			//		case 0b1111_1111:	// Reset.
			break;
		default:
			assert(false, "Not a status byte, (\(aBytes[0]))" );
		}
	}
}
