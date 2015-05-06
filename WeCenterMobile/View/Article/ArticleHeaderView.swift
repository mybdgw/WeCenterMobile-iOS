//
//  ArticleHeaderView.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/5/2.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

@objc protocol ArticleHeaderViewDelegate {
    optional func articleHeaderViewMaxHeightDidChange(header: ArticleHeaderView)
}

class ArticleHeaderView: UIView {
    
    var delegate: ArticleHeaderViewDelegate?
    
    lazy var backButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(named: "Arrow-Left")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        v.tintColor = UIColor.whiteColor()
        return v
    }()
    
    lazy var titleLabelA: UILabel = {
        let v = UILabel()
        v.textAlignment = .Center
        v.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.87)
        v.font = UIFont.systemFontOfSize(17)
        return v
    }()
    
    lazy var titleLabelB: UILabel = {
        let v = UILabel()
        v.numberOfLines = 0
        v.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.87)
        v.font = UIFont.systemFontOfSize(17)
        return v
    }()
    
    lazy var userAvatarViewA: MSRRoundedImageView = {
        let v = MSRRoundedImageView(image: defaultUserAvatar)
        return v
    }()
    
    lazy var userAvatarViewB: MSRRoundedImageView = {
        let v = MSRRoundedImageView(image: defaultUserAvatar)
        return v
    }()
    
    lazy var userNameLabel: UILabel = {
        let v = UILabel()
        v.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.87)
        v.font = UIFont.systemFontOfSize(15)
        return v
    }()
    
    lazy var userSignatureLabel: UILabel = {
        let v = UILabel()
        v.textColor = UIColor.lightTextColor()
        v.font = UIFont.systemFontOfSize(12)
        return v
    }()
    
    lazy var separator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        return v
    }()
    
    var backgroundView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if backgroundView != nil {
                addSubview(backgroundView!)
                sendSubviewToBack(backgroundView!)
                backgroundView!.frame = bounds
                backgroundView!.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            }
        }
    }
    
    override var frame: CGRect {
        didSet {
            if frame.width != oldValue.width {
                invalidateMaxHeight()
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        wc_initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        wc_initialize()
    }
    
    func wc_initialize() {
        clipsToBounds = true
        backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        for v in [backButton, titleLabelA, titleLabelB, userAvatarViewA, userAvatarViewB, userNameLabel, userSignatureLabel, separator] {
            addSubview(v)
        }
    }
    
    func update(#article: Article) {
        userAvatarViewA.wc_updateWithUser(article.user)
        userAvatarViewB.wc_updateWithUser(article.user)
        titleLabelA.text = article.title
        titleLabelB.text = article.title
        titleLabelA.sizeToFit()
        userNameLabel.text = article.user?.name ?? "匿名用户"
        userSignatureLabel.text = article.user?.signature
        invalidateMaxHeight()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let backButtonBeginFrame = CGRect(x: 10, y: 20, width: 30, height: normalHeight - minHeight)
        var backButtonEndFrame = CGRect(x: 10, y: 20, width: 30, height: maxHeight - 50 - 20)
        let userAvatarViewAFrame = CGRect(x: bounds.width - 40, y: backButtonBeginFrame.midY - 15, width: 30, height: 30)
        var userAvatarViewBFrame = CGRect(x: 10, y: backButtonEndFrame.maxY + 10, width: 30, height: 30)
        var titleLabelAFrame = CGRect(x: backButtonBeginFrame.maxX + 10, y: backButtonBeginFrame.midY - titleLabelA.bounds.height / 2, width: bounds.width - 100, height: titleLabelA.bounds.height)
        var titleLabelBFrame = CGRect(x: backButtonEndFrame.maxX + 10, y: backButtonEndFrame.minY, width: bounds.width - 60, height: backButtonEndFrame.height)
        var userNameLabelFrame = CGRect(x: userAvatarViewBFrame.maxX + 10, y: userAvatarViewBFrame.minY, width: bounds.width - 64, height: userAvatarViewBFrame.height / 2)
        var userSignatureLabelFrame = CGRect(x: userNameLabelFrame.minX, y: userNameLabelFrame.maxY, width: userNameLabelFrame.width, height: userAvatarViewBFrame.height / 2)
        var separatorFrame = CGRect(x: 0, y: backButtonEndFrame.maxY, width: bounds.width, height: 0.5)
        if bounds.height <= normalHeight {
            backButton.frame = backButtonBeginFrame
            backButton.alpha = 1
            userAvatarViewA.alpha = 1
            userAvatarViewB.alpha = 0
            titleLabelA.alpha = 1
            titleLabelB.alpha = 0
            userNameLabel.alpha = 0
            userSignatureLabel.alpha = 0
        } else if bounds.height <= maxHeight {
            let progress = (bounds.height - normalHeight) / (maxHeight - normalHeight)
            backButton.frame = MSRLinearInterpolation(backButtonBeginFrame, backButtonEndFrame, Double(progress))
            backButton.alpha = 1
            userAvatarViewA.alpha = CGFloat(max(0, progress * -2 + 1))
            userAvatarViewB.alpha = CGFloat(max(0, progress * 2 - 1))
            titleLabelA.alpha = CGFloat(max(0, progress * -2 + 1))
            titleLabelB.alpha = CGFloat(max(0, progress * 2 - 1))
            userNameLabel.alpha = CGFloat(max(0, progress * 2 - 1))
            userSignatureLabel.alpha = CGFloat(max(0, progress * 2 - 1))
        } else {
            let offset = bounds.height - maxHeight
            backButtonEndFrame.origin.y += offset
            userAvatarViewBFrame.origin.y += offset
            titleLabelAFrame.origin.y += offset
            titleLabelBFrame.origin.y += offset
            userNameLabelFrame.origin.y += offset
            userSignatureLabelFrame.origin.y += offset
            separatorFrame.origin.y += offset
            backButton.frame = backButtonEndFrame
            backButton.alpha = 1
            userAvatarViewA.alpha = 0
            userAvatarViewB.alpha = 1
            titleLabelA.alpha = 0
            titleLabelB.alpha = 1
            userNameLabel.alpha = 1
            userSignatureLabel.alpha = 1
        }
        titleLabelA.frame = titleLabelAFrame
        titleLabelB.frame = titleLabelBFrame
        userAvatarViewA.frame = userAvatarViewAFrame
        userAvatarViewB.frame = userAvatarViewBFrame
        userNameLabel.frame = userNameLabelFrame
        userSignatureLabel.frame = userSignatureLabelFrame
        separator.frame = separatorFrame
    }
    
    func invalidateMaxHeight() {
        _maxHeightIsInvalid = true
    }
    
    private var _maxHeight: CGFloat = 0 {
        didSet {
            if _maxHeight != oldValue {
                delegate?.articleHeaderViewMaxHeightDidChange?(self)
            }
        }
    }
    private var _maxHeightIsInvalid: Bool = true
    
    let minHeight: CGFloat = 20
    let normalHeight: CGFloat = 64
    var maxHeight: CGFloat {
        if _maxHeightIsInvalid {
            _maxHeightIsInvalid = false
            let titleHeight = titleLabelB.textRectForBounds(CGRect(origin: CGPointZero, size: CGSize(width: bounds.width - 60, height: CGFloat.max)), limitedToNumberOfLines: 0).height
            let oneLineHeight = titleLabelB.textRectForBounds(CGRectInfinite, limitedToNumberOfLines: 1).height
            _maxHeight = (titleHeight == oneLineHeight ? 44 : titleHeight + 22) + 20 + 50
        }
        return _maxHeight
    }
    
}
