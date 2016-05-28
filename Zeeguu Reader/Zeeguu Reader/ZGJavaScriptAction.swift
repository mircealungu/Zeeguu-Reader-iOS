//
//  ZGJavaScriptAction.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 05-05-16.
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

/**
Holds a JavaScript action to be executed.
*/
enum ZGJavaScriptAction {
	/// No action
	case None
	/// The translate action.
	///
	/// Use the `ZGJavaScriptAction.getJavaScriptExpression` method to retrieve a JavaScript expression that will insert the translation behind the original word.
	///
	/// **Important**: Before using `ZGJavaScriptAction.getJavaScriptExpression`, use `ZGJavaScriptAction.setTranslation` to set a translation, to make sure the JavaScript expression can be created!
	case Translate(Dictionary<String, String>)
	/// The edit translation action.
	///
	/// Use the `ZGJavaScriptAction.getJavaScriptExpression` method to retrieve a JavaScript expression that will update the translation behind the original word.
	///
	/// **Important**: Before using `ZGJavaScriptAction.getJavaScriptExpression`, use `ZGJavaScriptAction.setTranslation` to set a new translation, to make sure the JavaScript expression can be created!
	case EditTranslation(Dictionary<String, String>)
	/// The change font size action. The value indicates the factor of change (1 = +10%, -1 = -10%, ...)
	case ChangeFontSize(Int)
	/// The change translate mode action. The value indicates the translation mode (true = immediately, false = ask)
	case ChangeTranslationMode(Bool)
	/// The enable/disable links action. The value indicates whether links should be disabled or not.
	case DisableLinks(Bool)
	/// The remove selection highlights action. This action will remove selections of word groups that were selected for translation.
	case RemoveSelectionHighlights()
	
	static func parseMessage(dict: Dictionary<String, String>) -> ZGJavaScriptAction {
		var dict = dict
		if let action = dict.removeValueForKey("action"), _ = dict["id"] {
			if action == "translate" {
				if let _ = dict["word"] {
					return .Translate(dict)
				}
			} else if action == "editTranslation" {
				if let _ = dict["oldTranslation"], _ = dict["originalWord"] {
					return .EditTranslation(dict)
				}
			}
		}
		return .None
	}
	
	mutating func setTranslation(newWord: String) {
		switch self {
		case var .Translate(dict):
			dict["translation"] = newWord
			self = .Translate(dict)
		case var .EditTranslation(dict):
			dict["newTranslation"] = newWord
			self = .EditTranslation(dict)
		default:
			break // do nothing
		}
	}
	
	mutating func setBookmarkID(id: String) {
		switch self {
		case var .Translate(dict):
			dict["bookmarkID"] = id
			self = .Translate(dict)
		default:
			break // do nothing
		}
	}
	
	func getActionInformation() -> Dictionary<String, String>? {
		switch self {
		case let .Translate(dict):
			return dict
		case let .EditTranslation(dict):
			return dict
		default:
			return nil
		}
	}
	
	func getJavaScriptExpression() -> String {
		switch self {
		case let .Translate(dict):
			if let word = dict["translation"], id = dict["id"], bid = dict["bookmarkID"] {
				var w = word.stringByReplacingOccurrencesOfString("\\", withString: "\\\\")
				w = word.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
				return "insertTranslationForID(\"\(w)\", \"\(id)\", \"\(bid)\")"
			}
			fatalError("The ZGJavaScriptAction.Translate(_) dictionary is in an incorrect state!")
		case let .EditTranslation(dict):
			if let word = dict["newTranslation"], id = dict["id"] {
				var w = word.stringByReplacingOccurrencesOfString("\\", withString: "\\\\")
				w = word.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
				return "updateTranslationForID(\"\(w)\", \"\(id)\")"
			}
			fatalError("The ZGJavaScriptAction.EditTranslation(_) dictionary is in an incorrect state!")
		case let .ChangeFontSize(factor):
			return "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='\(100 + factor * 10)%'"
		case let .ChangeTranslationMode(immediately):
			return "zeeguuTranslatesImmediately = \(immediately ? "true" : "false");"
		case let .DisableLinks(disable):
			return "zeeguuLinksAreDisabled = \(disable ? "true" : "false"); zeeguuUpdateLinkState();"
		case .RemoveSelectionHighlights():
			return "removeSelectionHighlights();"
		default:
			return ""
		}
	}
}
