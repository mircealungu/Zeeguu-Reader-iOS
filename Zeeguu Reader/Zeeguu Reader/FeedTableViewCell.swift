//
//  FeedTableViewCell.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 19-01-16.
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

class FeedTableViewCell: UITableViewCell {

	private var titleField: UILabel
	private var descriptionField: UILabel
	private var feedImageView: UIImageView
	
	var title: String? {
		get {
			return titleField.text
		}
		set {
			titleField.text = newValue
		}
	}
	
	var feedDescription: String? {
		get {
			return descriptionField.text
		}
		set {
			descriptionField.text = newValue
		}
	}
	
	var feedImage: UIImage? {
		get {
			return feedImageView.image
		}
		set {
			feedImageView.image = newValue
		}
	}
	
	init(reuseIdentifier: String?) {
		titleField = UILabel.autoLayoutCapapble()
		descriptionField = UILabel.autoLayoutCapapble()
		feedImageView = UIImageView.autoLayoutCapapble()
		super.init(style: .Default, reuseIdentifier: reuseIdentifier)
		setupLayout()
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	private func setupLayout() {
		titleField.font = UIFont.boldSystemFontOfSize(12)
		titleField.numberOfLines = 2
		
		titleField.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
		titleField.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Vertical)
		descriptionField.font = UIFont.systemFontOfSize(10)
		descriptionField.textColor = UIColor.lightGrayColor() 
		descriptionField.numberOfLines = 0
		feedImageView.contentMode = .ScaleAspectFit
		
		self.contentView.addSubview(titleField)
		self.contentView.addSubview(descriptionField)
		self.contentView.addSubview(feedImageView)
		
		let views: [String: UIView] = ["t": titleField, "d": descriptionField, "i": feedImageView]
		
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[i(60)]-[t]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[i]-[d]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[i]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[t]-1-[d]-(>=0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.contentView.addConstraint(NSLayoutConstraint(item: feedImageView, attribute: .Height, relatedBy: .Equal, toItem: feedImageView, attribute: .Width, multiplier: 1, constant: 0))
	}
}
