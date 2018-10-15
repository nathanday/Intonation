/*
	UnsignedInteger_Arithmetic.swift
	Created by Nathan Day on 06.07.18 under a MIT-style license.
	Copyright (c) 2018 Nathaniel Day
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
*/

import Foundation

func greatestCommonDivisor<T : UnsignedInteger>(_ u: T, _ v: T) -> T {
	// simple cases (termination)
	guard u != v else { return u; }
	guard u != 0 else { return v; }
	guard v != 0 else { return u; }

	// look for factors of 2
	if (u & 0b1) == 0 {  // u is even
		return (v & 0b1) != 0
			? greatestCommonDivisor(u / 2, v)	// v is odd
			: greatestCommonDivisor(u / 2, v / 2) * 2; // both u and v are even
	}

	if (v & 0b1) == 0 { // u is odd, v is even
		return greatestCommonDivisor(u, v / 2);
	}

	// reduce larger argument
	return u > v
		? greatestCommonDivisor((u - v) / 2, v)
		: greatestCommonDivisor((v - u) / 2, u);
}
