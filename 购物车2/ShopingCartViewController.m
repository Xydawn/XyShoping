//
//  ShopingCartViewController.m
//  TangXianManual
//
//  Created by Han on 15/6/25.
//  Copyright (c) 2015年 Han. All rights reserved.
//

#import "ShopingCartViewController.h"
#import "MBProgressHUD.h"
#import "ShopingCartTableViewCell.h"
#import "ShoppingcartModel.h"

#define kShowTag1 5055
#define kShowTag2 5050
@interface ShopingCartViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>
{
    int tag ;
    int b;
    UITableView * table;
    UITextField * myTF;
    float  _sumStr;
    NSMutableArray * goodsArr,*choosePayArr, *sumArr;
    
    float currentCount;
}

@property (nonatomic,strong) NSMutableArray *cartID;
@property (nonatomic ) NSInteger Row;
@property (nonatomic,strong) NSMutableArray *selectArr;
@property (nonatomic) NSInteger oldCount;
@property (nonatomic) NSInteger changeCount;
@property (nonatomic) BOOL isloading;
@property (nonatomic) BOOL isChange;
@end

@implementation ShopingCartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    [self initNac];
    _isChange = NO;
    
     goodsArr = [NSMutableArray array];
    choosePayArr = [NSMutableArray array];
    sumArr =[NSMutableArray array];
    currentCount=0;
    self.payBtn.clipsToBounds =YES;
    self.payBtn.layer.cornerRadius = 5;
   
    [_chooseAllGoodsBtn addTarget:self action:@selector(chooseAllGoodsBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.isloading = NO;
    table =[[UITableView alloc]initWithFrame:CGRectMake(0, 64, k_width, k_height-64-60)style:UITableViewStylePlain];
    table.separatorStyle =   UITableViewCellSeparatorStyleNone;
    table.bounces = NO;
    table.tag  = 10000;
    table.delegate =self;
    table.dataSource = self;
    [self.view addSubview:table];
    table.backgroundColor=[UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1];
    [self getShopCartDateRequst];
}
#pragma mark - initNac
-(void)initNac{
      self.title = @"购物车";
    UIBarButtonItem *清空 = [[UIBarButtonItem alloc]initWithTitle:@"清空" style:(UIBarButtonItemStyleDone) target:self action:@selector(清空点击)];
    UIBarButtonItem *移至收藏夹 = [[UIBarButtonItem alloc]initWithTitle:@"移至收藏夹" style:(UIBarButtonItemStyleDone) target:self action:@selector(移至收藏夹点击)];
    self.navigationItem.rightBarButtonItems = @[移至收藏夹,清空];
}

-(void)清空点击{
    UIAlertView *view = [self showOnAlertViewWithTitle:@"提示" msg:@"是否要清空购物车？"];
    view.tag = kShowTag1;
}


-(void)移至收藏夹点击{
    UIAlertView *view = [self showOnAlertViewWithTitle:@"提示" msg:@"是否收藏这些商品?"];
    view.tag = kShowTag2;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex) {
        if (alertView.tag == kShowTag1) {
            [self getDownloadWith:@"/webApi/App_Api.ashx?action=clearcart" With:^(id dict) {
                [self showHint:@"购物车已清空"];
                [goodsArr removeAllObjects];
                [table reloadData];
            } andDefeated:^(id dict) {
                
            } with:@{GetUserAll}];
        }else if (alertView.tag == kShowTag2){
            
        }
       
    }
}

#pragma mark购物车列表
-(void)getShopCartDateRequst
{
    [self getDownloadWith:@"/webApi/App_Api.ashx?action=shoppingcart" With:^(id dict) {
        _sumStr = [dict[@"totalprice"] floatValue];
        for (NSDictionary *dic in dict[@"cartlist"]) {
            ShoppingcartModel *model = [[ShoppingcartModel alloc]init];
            [model setValuesForKeysWithDictionary:dic];
            [goodsArr addObject:model];
            [choosePayArr addObject:@"No"];
            [table reloadData ];
        }
    } andDefeated:^(id dict) {
        
    } with:@{
             GetUserAll
             }];
}


