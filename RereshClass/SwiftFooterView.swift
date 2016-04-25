//
//  SwiftFooterView.swift
//  SwiftRefresh
//
//  Created by Havi on 16/4/24.
//  Copyright © 2016年 Havi. All rights reserved.
//

import UIKit

public class SwiftFooterView:UIView {
    var scrollView = UIScrollView();
    var footLabel = UILabel();
    var loadMoreAction:(() -> Void)? = {}
    var loadMoreTempAction:(() -> Void)? = {};
    var loadMoreEndTempAction:(() -> Void)? = {};
    
    var isEndloadMore:Bool = false{
        willSet{
            self.footLabel.text = SwiftRefreshMessageText;
            self.isEndloadMore = newValue;
        }
    };
    
    var title:String{
        get {
            return footLabel.text!;
        }
        set {
            footLabel.text = newValue;
        }
    };
    
    convenience init(action:(()->Void),frame:CGRect){
        self.init(frame:frame);
        self.loadMoreAction = action;
    }
    
    //init meathod
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.backgroundColor = UIColor(red: 222.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 1.0);
        self.setUpUI();
    };
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    };
    
    func setUpUI() {
        let footerTitleLabel:UILabel = UILabel(frame: CGRectMake(0,0,self.frame.size.width,self.frame.size.height));
        footerTitleLabel.textAlignment = .Center;
        footerTitleLabel.text = SwiftRefreshFootViewText;
        self.addSubview(footerTitleLabel);
        self.footLabel = footerTitleLabel;
    }
    //添加kvo
    public override func willMoveToWindow(newWindow: UIWindow?) {
        refreshStatus = .Normal;
    }
    
    public override func willMoveToSuperview(newSuperview: UIView?) {
        //移除两个观察者
        superview?.removeObserver(self, forKeyPath: contentSizeKeyPath, context: &KVOContext);
        superview?.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &KVOContext);
        //
        refreshStatus = .Normal;
        if newSuperview != nil && (newSuperview?.isKindOfClass(UIScrollView))! {
            self.scrollView = newSuperview as! UIScrollView;
            // 如果UITableViewController情况下，contentInset.bottom 会加20
            var offset:CGFloat = 0;
            if self.getViewControllerWithView(self.scrollView).isKindOfClass(UITableViewController) {
                offset = self.frame.height * 0.5 - 20;
            }else {
                offset = self.frame.height * 0.5;
            }
            self.scrollView.contentInset = UIEdgeInsetsMake(self.scrollView.contentInset.top, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom + self.frame.height + offset + self.scrollView.frame.origin.y, self.scrollView.contentInset.right);
            newSuperview?.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .Initial, context: &KVOContext);
            newSuperview?.addObserver(self, forKeyPath: contentSizeKeyPath, options: .Initial, context: &KVOContext);
        }
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if self.loadMoreAction == nil {
            return;
        }
        
        let scrollView = self.scrollView;
        if keyPath == contentSizeKeyPath {
            if scrollView.isKindOfClass(UICollectionView) {
                let collectionView:UICollectionView = scrollView as! UICollectionView;
                let height:CGFloat = collectionView.collectionViewLayout.collectionViewContentSize().height;
                self.frame.origin.y = height;
            }else{
                if (self.scrollView.contentSize.height == 0){
                    self.frame.origin.y = 0;
                }else if(scrollView.contentSize.height < self.frame.size.height){
                    self.frame.origin.y = self.scrollView.frame.size.height - self.frame.height;
                }else{
                    self.frame.origin.y = scrollView.contentSize.height;
                }
            }
            self.frame.origin.y += SwiftRefreshFootViewHeight * 0.5;
            return;
        }
        
        let scrollViewContentOffsetY:CGFloat = scrollView.contentOffset.y;
        var height = SwiftRefreshHeadViewHeight;
        if SwiftRefreshHeadViewHeight > animations {
            height = animations;
        }
        if scrollViewContentOffsetY > 0 {
            let newContentOffSetY:CGFloat = scrollViewContentOffsetY + self.scrollView.frame.size.height;
            var tableMaxHeight:CGFloat = 0;
            if scrollView.isKindOfClass(UICollectionView) {
                let tepCollectionView:UICollectionView = scrollView as! UICollectionView;
                let height = tepCollectionView.collectionViewLayout.collectionViewContentSize().height;
                tableMaxHeight = height;
            }else{
                tableMaxHeight = scrollView.contentSize.height;
            }
            
            if (refreshStatus == .Normal){
                loadMoreTempAction = loadMoreAction
            }
            if (newContentOffSetY - tableMaxHeight) > 0 && scrollView.contentOffset.y != 0{
                if isEndloadMore == false && refreshStatus == .Normal {
                    if loadMoreTempAction != nil{
                        refreshStatus = .LoadMore;
                        self.title = SwiftRefreshLoadingText;
                        loadMoreTempAction?()
                        loadMoreTempAction = {}
                    }else {
                        self.title = SwiftRefreshMessageText;
                    }
                }
            }else if (isEndloadMore == false){
                loadMoreTempAction = loadMoreAction
                self.title = SwiftRefreshFootViewText;
            }
            
        }else if (isEndloadMore == false){
            self.title = SwiftRefreshFootViewText;
        }
    }
    
    func getViewControllerWithView(vcView:UIView) -> AnyObject {
        if vcView.nextResponder()?.isKindOfClass(UIViewController) == true {
            return vcView.nextResponder() as! UIViewController;
        }
        
        if vcView.superview == nil {
            return vcView;
        }
        
        return self.getViewControllerWithView(vcView.superview!);
    }
    
}