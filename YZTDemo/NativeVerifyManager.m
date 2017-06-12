//
//  NativeVerifyManager.m
//  NativeConnectDemo
//
//  Created by Chow Tai Fook on 2017/6/9.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "NativeVerifyManager.h"
#import "PhoneAppVerify.h"
#import <UIKit/UIKit.h>

@interface NativeVerifyManager ()<VerifyDelegate>
@property (assign, nonatomic) BOOL hasVerify;
@property (assign, nonatomic) BOOL nextOperate;
@property (strong, nonatomic) NSString *phone;
@end

@implementation NativeVerifyManager

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(startToVerify:(NSString*)phoneNum){
  if (phoneNum.length == 11) {
    _hasVerify = NO;
    _phone = phoneNum;
    [[PhoneAppVerify sharedInstance] verifyPhone:phoneNum busiType:@"001"];
  }else{
    [self showAlertViewTitle:@"温馨提示" message:@"请输入正确的电话号码"];
  }

}

-(void)startNext:(NSString*)phoneNum{
  if (_hasVerify) {
    
  }else{
    if (phoneNum.length == 11) {
      _nextOperate = YES;
      [[PhoneAppVerify sharedInstance]queryVerifyPhone:phoneNum busiType:@"001"];
    }else{
      [self showAlertViewTitle:@"温馨提示" message:@"请输入正确的电话号码"];
    }
  }
}

- (void)verifyResult:(NSInteger)status errMsg:(NSString *)msg{
  switch (status) {
    case 0:
    {
      if (_nextOperate) {
        [self showAlertViewTitle:@"温馨提示" message:@"您还未进行电话拨号验证，请点击“拨号验证”按钮，重新验证"];
      }
      _nextOperate = NO;
    }
      break;
    case 1:
    {
      _hasVerify = YES;
      if (_nextOperate) {
        [[PhoneAppVerify sharedInstance]calcelVerifyPhone:_phone busiType:@"0001"];
      }else{
        [self showAlertViewTitle:@"温馨提示" message:@"电话拨号验证通过！"];
      }
      _nextOperate = NO;
    }
      break;
    case 2:
    {
      [self showAlertViewTitle:@"温馨提示" message:@"电话拨号验证失败！"];
    }
      break;
      
    default:
      break;
  }
}

- (void)verifyCancel:(NSInteger)status errMsg:(NSString *)msg{
  switch (status) {
    case 1:
    {
      /// 直接进入下一步的操作
      [self startNext:_phone];
    }
      break;
    case 2:
    {
      [self showAlertViewTitle:@"温馨提示" message:msg];
    }
      break;
      
    default:
      break;
  }
}

- (void)verifyTimerInterval:(NSInteger)timerInterval{
//  NSString *title = [NSString stringWithFormat:@"%zd秒",timerInterval];
//  [_verifyButton setTitle:title forState:UIControlStateNormal];
}

- (void)showAlertViewTitle:(NSString *)title message:(NSString *)msg{
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"style:UIAlertActionStyleCancel handler:nil];
  UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"style:UIAlertActionStyleDefault handler:nil];
  [alertController addAction:cancelAction];
  [alertController addAction:okAction];
  UIViewController *result = nil;
  UIWindow * window = [[UIApplication sharedApplication] keyWindow];
  if (window.windowLevel != UIWindowLevelNormal)
  {
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for(UIWindow * tmpWin in windows)
      {
        if(tmpWin.windowLevel == UIWindowLevelNormal)
        {
          window = tmpWin;
          break;
        }
      }
  }
  UIView *frontView = [[window subviews] objectAtIndex:0];
  id nextResponder = [frontView nextResponder];
  if ([nextResponder isKindOfClass:[UIViewController class]])
    result = nextResponder;
  else
    result = window.rootViewController;
  [result presentViewController:alertController animated:YES completion:^{
    
  }];
}

@end
