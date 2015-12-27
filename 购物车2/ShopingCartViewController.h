//
//  ShopingCartViewController.h
//  TangXianManual
//
//  Created by Han on 15/6/25.
//  Copyright (c) 2015年 Xydawn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopingCartViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *payBtn;
- (IBAction)goToPay:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *chooseAllGoodsBtn;
@property (weak, nonatomic) IBOutlet UILabel *totalPrice;

@end
