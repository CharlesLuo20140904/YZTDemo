//
//  ViewController.m
//  YZTDemo
//
//  Created by Chow Tai Fook on 2017/6/7.
//  Copyright © 2017年 Chow Tai Fook. All rights reserved.
//

#import "ViewController.h"
#import "PhoneAppVerify.h"
#import "SecondViewController.h"
@interface ViewController ()<UITextFieldDelegate,VerifyDelegate>
@property (weak, nonatomic) IBOutlet UIButton *startBtb;
- (IBAction)startVerify:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (assign, nonatomic) BOOL hasVerify;
@property (assign, nonatomic) BOOL nextOperate;;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.phoneTextField.delegate = self;
    [PhoneAppVerify sharedInstance].verifyDelegate = self;
    self.nextBtn.layer.cornerRadius = 5.0;
    self.startBtb.layer.cornerRadius = 2.0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)startVerify:(id)sender {
    if (_phoneTextField.text.length == 11) {
        [[PhoneAppVerify sharedInstance] verifyPhone:_phoneTextField.text busiType:@"001"];
    }else{
        [self showAlertViewTitle:@"温馨提示" message:@"请输入正确的电话号码"];
    }
}
- (IBAction)startNext:(id)sender {
    if (_hasVerify) {
        UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        SecondViewController *sec = [mainstoryboard instantiateViewControllerWithIdentifier:@"second"];
        [self presentViewController:sec animated:YES completion:nil];
    }else{
        if (_phoneTextField.text.length == 11) {
            _nextOperate = YES;
            [[PhoneAppVerify sharedInstance]queryVerifyPhone:_phoneTextField.text busiType:@"001"];
        }else{
            [self showAlertViewTitle:@"温馨提示" message:@"请输入正确的电话号码"];
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)verifyResult:(NSInteger)status errMsg:(NSString *)msg{
    NSLog(@"%zi",status);
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
                [[PhoneAppVerify sharedInstance]calcelVerifyPhone:_phoneTextField.text busiType:@"0001"];
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
            [self startNext:nil];
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
//    NSString *title = [NSString stringWithFormat:@"%zd秒",timerInterval];
//    [self.startBtb setTitle:title forState:UIControlStateNormal];
}


- (void)showAlertViewTitle:(NSString *)title message:(NSString *)msg{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}
@end
