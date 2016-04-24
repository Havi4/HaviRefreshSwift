//
//  HaviRefreshExtension.swift
//  SwiftRefresh
//
//  Created by Havi on 16/4/21.
//  Copyright © 2016年 Havi. All rights reserved.
//

import UIKit

let animations:CGFloat = 60.0;
var refreshStatus:RefreshStatus = .Normal;

public enum RefreshStatus{
    case Normal, Refresh, LoadMore
}

public enum HeaderViewAnimationStatus{
    case headerViewRefreshPullAnimation, headerViewRefreshLoadingAnimation, headerViewRefreshArrowAnimation;
}

extension UIScrollView:UIScrollViewDelegate
{
    //定义headerview,定义一个option，可能为空
    public var headerRefreshView: SwiftHeaderView? {
        //定义get方法
        get {
            let headerRefreshView = viewWithTag(SwiftHeadViewTag);
            return headerRefreshView as? SwiftHeaderView;//类型转换向下类型转换，可选的，是否成功。
        }
    }
    
    public var footerLoadMoreView: SwiftFooterView? {
        get {
            let footerLoadMoreView = viewWithTag(SwiftFootViewTag);
            return footerLoadMoreView as? SwiftFooterView;
            
        }
    }
    
    //下拉刷新操作，默认是用activeacindicator这个是必须调用的方法
    
    public func pullDownRefresh(action:(()->Void)){//参数是action类型是（）-> Void
        self.alwaysBounceVertical = true;
        //decide the if the headerview is nil,if the view is nil,init an headerview or use the view that has init.
        if self.headerRefreshView == nil {
            //here use the 'tag' to align the view.
            let headerView:SwiftHeaderView = SwiftHeaderView(action: action, frame: CGRectMake(0, -SwiftRefreshHeadViewHeight, self.frame.size.width, SwiftRefreshHeadViewHeight));
            headerView.scrollView = self;
            headerView.tag = SwiftHeadViewTag;
            self.addSubview(headerView);
            
        }else{
            self.headerRefreshView?.action = action;
        }
        self.headerRefreshView?.nowAction = action;
        self.headerRefreshView?.nowRefreshing = true;
    }
    
    //自定义刷新方式。来控制下拉刷新动画等方式的
    
    public func headerRefreshAnimationStatus(status:HeaderViewAnimationStatus,  pullImages:[UIImage],loadingImages:[UIImage]){
        if self.headerRefreshView == nil {
            let headerView:SwiftHeaderView = SwiftHeaderView(action: {}, frame: CGRectMake(0, -SwiftRefreshHeadViewHeight, self.frame.size.width, SwiftRefreshHeadViewHeight));
            headerView.scrollView = self;
            headerView.tag = SwiftHeadViewTag;
            self.addSubview(headerView);
        }
        //决定是不是arrow
        if status != .headerViewRefreshArrowAnimation {
            self.headerRefreshView?.customAnimation = true;
        }
        
        self.headerRefreshView?.animationStatus = status;
        
        if (status == .headerViewRefreshLoadingAnimation){
            self.headerRefreshView?.headviewImage.animationImages = pullImages;
        }else{
            self.headerRefreshView?.headviewImage.image = pullImages.first;
            self.headerRefreshView?.pullImages = pullImages;
            self.headerRefreshView?.loadingImages = loadingImages;
        }
    }
    
    public func doneRefresh(){
        if let headerView:SwiftHeaderView = self.viewWithTag(SwiftHeadViewTag) as? SwiftHeaderView {
            headerView.stopAnimation();
        }
        refreshStatus = .Normal
    }
    
    //footer

}

