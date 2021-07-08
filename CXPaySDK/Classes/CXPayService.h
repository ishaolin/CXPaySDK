//
//  CXPayService.h
//  Pods
//
//  Created by wshaolin on 2017/5/28.
//
//

#import "CXPayDefines.h"

@class CXPayOrderParamsModel;
@class PayResp;
@class UIViewController;

NS_ASSUME_NONNULL_BEGIN

typedef void(^CXPayServiceCompoletionBlock)(CXPayChannel channel,
                                            CXPayStatus status,
                                            NSString * _Nullable msg);

@interface CXPayService : NSObject

+ (BOOL)canMakePayments; // 是否支持苹果支付

+ (BOOL)canMakePaymentsUsingChinaUnionPay; // 是否支持苹果支付（银联）

@property (nonatomic, copy) NSString *weChatUniversalLink; // 微信通用连接

+ (instancetype)defaultService;

- (void)payOrder:(CXPayOrderParamsModel *)order
          scheme:(NSString *)scheme
  viewController:(UIViewController * _Nullable)viewController
     compoletion:(CXPayServiceCompoletionBlock _Nullable)compoletion;

- (void)handleAlipayOpenURL:(NSURL *)url;
- (void)handleUnionPayOpenURL:(NSURL *)url;
- (void)handleWeChatPayCallback:(PayResp *)payResp;

@end

NS_ASSUME_NONNULL_END
