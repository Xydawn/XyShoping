//
//  ShoppingcartModel.h
//  ShopManager
//
//  Created by apple on 15/12/10.
//  Copyright © 2015年 Xydawn. All rights reserved.
//

#import "CHQModel.h"

@interface ShoppingcartModel : CHQModel

@property (nonatomic,copy) NSString *productid;
@property (nonatomic,copy) NSString *productname;
@property (nonatomic,copy) NSString *imageurl;
@property (nonatomic,copy) NSString *skuid;
@property (nonatomic,copy) NSString *skucontent;
@property (nonatomic,copy) NSString *adjustedprice;
@property (nonatomic,copy) NSString *quantity;
@property (nonatomic,copy) NSString *weight;
@property (nonatomic,copy) NSString *isfreeshipping;
@property (nonatomic) BOOL isSelected;

@end
/*
 "cartlist": [
 {
 "productid": 10,//产品编号
 "productname": "拼接面料百搭系带商务休闲鞋3",//产品名称
 "imageurl":"http://192.168.1.105/940c53d12c3b4ff8821814da2a08258c.jpg",//产品图片
 "skuid": "10_11_19",//规格编号
 "skucontent": "尺码：38; 颜色：黑色; ",//规格详情
 "adjustedprice": "321.0000",//价格
 "quantity": 1,//数量
 "weight": 0,//重量
 "isfreeshipping": false//是否包邮
 }
 ]
 */