-(void)alertViewCancel:(UIAlertView *)alertView{
    [self getShopCartDateRequst];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return goodsArr.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    
    static NSString * identifier = @"cellmy";
    
    ShopingCartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil)
    {
        NSArray *cellXib = [[NSBundle mainBundle]loadNibNamed:@"ShopingCartTableViewCell" owner:self options:nil];
        
        for (id oneObject in cellXib)
        {
            if ([oneObject isKindOfClass:[ShopingCartTableViewCell class]])
            {
                 cell = (ShopingCartTableViewCell *)oneObject;
            }
        }
    }
    cell.myTF.delegate = self;
    cell.myTF.tag = 10000+indexPath.row;
    cell.myTF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    
    ShoppingcartModel* cartModel = goodsArr[indexPath.row];
    cell.myTF.text = [NSString stringWithFormat:@"%@", cartModel.quantity];
    [cell.goodsImgView setImageWithURL:[NSURL URLWithString:cartModel.imageurl]];
    cell.goodsName.text =cartModel.productname;
    cell.goodsPrice.text = [NSString stringWithFormat:@"¥%@",cartModel.adjustedprice];
    //文字增加删除线
   /* NSString * oldPrice=[NSString stringWithFormat:@"¥%@",cartModel.goods_marketprice];
    NSInteger length = oldPrice.length;
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:oldPrice];
    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, length)];
     [cell.marketPriceLabel setAttributedText:attri];
*/
    [cell.choosePay addTarget:self action:@selector(cellChoosePay:) forControlEvents:UIControlEventTouchUpInside];
    cell.choosePay.tag = indexPath.row +1000;
    cell.choosePay.selected = cartModel.isSelected;
    
    
    [cell.addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.addBtn.tag = 1000+indexPath.row;
    
    [cell.minusBtn addTarget:self action:@selector(minusBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.minusBtn.tag = 2000+indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    cell.goodsPrice.adjustsFontSizeToFitWidth = YES;
    cell.myTF.adjustsFontSizeToFitWidth = YES;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (  _isChange == NO) {
        
/*
      ShoppingcartModel* cartModel = goodsArr[indexPath.row];
*/
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 100;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {

        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    [table reloadData];
}
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    return @"删除";
//}



- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
   __block ShoppingcartModel* cartModel = goodsArr[indexPath.row];
    NSString *idStr = [NSString stringWithFormat:@"%@", cartModel.skuid];

    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除"handler:^(UITableViewRowAction *action,NSIndexPath *indexPath) {
        
        
        
        [self getDownloadWith:@"/webApi/App_Api.ashx?action=delcart" With:^(id dict) {
            [self showHint:@"删除成功"];
            _sumStr -=[cartModel.adjustedprice floatValue]*[cartModel.quantity integerValue];
            if (cartModel.isSelected==YES) {
                self.Row --;
                
                
                
                currentCount -=  [cartModel.adjustedprice floatValue]*[cartModel.quantity integerValue];
                
                _totalPrice.text = [NSString stringWithFormat:@"总计:￥%0.2f",  currentCount];
                
                
                [self.selectArr removeObject:cartModel];
            }
            [goodsArr removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

        } andDefeated:^(id dict) {
            
        } with:@{
                 GetUserAll,
                 @"skuid":idStr
                 }];
        }];
    
    deleteRowAction.backgroundColor = [UIColor redColor];

    return  @[deleteRowAction];
    
    
}
#pragma mark   点空白处键盘回收
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    [myTF resignFirstResponder];
}
#pragma mark - UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{   myTF = textField;
    _isloading = YES;
    self.oldCount = [myTF.text integerValue];
    _isChange = YES;
    [textField selectAll:textField];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    /*
   ^[1-9]d*$
     */
    _isChange = NO;
    NSString *Regex = @"^[0-9]*$";
    NSPredicate *Test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
    if (![Test evaluateWithObject:textField.text]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"输入有误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];

            return;
    }
    
    if (_isloading) {
        NSInteger buttontag = myTF.tag -10000;
        CHQLog(@"%ld",buttontag);
         ShoppingcartModel* cartModel =  goodsArr[buttontag];
        cartModel.quantity  =[NSString stringWithFormat:@"%d" ,[myTF.text intValue]];
        
        
        self.changeCount = [myTF.text integerValue]-_oldCount;
        
//        _cartModel.goods_num = self.changeCount;
        
        [self changeTheDataWith:buttontag];
        _isloading = NO;
    }


    
    [myTF resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self textFieldDidEndEditing:myTF];
    return YES;
}

