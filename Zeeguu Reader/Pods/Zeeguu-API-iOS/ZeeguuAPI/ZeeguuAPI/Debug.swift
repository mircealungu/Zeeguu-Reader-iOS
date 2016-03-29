//
//  Debug.swift
//  ZeeguuAPI
//
//  Created by Jorrit Oosterhof on 08-12-15.
//  Copyright © 2015 Jorrit Oosterhof.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

extension NSURLRequest {
	public func extendedDescription() -> String {
		
		var result = "<\(NSStringFromClass(self.dynamicType)): " + String(format: "%p", self)
		result += "; HTTPMethod=" + (HTTPMethod ?? "nil") + "; URL=\(URL); timeoutInterval=" + String(format: "%.1fs", timeoutInterval) + "> {"
		
		// Add header fields.
		if let headers = allHTTPHeaderFields {
			result += "\nallHTTPHeaderFields {"
			for (key, value) in headers {
				result += "\n\t\(key) : '\(value)'"
			}
			result += "\n}"
		}
		
		if let body = HTTPBody {
			result += "\nHTTPBody {\n " + ((NSString(data: body, encoding: NSASCIIStringEncoding) ?? "") as String) + "\n}"
		}
		
		return result + "\n}"
	}
	
	public override var debugDescription: String {
		return extendedDescription()
	}
	
	public override var description: String {
		return extendedDescription()
	}
}