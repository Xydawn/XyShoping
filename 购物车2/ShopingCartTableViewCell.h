//
//  ShopingCartTableViewCell.h
//  TangXianManual
//
//  Created by Han on 15/6/25.
//  Copyright (c) 2015年 Xydawn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopingCartTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *myTF;
@property (weak, nonatomic) IBOutlet UIImageView *goodsImgView;
@property (weak, nonatomic) IBOutlet UILabel *goodsName;
@property (weak, nonatomic) IBOutlet UILabel *goodsPrice;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *minusBtn;


@property (weak, nonatomic) IBOutlet UIButton *choosePay;


@end