#pragma mark    刷新数据
-(void)changeTheDataWith:(NSInteger)buttontag{
  __block  ShoppingcartModel* cartModel =  goodsArr[buttontag];
    
    NSString *idStr = [NSString stringWithFormat:@"%@", cartModel.skuid ];
    
    NSString * numStr = [NSString stringWithFormat:@"%@",cartModel.quantity];
    
    
    [self getDownloadWith:@"/webApi/App_Api.ashx?action=updatecartinfo" With:^(id dict) {
        [self showHint:@"修改成功"];
        cartModel.quantity =dict[@"quantity"];
        _sumStr += [cartModel.adjustedprice floatValue]*_changeCount;
        if (cartModel.isSelected==YES) {
            currentCount +=  [cartModel.adjustedprice longLongValue]*_changeCount;
            _totalPrice.text=[NSString stringWithFormat:@"总计:￥%0.2f",  currentCount];
            
        }
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:buttontag inSection:0];
        [table reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    } andDefeated:^(id dict) {
        
    } with:@{
             GetUserAll,
             @"skuid": idStr,
             @"quantity":numStr
             }];
/*
 
             
             _cartModel.goods_num = [dic[@"body"][@"quantity"] intValue];
             
             [goodsArr replaceObjectAtIndex:buttontag withObject:_cartModel];
             
             _sumStr += [_cartModel.goods_price longLongValue]*_changeCount;
             CHQLog(@"%f",_sumStr);
             if (_cartModel.isSelected==YES) {
                 currentCount +=  [_cartModel.goods_price longLongValue]*_changeCount;
                 _totalPrice.text=[NSString stringWithFormat:@"总计:￥%0.2f",  currentCount];
                 
             }
 
*/
}


#pragma mark - 增加购物
-(void)addBtnClick:(UIButton *)send
{
  
   __block ShoppingcartModel *cartModel = goodsArr [send.tag -1000];
    
    NSString *idStr = [NSString stringWithFormat:@"%@", cartModel.skuid];
    
    NSString * numStr = [NSString stringWithFormat:@"%d",[cartModel.quantity intValue]+1 ];
    
    [self getDownloadWith:@"/webApi/App_Api.ashx?action=updatecartinfo" With:^(id dict) {
         cartModel.quantity = dict[@"quantity"];
//        [goodsArr replaceObjectAtIndex: send.tag -1000 withObject:cartModel];
         _sumStr =_sumStr+[cartModel.adjustedprice floatValue];
        if (cartModel.isSelected==YES) {
            currentCount +=  [cartModel.adjustedprice floatValue];
            
            _totalPrice.text=[NSString stringWithFormat:@"总计:￥%0.2f",currentCount];
            
            
            
        }

        
        [self showHint:@"修改成功"];
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:send.tag-1000 inSection:0];
        [table reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];

    } andDefeated:^(id dict) {
        
    } with:@{
             GetUserAll,
             @"skuid":idStr,
             @"quantity":numStr
             }];
}


#pragma mark   减少数量
-(void)minusBtnClick:(UIButton *)send
{

    __block ShoppingcartModel *cartModel = goodsArr [send.tag -2000];
    
    NSString *idStr = [NSString stringWithFormat:@"%@", cartModel.skuid];
    
    NSString * numStr = [NSString stringWithFormat:@"%d",[cartModel.quantity intValue]-1 ];
    
    [self getDownloadWith:@"/webApi/App_Api.ashx?action=updatecartinfo" With:^(id dict) {
        cartModel.quantity = dict[@"quantity"];
//        [goodsArr replaceObjectAtIndex: send.tag -2000 withObject:cartModel];
        _sumStr =_sumStr-[cartModel.adjustedprice floatValue];
        if (cartModel.isSelected==YES) {
            currentCount -=  [cartModel.adjustedprice floatValue];
            
            _totalPrice.text=[NSString stringWithFormat:@"总计:￥%0.2f",currentCount];
            
        }
        
        [self showHint:@"修改成功"];
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:send.tag-2000 inSection:0];
        [table reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        
    } andDefeated:^(id dict) {
        
    } with:@{
             GetUserAll,
             @"skuid":idStr,
             @"quantity":numStr
             }];

  
    
    /*
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    // act=login&op=verify_mobile
    
    
    NSString * str = [[NSUserDefaults standardUserDefaults]objectForKey:@"token"];
    
    
    NSDictionary * dic = @{@"cart_id":idStr,@"quantity":numStr,@"token":str};
    [manager POST: [ NSString stringWithFormat:@"%@act=member_cart&op=cart_edit_quantity",HEARD_URL ]parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         
         CHQLog(@"dic    %@",responseObject);
         
         CHQLog(@"输出的项目是%@",responseObject);
         NSDictionary * dic = (NSDictionary * )responseObject;
         int  code =[dic[@"head"][@"code"]intValue];
         if (code == 200)
         {
             
             _cartModel.goods_num = [dic[@"body"][@"quantity"] intValue];
             
             [goodsArr replaceObjectAtIndex: send.tag -2000 withObject:_cartModel];
             
             
             CHQLog(@"%@goodsarr  new  ",goodsArr);
             _sumStr =_sumStr -[_cartModel.goods_price floatValue];
             if (_cartModel.isSelected==YES) {
                 currentCount -=  [_cartModel.goods_price floatValue];
                 
                 _totalPrice.text=[NSString stringWithFormat:@"总计:￥%0.2f",  currentCount];
                 
                 //             }else{
                 //                 if (_cartModel.isSelected==YES) {
                 //
                 //                     currentCount -=  [_cartModel.goods_price intValue];
                 //                     _totalPrice.text = [NSString stringWithFormat:@"总计:￥%0.2f",  currentCount];
                 //                     _sumStr =_sumStr -[_cartModel.goods_price floatValue];
                 //                 }
                 //
                 
                 
             }
             
             [table reloadData];
             [MBProgressHUD hideHUDForView:self.view animated:YES];
         }
         else
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             UIAlertView * alert= [[UIAlertView  alloc]initWithTitle:@"温馨提示" message:@"操作失败" delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil
                                   ];
             
             [alert show];
             return ;
             
             
         }
         
         
         [MBProgressHUD hideHUDForView:self.view animated:YES];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         UIAlertView * alert  = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"网络连接失败" delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
         [alert show];
         
     }];
      */
}
    
