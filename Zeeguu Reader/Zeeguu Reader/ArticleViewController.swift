//
//  ArticleViewController.swift
//  Zeeguu Reader
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
import AVFoundation
import WebKit
import Zeeguu_API_iOS

class ArticleViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler, UpdateTranslationViewControllerDelegate {
	
	var article: Article?
	
	private var _webview: ZGWebView?
	private(set) var webview: ZGWebView { // _webview will never be nil when the initializer is finished
		get {
			return _webview!
		}
		set {
			_webview = newValue
		}
	}
	
	private var _translationMode = ArticleViewTranslationMode.Instant
	var translationMode: ArticleViewTranslationMode {
		get {
			return _translationMode
		}
		set(mode) {
			_translationMode = mode
			let action = ZGJavaScriptAction.ChangeTranslationMode(_translationMode)
			webview.evaluateJavaScript(action.getJavaScriptExpression()) { (result, error) in
				print("result: \(result)")
				print("error: \(error)")
			}
		}
	}
	
	private var _disableLinks = false
	var disableLinks: Bool {
		get {
			return _disableLinks
		}
		set(disable) {
			_disableLinks = disable
			let action = ZGJavaScriptAction.DisableLinks(disable)
			webview.evaluateJavaScript(action.getJavaScriptExpression()) { (result, error) in
				print("result: \(result)")
				print("error: \(error)")
			}
		}
	}
	
	var pronounceTranslatedWord = true
	
	private var currentJavaScriptAction: ZGJavaScriptAction?
	
