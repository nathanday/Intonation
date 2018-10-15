//
//  MIDIReceiver.swift
//  Intonation
//
//  Created by Nathan Day on 6/03/16.
//  Copyright © 2016 Nathan Day. All rights reserved.
//

import Foundation
import CoreMIDI

protocol MIDIReceiverObserver {
	func midiReceiverNoteOff( _ aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt );
	func midiReceiverNoteOn( _ aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt );
	func midiReceiverPolyphonicKeyPressure( _ aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, pressure aPressure: UInt );
	func midiReceiverControlChange( _ aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt );
	func midiReceiverProgramChange( _ aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt );
	func midiReceiverChannelPressure( _ aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt );
	func midiReceiverPitchBendChange( _ aReceiver: MIDIReceiver, channel aChannel: UInt, value aValue: UInt );
}

extension MIDIReceiverObserver {
	func midiReceiverNoteOff( _ aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt ) { }
	func midiReceiverNoteOn( _ aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt ) { }
	func midiReceiverPolyphonicKeyPressure( _ aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, pressure aPressure: UInt ) { }
	func midiReceiverControlChange( _ aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt ) { }
	func midiReceiverProgramChange( _ aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt ) { }
	func midiReceiverChannelPressure( _ aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt ) { }
	func midiReceiverPitchBendChange( _ aReceiver: MIDIReceiver, channel aChannel: UInt, value aValue: UInt ) { }
}

class MIDIReceiver {
	final private func sevenBits( _ aByte : UInt ) -> UInt {
		return aByte&0x7F;
	}
	final private func fourteenBits( _ aByteL : UInt, _ aByteH : UInt ) -> UInt {
		return sevenBits(aByteL) | (sevenBits(aByteH) << 7);
	}

	var			midiClientRef = MIDIClientRef();
	var			inputPortRef : UInt32 = 0;
	var			clientName : String;
	var			observer: MIDIReceiverObserver?;

	init( clientName aClientName: String ) {
		clientName = aClientName;
		setUp();
	}

	func postEvent(bytes aBytes : [UInt] ) {
		let		theEvent = (aBytes[0]>>4)&7;
		let		theChannel = UInt(aBytes[0]&0xF);
		switch theEvent {
		case 0:
			observer?.midiReceiverNoteOff( self, channel: theChannel, note: sevenBits(aBytes[1]), velocity: sevenBits(aBytes[2]) );
		case 1:
			observer?.midiReceiverNoteOn( self, channel: theChannel, note: sevenBits(aBytes[1]), velocity: sevenBits(aBytes[2]) );
		case 2:
			observer?.midiReceiverPolyphonicKeyPressure( self, channel: theChannel, note: sevenBits(aBytes[1]), pressure: sevenBits(aBytes[2]) );
		case 3:
			observer?.midiReceiverControlChange( self, channel: theChannel, note: sevenBits(aBytes[1]), velocity: sevenBits(aBytes[2]) );
		case 4:
			observer?.midiReceiverProgramChange( self, channel: theChannel, note: sevenBits(aBytes[1]) );
		case 5:
			observer?.midiReceiverChannelPressure( self, channel: theChannel, note: sevenBits(aBytes[1]) );
		case 6:
			observer?.midiReceiverPitchBendChange( self, channel: theChannel, value: fourteenBits(aBytes[1], aBytes[2]) );
		default:
			break;
		}
	}

	func setUp() {
		var		theStatus = noErr;
		var		theEndPointRef: [UInt32] = [0]
		var		theEndPointName: [String] = [""]
		var		theSourcePointRef: [UInt32] = [0];

		func midiNotifyBlock(_ midiNotification: UnsafePointer<MIDINotification>) {
			setUp();
		}

		func midiInputBlock(_ packetList: UnsafePointer<MIDIPacketList>, srcConnRefCon: UnsafeMutableRawPointer?) -> Swift.Void
		{
			let packets: MIDIPacketList = packetList.pointee
			var packet: MIDIPacket = packets.packet
			for _ in 0..<packets.numPackets {
				let msgs = MIDIPacketDivider.messageFor(packet:packet);

				//			...
				if  msgs[0][0] == 0xF8 || msgs[0][0] == 0xFE { break }
				//			...Add upper code if control signals are noisy.

				for theMsg in msgs {
					postEvent( bytes: theMsg );
				}
				packet = MIDIPacketNext( &packet ).pointee
			}
		}
		func convertCfTypeToString(_ cfValue: Unmanaged<CFString>!) -> String?{
			/* Coded by Vandad Nahavandipoor */
			let value = Unmanaged.fromOpaque(
				cfValue.toOpaque()).takeUnretainedValue() as CFString
			if CFGetTypeID(value) == CFStringGetTypeID(){
				return value as String
			} else {
				return nil
			}
		}

//		let		theMidiNumberOfDevices = MIDIGetNumberOfDevices() // devices registered on the system
		let		theMidiNumberOfSources = MIDIGetNumberOfSources() // now online devices

		for i in 0..<theMidiNumberOfSources {
			let thePointRef = MIDIGetSource(i)
			var theName: Unmanaged<CFString>?

			theStatus = MIDIObjectGetStringProperty(thePointRef, kMIDIPropertyDisplayName, &theName)
			if theStatus == noErr {
				theEndPointRef.append(thePointRef)
				theEndPointName.append(convertCfTypeToString(theName)!)
				theName!.release()
			}
		}
		if theEndPointRef.count > 0 {
			theEndPointRef.remove(at: 0)
			theEndPointName.remove(at: 0)
		}
//		for (theIndex,theRef) in theEndPointRef.enumerate() {
//			print("[\(theIndex)] : \(theEndPointName[theIndex]) (\(theRef))")
//		}
//
		theStatus = MIDIClientCreateWithBlock(clientName as CFString, &midiClientRef, midiNotifyBlock);
		precondition( theStatus == noErr, "Status \(theStatus)" );
//		precondition( theStatus == noErr, "Status \(theStatus) \(GetMacOSStatusCommentString(theStatus)), \(GetMacOSStatusErrorString(theStatus))" );
		theStatus = MIDIInputPortCreateWithBlock( midiClientRef, "\(clientName) port" as CFString, &inputPortRef, midiInputBlock );
		precondition( theStatus == noErr, "Status \(theStatus)" );

		for i in 0..<theMidiNumberOfSources {
			theSourcePointRef.append(MIDIGetSource(i))
			if i == 0 {
				// avoid appending to empty array.
				theSourcePointRef.remove(at: 0)
			}

			theStatus = MIDIPortConnectSource(inputPortRef, theSourcePointRef[i], nil);
			precondition( theStatus == noErr, "Status \(theStatus)" );
		}
	}
}


