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
	func midiReceiverNoteOff( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt );
	func midiReceiverNoteOn( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt );
	func midiReceiverPolyphonicKeyPressure( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt );
	func midiReceiverControlChange( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt );
	func midiReceiverProgramChange( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt );
	func midiReceiverChannelPressure( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt );
	func midiReceiverPitchBendChange( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt );
}

extension MIDIReceiverObserver {
	func midiReceiverNoteOff( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt ) { }
	func midiReceiverNoteOn( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt ) { }
	func midiReceiverPolyphonicKeyPressure( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt ) { }
	func midiReceiverControlChange( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt ) { }
	func midiReceiverProgramChange( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt ) { }
	func midiReceiverChannelPressure( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt ) { }
	func midiReceiverPitchBendChange( aReceiver: MIDIReceiver, channel aChannel: UInt, note aNote: UInt, velocity aVelocity: UInt ) { }
}

class MIDIReceiver {
	var			midiClientRef = MIDIClientRef();
	var			inputPortRef : UInt32 = 0;
	var			clientName : String;
	var			observer: MIDIReceiverObserver?;

	init( clientName aClientName: String ) {
		clientName = aClientName;
		setUp();
	}

	func postEvent(bytes aBytes : [UInt] ) {
		let		theChannel = UInt(aBytes[0]&0xF);
		let		theNote = UInt(aBytes[1]&0x7F);
		let		theVelocity = UInt(aBytes[2]&0x7F);
		switch (aBytes[0]>>4)&7 {
		case 0: observer?.midiReceiverNoteOff( self, channel: theChannel, note: theNote, velocity: theVelocity );
		case 1: observer?.midiReceiverNoteOn( self, channel: theChannel, note: theNote, velocity: theVelocity );
		case 2: observer?.midiReceiverPolyphonicKeyPressure( self, channel: theChannel, note: theNote, velocity: theVelocity );
		case 3: observer?.midiReceiverControlChange( self, channel: theChannel, note: theNote, velocity: theVelocity );
		case 4: observer?.midiReceiverProgramChange( self, channel: theChannel, note: theNote, velocity: theVelocity );
		case 5: observer?.midiReceiverChannelPressure( self, channel: theChannel, note: theNote, velocity: theVelocity );
		case 6: observer?.midiReceiverPitchBendChange( self, channel: theChannel, note: theNote, velocity: theVelocity );
		default:
			break;
		}
	}

	func setUp() {
		var		theStatus = OSStatus(noErr);
		var		theEndPointRef: [UInt32] = [0]
		var		theEndPointName: [String] = [""]
		var		theSourcePointRef: [UInt32] = [0];

		func midiNotifyBlock(midiNotification: UnsafePointer<MIDINotification>) {
			setUp();
		}

		func midiInputBlock(packetList: UnsafePointer<MIDIPacketList>, srcConnRefCon: UnsafeMutablePointer<Void>)
		{
			let packets: MIDIPacketList = packetList.memory
			var packet: MIDIPacket = packets.packet
			for _ in 0..<packets.numPackets {
				let msgs = MIDIPacketDivider.messageFor(packet:packet);

				//			...
				if  msgs[0][0] == 0xF8 || msgs[0][0] == 0xFE { break }
				//			...Add upper code if control signals are noisy.

				for theMsg in msgs {
					postEvent( bytes: theMsg );
				}
				packet = MIDIPacketNext( &packet ).memory
			}
		}
		func convertCfTypeToString(cfValue: Unmanaged<CFString>!) -> String?{
			/* Coded by Vandad Nahavandipoor */
			let value = Unmanaged.fromOpaque(
				cfValue.toOpaque()).takeUnretainedValue() as CFStringRef
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
			theEndPointRef.removeAtIndex(0)
			theEndPointName.removeAtIndex(0)
		}
//		for i in 0..<theEndPointRef.count {
//			print("[\(i)] : \(theEndPointName[i]) (\(theEndPointRef[i]))")
//		}
//
		theStatus = MIDIClientCreateWithBlock(clientName, &midiClientRef, midiNotifyBlock);
		precondition( theStatus == OSStatus(noErr), "Status \(theStatus)" );
		theStatus = MIDIInputPortCreateWithBlock( midiClientRef, "\(clientName) port", &inputPortRef, midiInputBlock );
		precondition( theStatus == OSStatus(noErr), "Status \(theStatus)" );

		for i in 0..<theMidiNumberOfSources {
			theSourcePointRef.append(MIDIGetSource(i))
			if i == 0 {
				// avoid appending to empty array.
				theSourcePointRef.removeAtIndex(0)
			}

			theStatus = MIDIPortConnectSource(inputPortRef, theSourcePointRef[i], nil);
			precondition( theStatus == OSStatus(noErr), "Status \(theStatus)" );
		}
	}
}