	init(article: Article? = nil) {
		self.article = article
		//		self._articleView = ArticleView(article: self.article)
		super.init(nibName: nil, bundle: nil)
		
		let controller = WKUserContentController()
		controller.addScriptMessageHandler(self, name: "zeeguu")
		
		Utils.addUserScriptToUserContentController(controller, jsFileName: "jquery-2.2.3.min")
		Utils.addUserScriptToUserContentController(controller, jsFileName: "ZeeguuVars")
		Utils.addUserScriptToUserContentController(controller, jsFileName: "ZeeguuHelperFunctions")
		Utils.addUserScriptToUserContentController(controller, jsFileName: "ZeeguuPageInteraction")
		Utils.addUserScriptToUserContentController(controller, jsFileName: "ZeeguuPagePreparation")
		Utils.addStyleSheetToUserContentController(controller, cssFileName: "zeeguu")
		
		let config = WKWebViewConfiguration()
		config.userContentController = controller
		self.webview = ZGWebView(article: self.article, webViewConfiguration: config)
		
		self.webview.navigationDelegate = self
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.view.backgroundColor = UIColor.whiteColor()
		let views: [String: AnyObject] = ["v": webview]
		
		self.view.addSubview(webview)
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		let optionsBut = UIBarButtonItem(title: "OPTIONS".localized, style: .Plain, target: self, action: #selector(ArticleViewController.showOptions(_:)))
		self.navigationItem.rightBarButtonItem = optionsBut
		
		if let str = article?.url, url = NSURL(string: "http://www.readability.com/m?url=\(str)") {
			webview.loadRequest(NSURLRequest(URL: url))
		}
		//		if let str = article?.url, url = NSURL(string: str) {
		//			webview.loadRequest(NSURLRequest(URL: url))
		//		}
		
		if article == nil {
			optionsBut.enabled = false;
		}
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ArticleViewController.didHideUIMenuController(_:)), name: UIMenuControllerDidHideMenuNotification, object: nil)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidAppear(animated: Bool) {
		let mc = UIMenuController.sharedMenuController()
		
		let bookmarkItem = UIMenuItem(title: "TRANSLATE".localized, action: #selector(ArticleViewController.translateSelection(_:)))
		
		mc.menuItems = [bookmarkItem]
	}
	
	override func viewDidDisappear(animated: Bool) {
		let mc = UIMenuController.sharedMenuController()
		
		mc.menuItems = nil
	}
	
	func showOptions(sender: UIBarButtonItem) {
		let vc = ArticleViewOptionsTableViewController(parent: self)
		vc.popoverPresentationController?.barButtonItem = sender
		self.presentViewController(vc, animated: true, completion: nil)
	}
	
	func showUpdateTranslation(sender: ZGJavaScriptAction) {
		let dict = sender.getActionInformation();
		guard let r = dict, old = r["oldTranslation"], rx = r["left"], ry = r["top"], rw = r["width"], rh = r["height"], x = Float(rx), y = Float(ry), w = Float(rw), h = Float(rh) else {
			return
		}
		let vc = UpdateTranslationViewController(oldTranslation: old, action: sender)
		
		vc.delegate = self;
		
		let topGuide = self.topLayoutGuide
		vc.popoverPresentationController?.sourceRect = CGRectMake(CGFloat(x), CGFloat(y) + topGuide.length, CGFloat(w), CGFloat(h))
		vc.popoverPresentationController?.sourceView = webview
		
		currentJavaScriptAction = sender
		self.presentViewController(vc, animated: true, completion: nil)
	}
	
	func updateTranslationViewControllerDidChangeTranslationTo(translation: String, otherTranslations: [String : String]?) {
		var otherTranslations = otherTranslations
		print("new translation: \(translation)")
		guard var act = currentJavaScriptAction, d = act.getActionInformation(), let bid = d["bookmarkID"], let old = d["oldTranslation"] else {
			return
		}
		if var ot = otherTranslations {
			var add = true
			for (_, value) in ot {
				if value == translation {
					add = false
				}
			}
			if add {
				ot[translation] = translation
				otherTranslations = ot
			}
		}
		
		if let ot = otherTranslations, jsonData = try? NSJSONSerialization.dataWithJSONObject(ot, options: NSJSONWritingOptions(rawValue: 0)), str = String(data: jsonData, encoding: NSUTF8StringEncoding) {
			act.setOtherTranslations(str)
		}
		
		ZeeguuAPI.sharedAPI().addNewTranslationToBookmarkWithID(bid, translation: translation, completion: { (success) in
			if (success) {
				ZeeguuAPI.sharedAPI().deleteTranslationFromBookmarkWithID(bid, translation: old, completion: { (success) in})
			}
		})
		
		
		act.setTranslation(translation)
		self.webview.evaluateJavaScript(act.getJavaScriptExpression(), completionHandler: { (result, error) in
			print("result: \(result)")
			print("error: \(error)")
		})
		currentJavaScriptAction = nil
	}
	
	override func canBecomeFirstResponder() -> Bool {
		return true
	}
	
	func translateSelection(sender: AnyObject?) {
		if let action = currentJavaScriptAction {
			translateWithAction(action)
			currentJavaScriptAction = nil
		}
		self.webview.userInteractionEnabled = true
	}
	
	func translate(action: ZGJavaScriptAction) {
		if translationMode != .Instant {
			let mc = UIMenuController.sharedMenuController()
			let dict = action.getActionInformation();
			
			if let r = dict, rx = r["left"], ry = r["top"], rw = r["width"], rh = r["height"], x = Float(rx), y = Float(ry), w = Float(rw), h = Float(rh) {
				let topGuide = self.topLayoutGuide
				let rect = CGRectMake(CGFloat(x), CGFloat(y) + topGuide.length, CGFloat(w), CGFloat(h))
				
				currentJavaScriptAction = action
				
				self.webview.userInteractionEnabled = false
				
				self.becomeFirstResponder()
				mc.setTargetRect(rect, inView: webview)
				mc.setMenuVisible(true, animated: true)
			}
			return
		}
		translateWithAction(action)
	}
	
	func translateWithAction(action: ZGJavaScriptAction) {
		var action = action
		guard let word = action.getActionInformation()?["word"], context = action.getActionInformation()?["context"], art = article else {
			return
		}
		ZeeguuAPI.sharedAPI().translateWord(word, title: art.title, context: context, url: art.url /* TODO: Or maybe webview url? */, completion: { (translation) in
			print("translation: \(translation)")
			guard let t = translation?["translation"].string, b = translation?["bookmark_id"].string else {
				return
			}
			print("\"\(word)\" translated to \"\(t)\"")
			action.setTranslation(t)
			action.setBookmarkID(b)
			
			if (self.pronounceTranslatedWord) {
				let synthesizer = AVSpeechSynthesizer()
				
				let utterance = AVSpeechUtterance(string: word)
				utterance.voice = AVSpeechSynthesisVoice(language: self.article?.feed.language)
				
				synthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
				synthesizer.speakUtterance(utterance)
			}
			
			self.webview.evaluateJavaScript(action.getJavaScriptExpression(), completionHandler: { (result, error) in
				print("result: \(result)")
				print("error: \(error)")
			})
		})
	}
	
	func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
		print("Received message: \(message.body)")
		guard let body = message.body as? Dictionary<String, AnyObject> else {
			return
		}
		var dict = Dictionary<String, String>()
		
		for (key, var value) in body {
			if let val = value as? NSObject where val == NSNull() {
				value = ""
			}
			dict[key] = String(value)
		}
		
		
		let action = ZGJavaScriptAction.parseMessage(dict)
		
		switch action {
		case .Translate(_):
			self.translate(action)
			break
		case .EditTranslation(_):
			self.showUpdateTranslation(action)
			break
		default:
			break
		}
	}
	
	func didHideUIMenuController(sender: NSNotification) {
		self.webview.evaluateJavaScript(ZGJavaScriptAction.RemoveSelectionHighlights().getJavaScriptExpression(), completionHandler: { (result, error) in
			print("result: \(result)")
			print("error: \(error)")
		})
		self.webview.userInteractionEnabled = true
	}
	
}