struct MIDIPacketDivider {
	static func messageFor(packet aPacket: MIDIPacket) -> [[UInt]] {
		return mypacket2msgs(packet2mypacket(aPacket))
	}

	static func packet2mypacket(_ packet: MIDIPacket) -> [UInt] {
		var mypacket = [UInt]()
		switch packet.length {
		case 1: mypacket.append(UInt(packet.data.0)); fallthrough;
		case 2: mypacket.append(UInt(packet.data.1)); fallthrough;
		case 3: mypacket.append(UInt(packet.data.2)); fallthrough;
		case 4: mypacket.append(UInt(packet.data.3)); fallthrough;
		case 5: mypacket.append(UInt(packet.data.4)); fallthrough;
		case 6: mypacket.append(UInt(packet.data.5)); fallthrough;
		case 7: mypacket.append(UInt(packet.data.6)); fallthrough;
		case 8: mypacket.append(UInt(packet.data.7)); fallthrough;
		case 9: mypacket.append(UInt(packet.data.8)); fallthrough;
		case 10: mypacket.append(UInt(packet.data.9)); fallthrough;
		case 11: mypacket.append(UInt(packet.data.10)); fallthrough;
		case 12: mypacket.append(UInt(packet.data.11)); fallthrough;
		case 13: mypacket.append(UInt(packet.data.12)); fallthrough;
		case 14: mypacket.append(UInt(packet.data.13)); fallthrough;
		case 15: mypacket.append(UInt(packet.data.14)); fallthrough;
		case 16: mypacket.append(UInt(packet.data.15)); fallthrough;
		case 17: mypacket.append(UInt(packet.data.16)); fallthrough;
		case 18: mypacket.append(UInt(packet.data.17)); fallthrough;
		case 19: mypacket.append(UInt(packet.data.18)); fallthrough;
		case 20: mypacket.append(UInt(packet.data.19)); fallthrough;
		case 21: mypacket.append(UInt(packet.data.20)); fallthrough;
		case 22: mypacket.append(UInt(packet.data.21)); fallthrough;
		case 23: mypacket.append(UInt(packet.data.22)); fallthrough;
		case 24: mypacket.append(UInt(packet.data.23)); fallthrough;
		case 25: mypacket.append(UInt(packet.data.24)); fallthrough;
		case 26: mypacket.append(UInt(packet.data.25)); fallthrough;
		case 27: mypacket.append(UInt(packet.data.26)); fallthrough;
		case 28: mypacket.append(UInt(packet.data.27)); fallthrough;
		case 29: mypacket.append(UInt(packet.data.28)); fallthrough;
		case 30: mypacket.append(UInt(packet.data.29)); fallthrough;
		case 31: mypacket.append(UInt(packet.data.30)); fallthrough;
		case 32: mypacket.append(UInt(packet.data.31)); fallthrough;
		case 33: mypacket.append(UInt(packet.data.32)); fallthrough;
		case 34: mypacket.append(UInt(packet.data.33)); fallthrough;
		case 35: mypacket.append(UInt(packet.data.34)); fallthrough;
		case 36: mypacket.append(UInt(packet.data.35));
		default: break // do nothing
		}

		return mypacket
	}

	static func mypacket2msgs( _ aPacket: [UInt]) -> [[UInt]] {

		var		thePacket = aPacket
		var		theIndex = 0;

		thePacket.append(0xF4) // Sentinel
		thePacket.append(0xF4) // Sentinel
		thePacket.append(0xF4) // Sentinel

		var msgs : [[UInt]] = [[0]] // avoid appending to empty array.

		while theIndex < thePacket.count-3 {
			if thePacket[theIndex+1] >> 7 == 1 {
				msgs.append([thePacket[theIndex]])
				theIndex += 1
			} else if thePacket[theIndex+2] >> 7 == 1 {
				msgs.append([thePacket[theIndex], thePacket[theIndex+1]])
				theIndex += 2
				continue
			} else if thePacket[theIndex+3] >> 7 == 1 {
				msgs.append([thePacket[theIndex], thePacket[theIndex+1], thePacket[theIndex+2]])
				theIndex += 3
				continue
			} else {
				print("broken packet")
				theIndex += 1;
			}
		}

		msgs.remove(at: 0)

		return msgs
	}
}
