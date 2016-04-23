//
//  ViewController.swift
//  SwiftRefresh
//
//  Created by Havi on 16/4/21.
//  Copyright © 2016年 Havi. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    var tableView:UITableView = UITableView();
    

    override func viewDidLoad() {
        super.viewDidLoad()
        weak var weakSelf = self as ViewController;
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.whiteColor();
        tableView = UITableView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), style: UITableViewStyle.Plain);
        tableView.delegate = self;
        tableView.dataSource = self;
        self.view.addSubview(tableView);
        
        var animationImages = [UIImage]()
        for i in 0..<73{
            var str = "PullToRefresh_00\(i)"
            if (i > 9){
                str = "PullToRefresh_0\(i)"
            }
            let image = self.imageFromBundleWithName(str);
            animationImages.append(image!)
        }
        
        // 加载动画
        var loadAnimationImages = [UIImage]()
        for i in 73..<141{
            var str = "PullToRefresh_0\(i)"
            if (i > 99){
                str = "PullToRefresh_\(i)"
            }
            let image = self.imageFromBundleWithName(str);
            if image != nil {
                loadAnimationImages.append(image!)
            }
        }
        
        // 上拉动画
        self.tableView.headerRefreshAnimationStatus(.headerViewRefreshPullAnimation, pullImages: animationImages, loadingImages: loadAnimationImages);
        self.tableView.headerRefreshAnimationStatus(.headerViewRefreshArrowAnimation, pullImages: [], loadingImages: []);

        tableView.pullDownRefresh{ () -> Void in
            weakSelf?.delay(2.0, closure: { () -> () in})
            weakSelf?.delay(2.0, closure: { () -> () in
                print("nowRefresh success")
                weakSelf?.tableView.reloadData();
                weakSelf?.tableView.doneRefresh()
            })
        };
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

    
    /**
     tableview delegate
     */
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("cell");
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell");
        }
        cell?.textLabel?.text = "niahoa";
        return cell!;
    }
    
    func imageFromBundleWithName(name:String!) -> UIImage? {
        let bundle = NSBundle(identifier: "PullBundle");
        let image = SwiftRefreshBundleName.stringByAppendingFormat("/%@", name);
        if let image = UIImage(named: image, inBundle: bundle, compatibleWithTraitCollection: nil){
            return image;
        }
        return nil;
        //this init meathod in image return an option value,so when use it must add '!' at the end.
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

