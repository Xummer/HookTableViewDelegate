//
//  ViewController.h
//  HookTableViewDelegate
//
//  Created by Xummer on 2019/8/2.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FatherViewController : UIViewController
@property (nonatomic, weak) UITableView *tableView;
- (void)addKVO;
@end

@interface ViewController : FatherViewController


@end

