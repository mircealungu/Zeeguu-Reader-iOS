//
//  ZGWebView.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 03-05-16.
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
import WebKit
import Zeeguu_API_iOS

class ZGWebView: WKWebView {
	
	init(webViewConfiguration: WKWebViewConfiguration? = nil) {
		if let wvc = webViewConfiguration {
			super.init(frame: CGRectZero, configuration: wvc)
		} else {
			super.init(frame: CGRectZero, configuration: WKWebViewConfiguration())
		}
		self.translatesAutoresizingMaskIntoConstraints = false
	}

	required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func executeJavaScriptAction(action: ZGJavaScriptAction, resultHandler: ((AnyObject?) -> Void)? = nil) {
		let js = action.getJavaScriptExpression()
		self.evaluateJavaScript(js, completionHandler: { (result, error) in
			resultHandler?(result)
			print("Executed JavaScript: \(js)")
			print("result: \(result)")
			print("error: \(error)")
		})
	}
	
}
