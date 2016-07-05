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
	/// The delete translation action. The value is the JavaScript element id of the HTML element that displays the translation.
	case DeleteTranslation(String)
	/// The change font size action. The value indicates the factor of change (1 = +10%, -1 = -10%, ...)
	case ChangeFontSize(Int)
	/// The change translate mode action. The value indicates the translation mode.
	case ChangeTranslationMode(ArticleViewTranslationMode)
	/// The enable/disable links action. The value indicates whether links should be disabled or not.
	case DisableLinks(Bool)
	/// The remove selection highlights action. This action will remove selections of word groups that were selected for translation.
	case RemoveSelectionHighlights
	/// The selection incomplete action. If this action was parsed, it means a selection between two words is incomplete and that the user tapped a second word outside the paragraph of the first word. This is not supported yet.
	case SelectionIncomplete
	/// The pronounce action. If this action was parsed, the given word is pronounced by iOS. The string is the word/phrase to pronounce.
	case Pronounce(Dictionary<String, String>)
	/// The set inserts translation action. Sets whether the translation will be inserted or not. If the translation is not inserted, it is possible to translate a word multiple times.
	case SetInsertsTranslation(Bool)
	/// The insert loading icon action. The string contains the id of the element after which to put the loading icon.
	case InsertLoadingIcon(String)
	/// Send a post request with a URL, Method and POST parameters. Use this if you want to load a POST request with parameters using WKWebview. WKWebView ignores the HTTPBody of an NSURLRequest by default.
	case SendPOSTRequest(String, String, String)
	/// Get the page as an HTML string
	case GetPageHTML
	/// Get the page text as a string
	case GetPageText
	
	static func parseMessage(dict: Dictionary<String, String>) -> ZGJavaScriptAction {
		var dict = dict
		guard let action = dict.removeValueForKey("action")  else {
			return .None
		}
		if action == "translate" {
			if let _ = dict["word"] {
				return .Translate(dict)
			}
		} else if action == "editTranslation" {
			if let _ = dict["oldTranslation"], _ = dict["originalWord"] {
				return .EditTranslation(dict)
			}
		} else if action == "selectionIncomplete" {
			return .SelectionIncomplete
		} else if action == "pronounce" {
			if let _ = dict["word"] {
				return .Pronounce(dict)
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
	
	mutating func setOtherTranslations(ot: String) {
		switch self {
		case var .EditTranslation(dict):
			dict["otherTranslations"] = ot
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
	
	mutating func setPronounceID(id: String) {
		switch self {
		case var .Translate(dict):
			dict["pronounceID"] = id
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
		case let .Pronounce(dict):
			return dict
		default:
			return nil
		}
	}
	
	func getJavaScriptExpression() -> String {
		switch self {
		case let .Translate(dict):
			guard let translation = dict["translation"], word = dict["word"], context = dict["context"], id = dict["id"], bid = dict["bookmarkID"], pid = dict["pronounceID"] else {
				fatalError("The ZGJavaScriptAction.Translate(_) dictionary is in an incorrect state!")
			}
			let t = translation.stringByJSEscaping()
			let c = context.stringByJSEscaping()
			let w = word.stringByJSEscaping()
			
			return "insertTranslationForID(\"\(t)\", \"\(w)\", \"\(c)\", \"\(id)\", \"\(bid)\", \"\(pid)\")"
		case let .EditTranslation(dict):
			guard let word = dict["newTranslation"], id = dict["id"] else {
				fatalError("The ZGJavaScriptAction.EditTranslation(_) dictionary is in an incorrect state!")
			}
			let w = word.stringByJSEscaping()
			if let ot = dict["otherTranslations"] {
				let str = ot.stringByJSEscaping()
				
				return "updateTranslationForID(\"\(w)\", \"\(id)\", \"\(str)\")"
			} else {
				return "updateTranslationForID(\"\(w)\", \"\(id)\", null)"
			}
		case let .DeleteTranslation(id):
			return "deleteTranslationWithID(\"\(id)\")"
		case let .ChangeFontSize(factor):
			return "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='\(100 + factor * 10)%'"
		case let .ChangeTranslationMode(mode):
			return "setTranslationMode(\(mode.rawValue));"
		case let .DisableLinks(disable):
			return "zeeguuLinksAreDisabled = \(disable ? "true" : "false"); zeeguuUpdateLinkState();"
		case .RemoveSelectionHighlights():
			return "removeSelectionHighlights();"
		case let .SetInsertsTranslation(inserts):
			return "setInsertsTranslation(\(inserts ? "true" : "false"));"
		case let .InsertLoadingIcon(id):
			return "insertIconAfterID(\"\(id)\");"
		case let .SendPOSTRequest(url, method, params):
			
			var json = "{ "
			let pairs = params.characters.split(",").map(String.init)
			for pair in pairs {
				let kv = pair.characters.split("=").map(String.init)
				let key = kv[0]
				let value = kv[1]
				json += "\"\(key)\": \"\(value)\","
			}
			json = String(json.characters.dropLast()) + "}"
			
			return ["function post(path, params, method) {\n",
					"    method = method || \"post\"; // Set method to post by default if not specified.\n",
			        "    \n",
			        "    // The rest of this code assumes you are not using a library.\n",
			        "    // It can be made less wordy if you use one.\n",
			        "    var form = document.createElement(\"form\");\n",
			        "    form.setAttribute(\"method\", method);\n",
			        "    form.setAttribute(\"action\", path);\n",
			        "    \n",
			        "    for(var key in params) {\n",
			        "        if(params.hasOwnProperty(key)) {\n",
			        "            var hiddenField = document.createElement(\"input\");\n",
			        "            hiddenField.setAttribute(\"type\", \"hidden\");\n",
			        "            hiddenField.setAttribute(\"name\", key);\n",
			        "            hiddenField.setAttribute(\"value\", params[key]);\n",
			        "            \n",
			        "            form.appendChild(hiddenField);\n",
			        "        }\n",
			        "    }\n",
			        "    \n",
			        "    document.body.appendChild(form);\n",
			        "    form.submit();\n",
			        "}\n",
					"post(\"\(url)\", \(json), \"\(method)\");"].reduce("", combine: +)
		case .GetPageHTML:
			return "document.documentElement.outerHTML.toString()"
		case .GetPageText:
			return "document.documentElement.outerText.toString()"
		default:
			return ""
		}
	}
}