#pragma mark - 算法
#pragma mark   cellChoosePay
-(void)cellChoosePay:(UIButton *)cellChooseBtn
{
    NSInteger  choose =  cellChooseBtn.tag - 1000;

    [choosePayArr replaceObjectAtIndex:choose withObject:@"Yes"];
    ShoppingcartModel*cartModel = goodsArr[choose];
    
    if (cellChooseBtn.selected == YES)
    {
        self.Row --;
       currentCount -=  [cartModel.adjustedprice floatValue]*[cartModel.quantity integerValue];
        _totalPrice.text = [NSString stringWithFormat:@"总计:￥%0.2f",  currentCount];
        [self.selectArr removeObject:goodsArr[choose]];
    }
    if (cellChooseBtn.selected == NO)
    {
        self.Row ++;
         currentCount  +=  [cartModel.adjustedprice floatValue]*[cartModel.quantity integerValue];
        _totalPrice.text = [NSString stringWithFormat:@"总计:￥%0.2f",  currentCount];
        [self.selectArr addObject:goodsArr[choose]];
    }
    
    cartModel.isSelected = !cartModel.isSelected;

    [table reloadData];
    if (self.Row==goodsArr.count) {
        _chooseAllGoodsBtn.selected =YES;
    }else{
        _chooseAllGoodsBtn.selected = NO;
    }
}

-(void)chooseAllGoodsBtnClick
{
    _chooseAllGoodsBtn.selected = !_chooseAllGoodsBtn.selected;
    
    for (UIView *v  in table.subviews) {
        for (UIView *v1 in v.subviews) {
            if ([v1 isKindOfClass:[ShopingCartTableViewCell class]]) {
                ShopingCartTableViewCell *cell=(ShopingCartTableViewCell *)v1;
                if (_chooseAllGoodsBtn.selected==YES) {
                    cell.choosePay.selected=YES;
                    for (ShoppingcartModel *model in goodsArr) {
                        model.isSelected = YES;
                    }
                }else{
                    cell.choosePay.selected=NO;
                    for (ShoppingcartModel *model in goodsArr) {
                        model.isSelected = NO;
                    }
                }
                
            }
        }
       
    }
    if (_chooseAllGoodsBtn.selected == YES)
    {
        _totalPrice.text = [NSString stringWithFormat:@"总计:￥%0.2f",_sumStr];
        currentCount = _sumStr ;
        self.Row = goodsArr.count;
        [self.selectArr setArray:goodsArr];
    }
    if (_chooseAllGoodsBtn.selected == NO)
    {
        _totalPrice.text = @"总计:￥0.00";
        currentCount= 0;
        self.Row = 0;
        [self.selectArr removeAllObjects];
    }
    [table reloadData];
}

- (IBAction)goToPay:(UIButton *)sender
{
    [self showHint:@"11111"];
   
}

@end
