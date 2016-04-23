//
//  SwiftHeaderView.swift
//  SwiftRefresh
//
//  Created by Havi on 16/4/21.
//  Copyright © 2016年 Havi. All rights reserved.
//

import Foundation
import UIKit
var KVOContext = ""
let imageViewW:CGFloat = 50
let labelTextW:CGFloat = 150

public class SwiftHeaderView:UIView {
    
    /*
     propertys
    */
    private var headLabel:UILabel = UILabel();
    var headviewImage = UIImageView();//下拉中的图片处理
    var scrollView:UIScrollView = UIScrollView();//这个是处理滚动情况的
    var customAnimation:Bool = false;//决定是不是自定义动画
    var pullImages:[UIImage] = [UIImage]();//数组的自定义,下拉动画
    var loadingImages:[UIImage] = [UIImage]();//刷新动画。
    
    var animationStatus:HeaderViewAnimationStatus?;//动画状态
    var activityView:UIActivityIndicatorView?;
    
    var nowRefreshing:Bool = false {
        willSet{
            if newValue == true {
                self.nowRefreshing = newValue;
                self.scrollView.contentOffset = CGPointMake(0, -SwiftRefreshHeadViewHeight);//when check the headerView is loading change the scrollview's contentOffset.
            }
        }
    };
    
    var action:(()->())? = {};//
    var nowAction:(() -> ()) = {};
    private var refreshTempAction:(() -> Void)? = {};
    var imageName:String{
        set {
            if self.customAnimation {
                let image = pullImages[Int(newValue)!];
                self.headviewImage.image = image;
            }else{
                if self.animationStatus != .headerViewRefreshArrowAnimation {
                    self.headviewImage.image = self.imageFromBundleWithName("dropdown_anim__000\(newValue)");
                    print("\(newValue)");
                }else{
                    self.headviewImage.image = self.imageFromBundleWithName("arrow");
                }
            }
        }
        
        get {
            return self.imageName;
        }
    };
    /**
     some init meathod
     指定构造器必须指向父类构造器，
     便利构造器必须指向同级构造器。
     指定构造器和便利构造器都可以有多个。
    */
    convenience init(action:(() -> ()),frame:CGRect){
        self.init(frame:frame);
        self.action = action;
        self.initHeaderView();
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    /**
     layoutsubviews when the view is done
     */
    
    public override func layoutSubviews() {
        super.layoutSubviews();
        
        headLabel.sizeToFit();
        headLabel.frame = CGRectMake((self.frame.width - labelTextW)/2, -self.scrollView.frame.origin.y, labelTextW, self.frame.size.height);
        headviewImage.frame = CGRectMake(headLabel.frame.origin.x - imageViewW - 5, headLabel.frame.origin.y, imageViewW, self.frame.size.height);
        activityView?.frame = headviewImage.frame;
    }
    
    
    
    /**
     init headerview with some view
     */
    
    func initHeaderView(){
        let headImageView:UIImageView = UIImageView(frame: CGRectZero);
        headImageView.contentMode = .Center;
        headImageView.clipsToBounds = true;
        self.addSubview(headImageView);
        self.headviewImage = headImageView;
        
        let headerLabel:UILabel = UILabel(frame: self.frame);
        headerLabel.text = SwiftRefreshHeadViewText;
        headerLabel.textAlignment = .Center;
        headerLabel.clipsToBounds = true;
        self.addSubview(headerLabel);
        self.headLabel = headerLabel;
        
        let activityView:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray);
        self.addSubview(activityView);
        self.activityView = activityView;
    }
    
    func startAnimation() {
        if self.activityView?.isAnimating() == true {
            return;
        }
        
        if self.customAnimation {
            let duration:Double = Double(self.pullImages.count)*0.1;
            self.headviewImage.animationDuration = duration;
            self.headviewImage.animationImages = self.loadingImages;
        }else{
            if self.animationStatus == .headerViewRefreshArrowAnimation {
                self.activityView?.alpha = 1.0;
                self.headviewImage.hidden = true;
            }else{
                var results:[AnyObject] = [];
                for i in 1..<4 {
                    if let image = self.imageFromBundleWithName("dropdown_loading_0\(i)") {
                        results.append(image);
                    }
                }
                self.headviewImage.animationImages = results as? [UIImage];
                self.headviewImage.animationDuration = 0.6;
                self.activityView?.alpha = 0.0;
            }
            self.activityView?.startAnimating();
        }
        
        self.headLabel.text = SwiftRefreshLoadingText;
        if (self.animationStatus != .headerViewRefreshArrowAnimation){
            self.headviewImage.animationRepeatCount = 0;
            self.headviewImage.startAnimating();
        }
    }
    
