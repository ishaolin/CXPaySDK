//
//  CXPayService.m
//  Pods
//
//  Created by wshaolin on 2017/5/28.
//
//

#import "CXPayService.h"
#import <AlipaySDK/AlipaySDK.h>
#import "CXPayOrderParamsModel.h"
#import "WXApi.h"
#import <CXFoundation/CXFoundation.h>
#import "UPPaymentControl.h"
#import "UPAPayPlugin.h"
#import "UPAPayPluginDelegate.h"
#import <PassKit/PassKit.h>

@interface CXPayService () <UPAPayPluginDelegate> {
    
}

@property (nonatomic, copy) CXPayServiceCompoletionBlock compoletion;

@end

@implementation CXPayService

+ (BOOL)canMakePayments{
    if(@available(iOS 10.0, *)){
        return [PKPaymentAuthorizationController canMakePayments];
    }
    
    return [PKPaymentAuthorizationViewController canMakePayments];
}

+ (BOOL)canMakePaymentsUsingChinaUnionPay{
    if(@available(iOS 9.2, *)){
        NSArray<PKPaymentNetwork> *networks = @[PKPaymentNetworkChinaUnionPay];
        if(@available(iOS 10.0, *)){
            return [PKPaymentAuthorizationController canMakePaymentsUsingNetworks:networks];
        }
        return [PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:networks];
    }else{
        return NO;
    }
}

+ (instancetype)defaultService{
    static CXPayService *_service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _service = [[self alloc] init];
    });
    
    return _service;
}

- (void)payOrder:(CXPayOrderParamsModel *)order
          scheme:(NSString *)scheme
  viewController:(UIViewController *)viewController
     compoletion:(CXPayServiceCompoletionBlock)compoletion{
    self.compoletion = compoletion;
    
    if(![order isValidParams]){
        [self handleCallbackForChannel:order.payChannel
                             payStatus:CXPayStatusFailed
                                   msg:@"缺少支付参数"];
        return;
    }
    
    if(order.payChannel == CXPayChannelAlipay){
        [[AlipaySDK defaultService] payOrder:order.payStr fromScheme:scheme callback:^(NSDictionary<NSString *, id> *dictionary) {
            [self handlePayCallbackForAlipay:dictionary];
        }];
    }else if(order.payChannel == CXPayChannelWeChat){
        if(![WXApi isWXAppInstalled]){
            [self handleCallbackForChannel:order.payChannel
                                 payStatus:CXPayStatusNotInstalled
                                       msg:@"没有安装微信"];
            return;
        }
        
        if(![WXApi isWXAppSupportApi]){
            [self handleCallbackForChannel:order.payChannel
                                 payStatus:CXPayStatusNotSupported
                                       msg:@"微信版本过低"];
            return;
        }
        
        PayReq *payReq = [[PayReq alloc] init];
        payReq.openID = order.weChatParams.appId;
        payReq.partnerId = order.weChatParams.partnerId;
        payReq.prepayId = order.weChatParams.prepayId;
        payReq.nonceStr = order.weChatParams.nonceStr;
        payReq.package = order.weChatParams.package;
        payReq.sign = order.weChatParams.sign;
        payReq.timeStamp = (UInt32)order.weChatParams.timeStamp;
        
        [WXApi registerApp:payReq.openID universalLink:self.weChatUniversalLink];
        [WXApi sendReq:payReq completion:^(BOOL success) {
            if(!success){
                [self handleCallbackForChannel:order.payChannel
                                     payStatus:CXPayStatusCommonError
                                           msg:@"未知错误"];
            }
        }];
    }else if(order.payChannel == CXPayChannelUnionPay){
        [[UPPaymentControl defaultControl] startPay:order.payStr
                                         fromScheme:scheme
                                               mode:order.unionPayEnvMode
                                     viewController:viewController];
    }else if(order.payChannel == CXPayChannelApplePay){
        if([CXPayService canMakePaymentsUsingChinaUnionPay]){
            [UPAPayPlugin startPay:order.payStr
                              mode:order.unionPayEnvMode
                    viewController:viewController
                          delegate:self
                    andAPMechantID:order.mechantId];
        }else{
            [self handleCallbackForChannel:order.payChannel
                                 payStatus:CXPayStatusNotSupported
                                       msg:@"此设备不支持Apple Pay或者没有启用Apple Pay"];
        }
    }
}