struct MIDIPacketDivider {
	static func messageFor(packet aPacket: MIDIPacket) -> [[UInt]] {
		return mypacket2msgs(packet2mypacket(aPacket))
	}

	static func packet2mypacket(packet: MIDIPacket) -> [UInt] {
		var mypacket = [UInt]()
		switch packet.length {
		case 1: mypacket = [UInt(packet.data.0)]
		case 2: mypacket = [UInt(packet.data.0), UInt(packet.data.1)]
		case 3: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2)]
		case 4: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3)]
		case 5: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4)]
		case 6: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5)]
		case 7: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6)]
		case 8: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7)]
		case 9: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8)]
		case 10: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9)]
		case 11: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10)]
		case 12: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11)]
		case 13: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12)]
		case 14: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13)]
		case 15: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14)]
		case 16: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14), UInt(packet.data.15)]
		case 17: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14), UInt(packet.data.15), UInt(packet.data.16)]
		case 18: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14), UInt(packet.data.15), UInt(packet.data.16), UInt(packet.data.17)]
		case 19: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14), UInt(packet.data.15), UInt(packet.data.16), UInt(packet.data.17), UInt(packet.data.18)]
		case 20: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14), UInt(packet.data.15), UInt(packet.data.16), UInt(packet.data.17), UInt(packet.data.18), UInt(packet.data.19)]
		case 21: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14), UInt(packet.data.15), UInt(packet.data.16), UInt(packet.data.17), UInt(packet.data.18), UInt(packet.data.19), UInt(packet.data.20)]
		case 22: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14), UInt(packet.data.15), UInt(packet.data.16), UInt(packet.data.17), UInt(packet.data.18), UInt(packet.data.19), UInt(packet.data.20), UInt(packet.data.21)]
		case 23: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14), UInt(packet.data.15), UInt(packet.data.16), UInt(packet.data.17), UInt(packet.data.18), UInt(packet.data.19), UInt(packet.data.20), UInt(packet.data.21), UInt(packet.data.22)]
		case 24: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14), UInt(packet.data.15), UInt(packet.data.16), UInt(packet.data.17), UInt(packet.data.18), UInt(packet.data.19), UInt(packet.data.20), UInt(packet.data.21), UInt(packet.data.22), UInt(packet.data.23)]
		case 25: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14), UInt(packet.data.15), UInt(packet.data.16), UInt(packet.data.17), UInt(packet.data.18), UInt(packet.data.19), UInt(packet.data.20), UInt(packet.data.21), UInt(packet.data.22), UInt(packet.data.23), UInt(packet.data.24)]
		case 26: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14), UInt(packet.data.15), UInt(packet.data.16), UInt(packet.data.17), UInt(packet.data.18), UInt(packet.data.19), UInt(packet.data.20), UInt(packet.data.21), UInt(packet.data.22), UInt(packet.data.23), UInt(packet.data.24), UInt(packet.data.25)]
		case 27: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14), UInt(packet.data.15), UInt(packet.data.16), UInt(packet.data.17), UInt(packet.data.18), UInt(packet.data.19), UInt(packet.data.20), UInt(packet.data.21), UInt(packet.data.22), UInt(packet.data.23), UInt(packet.data.24), UInt(packet.data.25), UInt(packet.data.26)]
		case 28: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14), UInt(packet.data.15), UInt(packet.data.16), UInt(packet.data.17), UInt(packet.data.18), UInt(packet.data.19), UInt(packet.data.20), UInt(packet.data.21), UInt(packet.data.22), UInt(packet.data.23), UInt(packet.data.24), UInt(packet.data.25), UInt(packet.data.26), UInt(packet.data.27)]
		case 29: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14), UInt(packet.data.15), UInt(packet.data.16), UInt(packet.data.17), UInt(packet.data.18), UInt(packet.data.19), UInt(packet.data.20), UInt(packet.data.21), UInt(packet.data.22), UInt(packet.data.23), UInt(packet.data.24), UInt(packet.data.25), UInt(packet.data.26), UInt(packet.data.27), UInt(packet.data.28)]
		case 30: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14), UInt(packet.data.15), UInt(packet.data.16), UInt(packet.data.17), UInt(packet.data.18), UInt(packet.data.19), UInt(packet.data.20), UInt(packet.data.21), UInt(packet.data.22), UInt(packet.data.23), UInt(packet.data.24), UInt(packet.data.25), UInt(packet.data.26), UInt(packet.data.27), UInt(packet.data.28), UInt(packet.data.29)]
		case 31: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14), UInt(packet.data.15), UInt(packet.data.16), UInt(packet.data.17), UInt(packet.data.18), UInt(packet.data.19), UInt(packet.data.20), UInt(packet.data.21), UInt(packet.data.22), UInt(packet.data.23), UInt(packet.data.24), UInt(packet.data.25), UInt(packet.data.26), UInt(packet.data.27), UInt(packet.data.28), UInt(packet.data.29), UInt(packet.data.30)]
		case 32: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14), UInt(packet.data.15), UInt(packet.data.16), UInt(packet.data.17), UInt(packet.data.18), UInt(packet.data.19), UInt(packet.data.20), UInt(packet.data.21), UInt(packet.data.22), UInt(packet.data.23), UInt(packet.data.24), UInt(packet.data.25), UInt(packet.data.26), UInt(packet.data.27), UInt(packet.data.28), UInt(packet.data.29), UInt(packet.data.30), UInt(packet.data.31)]
		case 33: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14), UInt(packet.data.15), UInt(packet.data.16), UInt(packet.data.17), UInt(packet.data.18), UInt(packet.data.19), UInt(packet.data.20), UInt(packet.data.21), UInt(packet.data.22), UInt(packet.data.23), UInt(packet.data.24), UInt(packet.data.25), UInt(packet.data.26), UInt(packet.data.27), UInt(packet.data.28), UInt(packet.data.29), UInt(packet.data.30), UInt(packet.data.31), UInt(packet.data.32)]
		case 34: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14), UInt(packet.data.15), UInt(packet.data.16), UInt(packet.data.17), UInt(packet.data.18), UInt(packet.data.19), UInt(packet.data.20), UInt(packet.data.21), UInt(packet.data.22), UInt(packet.data.23), UInt(packet.data.24), UInt(packet.data.25), UInt(packet.data.26), UInt(packet.data.27), UInt(packet.data.28), UInt(packet.data.29), UInt(packet.data.30), UInt(packet.data.31), UInt(packet.data.32), UInt(packet.data.33)]
		case 35: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14), UInt(packet.data.15), UInt(packet.data.16), UInt(packet.data.17), UInt(packet.data.18), UInt(packet.data.19), UInt(packet.data.20), UInt(packet.data.21), UInt(packet.data.22), UInt(packet.data.23), UInt(packet.data.24), UInt(packet.data.25), UInt(packet.data.26), UInt(packet.data.27), UInt(packet.data.28), UInt(packet.data.29), UInt(packet.data.30), UInt(packet.data.31), UInt(packet.data.32), UInt(packet.data.33), UInt(packet.data.34)]
		case 36: mypacket = [UInt(packet.data.0), UInt(packet.data.1), UInt(packet.data.2), UInt(packet.data.3), UInt(packet.data.4), UInt(packet.data.5), UInt(packet.data.6), UInt(packet.data.7), UInt(packet.data.8), UInt(packet.data.9), UInt(packet.data.10), UInt(packet.data.11), UInt(packet.data.12), UInt(packet.data.13), UInt(packet.data.14), UInt(packet.data.15), UInt(packet.data.16), UInt(packet.data.17), UInt(packet.data.18), UInt(packet.data.19), UInt(packet.data.20), UInt(packet.data.21), UInt(packet.data.22), UInt(packet.data.23), UInt(packet.data.24), UInt(packet.data.25), UInt(packet.data.26), UInt(packet.data.27), UInt(packet.data.28), UInt(packet.data.29), UInt(packet.data.30), UInt(packet.data.31), UInt(packet.data.32), UInt(packet.data.33), UInt(packet.data.34), UInt(packet.data.35)]
		default: break // do nothing
		}

		return mypacket
	}

	static func mypacket2msgs( aPacket: [UInt]) -> [[UInt]] {

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

		msgs.removeAtIndex(0)

		return msgs
	}
}
