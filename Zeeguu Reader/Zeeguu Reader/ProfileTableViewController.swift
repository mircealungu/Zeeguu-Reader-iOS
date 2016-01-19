//
//  ProfileTableViewController.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 03-01-16.
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

class ProfileTableViewController: ZGTableViewController, LanguagesTableViewControllerDelegate {
	
	var data = [[(String, String)]]()
	
	convenience init() {
		self.init(style: .Grouped)
		
		self.tabBarItem = UITabBarItem(title: nil, image: AppIcon.profileIcon(), selectedImage: AppIcon.profileIcon(true))
		self.title = "PROFILE".localized
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tableView.estimatedRowHeight = 80
		
		let logoutButton = UIBarButtonItem(title: "LOGOUT".localized, style: .Done, target: self, action: "logout:")
		self.navigationItem.leftBarButtonItem = logoutButton
		
		self.clearsSelectionOnViewWillAppear = true
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: "getUserData", forControlEvents: .ValueChanged)
		self.refreshControl?.beginRefreshing()
		getUserData()
	}
	
	func getUserData() {
		self.data = [[(String, String)]]()
		ZeeguuAPI.sharedAPI().getUserDetails { (dict) -> Void in
			if let d = dict {
				self.data.append([(String, String)]())
				self.data.append([(String, String)]())
				
				self.data[0].append(("NAME".localized, d["name"].stringValue))
				self.data[0].append(("EMAIL".localized, d["email"].stringValue))
				
				self.data[1].append(("LEARN_LANGUAGE".localized, d["learned_language"].stringValue))
				self.data[1].append(("BASE_LANGUAGE".localized, d["native_language"].stringValue))
			}
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				CATransaction.begin()
				CATransaction.setCompletionBlock({ () -> Void in
					self.tableView.reloadData()
				})
				self.refreshControl?.endRefreshing()
				CATransaction.commit()
			})
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Table View
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return data.count
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return data[section].count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let queueCell = tableView.dequeueReusableCellWithIdentifier("Cell")
		var cell: UITableViewCell
		if let c = queueCell {
			cell = c
		} else {
			cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
		}
		
		let d = self.data[indexPath.section][indexPath.row]
		cell.textLabel?.text = d.0
		if indexPath.section == 0 {
			cell.detailTextLabel?.text = d.1
		} else if indexPath.section == 1 {
			cell.detailTextLabel?.text = LanguagesTableViewController.getNameForLanguageCode(d.1)
		}
		
		if (indexPath.section == 1) {
			cell.accessoryType = .DisclosureIndicator
		}
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.section == 1 {
			if indexPath.row == 0 {
				let vc = LanguagesTableViewController(chooseType: .LearnLanguage, preselectedLanguage: self.data[indexPath.section][indexPath.row].1, delegate: self)
				self.navigationController?.pushViewController(vc, animated: true)
			} else if indexPath.row == 1 {
				let vc = LanguagesTableViewController(chooseType: .BaseLanguage, preselectedLanguage: self.data[indexPath.section][indexPath.row].1, delegate: self)
				self.navigationController?.pushViewController(vc, animated: true)
			}
		}
	}
	
	func didChooseLanguage(language: String, languageType: LanguageChooseType) {
		print("self.data: \(self.data)")
		ZeeguuAPI.sharedAPI().enableDebugOutput = true
		switch (languageType) {
		case .BaseLanguage:
			self.data[1][1].1 = language
			ZeeguuAPI.sharedAPI().setNativeLanguage(language, completion: { (success) -> Void in
				print("success: \(success)")
			})
			self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 1)], withRowAnimation: .Automatic)
			break
		case .LearnLanguage:
			self.data[1][0].1 = language
			ZeeguuAPI.sharedAPI().setLearnedLanguage(language, completion: { (success) -> Void in
				print("success: \(success)")
			})
			self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: .Automatic)
			break
		}
		ZeeguuAPI.sharedAPI().enableDebugOutput = false
		print("self.data: \(self.data)")
	}
	
	
}
