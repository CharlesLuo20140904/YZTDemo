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
#import "DesUtil.h"



@interface ViewController ()<UITextFieldDelegate,VerifyDelegate,NSURLSessionDelegate>
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
    self.title = @"验证";
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
//    if (_phoneTextField.text.length == 11) {
//        [[PhoneAppVerify sharedInstance] verifyPhone:_phoneTextField.text busiType:@"001"];
//    }else{
//        [self showAlertViewTitle:@"温馨提示" message:@"请输入正确的电话号码"];
//    }
//    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//    [[UIApplication sharedApplication] openURL:url];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=INTERNET_TETHERING"]];
    NSString *url = @"https://cls.sms.sooware.com/csms/sms/send.do";
//    NSString *phone = @"18475436205";
    NSString *openID = @"F8185A2AD6EE4F15ABBA691166829C6A";
    NSDictionary *dataDict = @{
    @"areaID":@"", @"mobile":@"18475436205",
    @"content": @"validate code: 1234", @"templateId":@"templateId123",
    @"msgid":@"msg1234", @"cbUrl":@""
    };
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDict options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *dcstr = [DesUtil convertStringToHexStr:[DesUtil AES128Encrypt:str]];
//    NSString *dcstr = [DesUtil AES128Encrypt:str];
    NSString *poststr= [NSString stringWithFormat:@"{\"header\":{\"from\":\"zdf\", \"openId\":\"%@\"},\"body\":\"%@\"}",openID,dcstr];
    NSLog(@"----%@",poststr);
    NSURLSessionConfiguration* ephConfiguration=[NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session=[NSURLSession sessionWithConfiguration:ephConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [poststr dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    [dataTask resume];
}

-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] && [challenge.protectionSpace.host hasSuffix:@"cls.sms.sooware.com"]) {
        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        if (credential) {
            disposition = NSURLSessionAuthChallengeUseCredential;
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    } else {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
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

//+ (NSString *)convertStringToHexStr:(NSString *)str {
//    if (!str || [str length] == 0) {
//        return @"";
//    }
//    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
//    
//    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
//    
//    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
//        unsigned char *dataBytes = (unsigned char*)bytes;
//        for (NSInteger i = 0; i < byteRange.length; i++) {
//            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
//            if ([hexStr length] == 2) {
//                [string appendString:hexStr];
//            } else {
//                [string appendFormat:@"0%@", hexStr];
//            }
//        }
//    }];
//    
//    return string;
//}

@end
