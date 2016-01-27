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
import ZeeguuAPI

class ArticleViewController: UIViewController, ArticleViewDelegate {
	
	var article: Article?
	let refresher = UIRefreshControl()
	
	convenience init(article: Article) {
		self.init()
		self.article = article
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.view.backgroundColor = UIColor.whiteColor()
		if let art = article {
			let sv = UIScrollView.autoLayoutCapapble()
			let view = ArticleView(article: art, delegate: self)
			let views: [String: AnyObject] = ["sv": sv,"v":view, "top":self.topLayoutGuide]
			
			sv.addSubview(refresher)
			
			
			self.view.addSubview(sv)
			self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[sv]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
			self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[sv]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
			
			sv.addSubview(view)
			self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v(==sv)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
			self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
			
			refresher.beginRefreshing()
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidAppear(animated: Bool) {
		let mc = UIMenuController.sharedMenuController()
		
		let bookmarkItem = UIMenuItem(title: "TRANSLATE".localized, action: "translate:")
		
		mc.menuItems = [bookmarkItem]
	}
	
	override func viewDidDisappear(animated: Bool) {
		let mc = UIMenuController.sharedMenuController()
		
		mc.menuItems = nil
	}

	func articleContentsDidLoad() {
		let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
		dispatch_after(delayTime, dispatch_get_main_queue()) {
			CATransaction.begin()
			CATransaction.setCompletionBlock({ () -> Void in
				self.refresher.removeFromSuperview()
			})
			self.refresher.endRefreshing()
			CATransaction.commit()
		}
	}
}