- (void)handleAlipayOpenURL:(NSURL * _Nonnull)url{
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary<NSString *, id> *dictionary) {
        [self handlePayCallbackForAlipay:dictionary];
    }];
}

- (void)handleUnionPayOpenURL:(NSURL * _Nonnull)url{
    [[UPPaymentControl defaultControl] handlePaymentResult:url completeBlock:^(NSString *code, NSDictionary *data) {
        CXPayStatus status = CXPayStatusCommonError;
        if([code isEqualToString:@"success"]){
            status = CXPayStatusSuccess;
        }else if([code isEqualToString:@"fail"]){
            status = CXPayStatusFailed;
        }else if([code isEqualToString:@"cancel"]){
            status = CXPayStatusCancel;
        }
        
        [self handleCallbackForChannel:CXPayChannelUnionPay
                             payStatus:status
                                   msg:@""];
    }];
}

- (void)handlePayCallbackForAlipay:(NSDictionary<NSString *, id> *)dictionary{
    [CXDispatchHandler asyncOnMainQueue:^{
        NSInteger status = [dictionary cx_numberForKey:@"resultStatus"].integerValue;
        CXPayStatus payStatus = CXPayStatusCommonError;
        NSString *msg = @"未知错误";
        switch (status) {
            case 4000:{
                payStatus = CXPayStatusFailed;
                msg = @"支付失败";
            }
                break;
            case 5000:{
                payStatus = CXPayStatusCommonError;
                msg = @"重复请求";
            }
                break;
            case 6001:{
                payStatus = CXPayStatusCancel;
                msg = @"请求取消";
            }
                break;
            case 6002:{
                payStatus = CXPayStatusCommonError;
                msg = @"网络错误";
            }
                break;
            case 6004:{
                payStatus = CXPayStatusCommonError;
                msg = @"未知结果";
            }
                break;
            case 8000:{
                payStatus = CXPayStatusCommonError;
                msg = @"支付处理中";
            }
                break;
            case 9000:{
                payStatus = CXPayStatusSuccess;
                msg = @"支付成功";
            }
                break;
            default:
                break;
        }
        
        [self handleCallbackForChannel:CXPayChannelAlipay
                             payStatus:payStatus
                                   msg:msg];
    }];
}

- (void)handleWeChatPayCallback:(PayResp *)payResp{
    [CXDispatchHandler asyncOnMainQueue:^{
        CXPayStatus status = CXPayStatusCommonError;
        switch (payResp.errCode) {
            case WXSuccess:{
                status = CXPayStatusSuccess;
            }
                break;
            case WXErrCodeCommon:{
                status = CXPayStatusCommonError;
            }
                break;
            case WXErrCodeUserCancel:{
                status = CXPayStatusCancel;
            }
                break;
            case WXErrCodeSentFail:{
                status = CXPayStatusFailed;
            }
                break;
            default:
                break;
        }
        
        [self handleCallbackForChannel:CXPayChannelWeChat
                             payStatus:status
                                   msg:payResp.errStr];
    }];
}

- (void)UPAPayPluginResult:(UPPayResult *)payResult{
    CXPayStatus status = CXPayStatusCommonError;
    if(payResult.paymentResultStatus == UPPaymentResultStatusSuccess){
        status = CXPayStatusSuccess;
    }else if(payResult.paymentResultStatus == UPPaymentResultStatusFailure){
        status = CXPayStatusFailed;
    }else if(payResult.paymentResultStatus == UPPaymentResultStatusCancel){
        status = CXPayStatusCancel;
    }
    
    [self handleCallbackForChannel:CXPayChannelApplePay
                         payStatus:status
                               msg:payResult.errorDescription];
}

- (void)handleCallbackForChannel:(CXPayChannel)channel
                       payStatus:(CXPayStatus)status
                             msg:(NSString *)msg{
    !self.compoletion ?: self.compoletion(channel, status, msg);
    self.compoletion = NULL;
}

@end