    public func stopAnimation() {
        self.nowRefreshing = false;
        self.headLabel.text = SwiftRefreshHeadViewText;
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            if (abs(self.scrollView.contentOffset.y) >= self.getNavigationHeight() + SwiftRefreshHeadViewHeight){
                self.scrollView.contentInset = UIEdgeInsetsMake(self.getNavigationHeight(), 0, self.scrollView.contentInset.bottom, 0)
            }else{
                self.scrollView.contentInset = UIEdgeInsetsMake(self.getNavigationHeight(), 0, self.scrollView.contentInset.bottom, 0)
            }
        })
        
        if (self.animationStatus == .headerViewRefreshArrowAnimation){
            self.headviewImage.hidden = false
            self.activityView?.alpha = 0.0
        }else{
            self.activityView?.alpha = 1.0
            self.headviewImage.stopAnimating()
        }
        self.activityView?.stopAnimating()
    }
    
    /**
    when the view is done ,add an observer to obserers the scrollview's change
     
     - parameter newSuperview:
     */
    public override func willMoveToSuperview(newSuperview: UIView!) {
        superview?.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &KVOContext);
        //because this view must add the scrollview, so here use '!'to unwraper the view 
        /*
         this meathod is use unwraper method to estimate the weather the newSuperview is ScrollView
        if let view = newSuperview as? UIScrollView {
            view.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .Initial, context: &KVOContext);
        }
         */
        if (newSuperview != nil && newSuperview.isKindOfClass(UIScrollView)) {
            newSuperview.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .Initial, context: &KVOContext);
        }
    }
    
    /**
     the observer method to obser the scrollView when the scrollView scrolled.
     
     - parameter keyPath: the keyPath to seperate the different observer
     - parameter object:  object
     - parameter change:  change
     - parameter context:
     */
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if self.action == nil {
            return;//if the refresh action is nil,return.
        }
        
        if self.activityView?.isAnimating() == true {
            return;//this is define that the view is refreshing
        }
        
        let scrollView:UIScrollView = self.scrollView;
        let scrollViewContentOffsetY = scrollView.contentOffset.y;
        var height = SwiftRefreshHeadViewHeight;
        if SwiftRefreshHeadViewHeight > animations {
            height = animations;
        }
        //this is the assert to start the animation
        if ((scrollViewContentOffsetY + self.getNavigationHeight()) != 0 && (scrollViewContentOffsetY <= -height - scrollView.contentInset.top + 20)) {
            if self.animationStatus == .headerViewRefreshArrowAnimation {
                UIView.animateWithDuration(0.15, animations: { 
                    () -> Void in
                    self.headviewImage.transform = CGAffineTransformMakeRotation(CGFloat(M_PI));
                });
            }
            self.headLabel.text = SwiftRefreshRecoderText;
            if scrollView.dragging == false && self.headviewImage.isAnimating() == false {
                if refreshTempAction != nil {
                    refreshStatus = .Refresh;
                    self.startAnimation();
                    UIView.animateWithDuration(0.25, animations: { ()->Void in
                        if scrollView.contentInset.top == 0{
                            scrollView.contentInset = UIEdgeInsetsMake(self.getNavigationHeight(), 0, scrollView.contentInset.bottom, 0);
                        }else{
                            scrollView.contentInset = UIEdgeInsetsMake(SwiftRefreshHeadViewHeight + scrollView.contentInset.top, 0, scrollView.contentInset.bottom, 0);
                        }
                        
                    });
                    if nowRefreshing == true {
                        nowAction();
                        nowAction = {}
                        nowRefreshing = false
                    }else{
                        refreshTempAction?()
                        refreshTempAction = {}
                    }
                }
            }
        }else{
            if nowRefreshing == true {
                self.headLabel.text = SwiftRefreshLoadingText;
            }else if scrollView.dragging == true {
                self.headLabel.text = SwiftRefreshHeadViewText;
            }
            
            if (self.animationStatus == .headerViewRefreshArrowAnimation){
                UIView.animateWithDuration(0.15, animations: { () -> Void in
                    self.headviewImage.transform = CGAffineTransformIdentity;
                })
            }
            
            refreshTempAction = self.action;
        }
        
        if nowRefreshing == true {
            self.headLabel.text = SwiftRefreshLoadingText;
        }
        
        if scrollViewContentOffsetY <= 0 {
            var v:CGFloat = scrollViewContentOffsetY + scrollView.contentInset.top;
            if ((!self.customAnimation)&&(v < -animations)&&(v > animations)) {
                v = animations;
            }
            if self.customAnimation {
                v *= CGFloat(CGFloat(self.pullImages.count) / SwiftRefreshHeadViewHeight);
                if (Int(abs(v)) > self.pullImages.count - 1){
                    v = CGFloat(self.pullImages.count - 1);
                }
            }
            
            if ((Int)(abs(v)) > 0){
                self.imageName = "\((Int)(abs(v)))"
            }
        }
        
    }
    /**
     get the viewController of an view
     
     - parameter vcView: an view
     
     - returns: the controller
     */
    
    func getNavigationHeight() -> CGFloat {
        var vc = UIViewController();
        if self.getViewControllerWithView(self).isKindOfClass(UIViewController) == true {
            vc = self.getViewControllerWithView(self) as! UIViewController;
        }
        var top = vc.navigationController?.navigationBar.frame.height;
        if top == nil {
            top = 0;
        }
        // iOS7
        var offset:CGFloat = 20
        if((UIDevice.currentDevice().systemVersion as NSString).floatValue < 7.0){
            offset = 0
        }
        
        return offset + top!
        
    }
    
    func getViewControllerWithView(vcView:UIView) -> AnyObject {
        if vcView.nextResponder()?.isKindOfClass(UIViewController)==true {
            return vcView.nextResponder() as! UIViewController;//下一个响应链是一个viewController
        }
        if vcView.superview == nil {
            return vcView;//本身就是一个viewController
        }
        //
        return self.getViewControllerWithView(vcView.superview!);//一层层的调用
    }
    
    /**
     *  load the image from the bundle
     */
    
    func imageFromBundleWithName(name:String!) -> UIImage? {
        let bundle = NSBundle(identifier: "PullBundle");
        let image = SwiftRefreshBundleName.stringByAppendingFormat("/%@", name);
        if let image = UIImage(named: image, inBundle: bundle, compatibleWithTraitCollection: nil){
            return image;
        }
        return self.headviewImage.image;
        //this init meathod in image return an option value,so when use it must add '!' at the end.
    }
    
}
