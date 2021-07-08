//
//  CXPayOrderParamsModel.h
//  Pods
//
//  Created by wshaolin on 2017/5/28.
//
//

#import "CXPayDefines.h"

NS_ASSUME_NONNULL_BEGIN

@class CXWeChatPayParamsModel;

@interface CXPayOrderParamsModel : NSObject

@property (nonatomic, assign, readonly) CXPayChannel payChannel;
@property (nonatomic, copy, readonly) NSString *payStr;
@property (nonatomic, strong, readonly) CXWeChatPayParamsModel *weChatParams;
@property (nonatomic, copy, readonly) NSString *transactionId; // 交易系统支付流水订单号
@property (nonatomic, copy) NSString *unionPayEnvMode; // 银联支付环境参数：00 生产环境，01 测试环境
@property (nonatomic, copy) NSString *mechantId; // 苹果公司分配的商户号，Apple Pay需要

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> * _Nonnull)dictionary;

- (BOOL)isValidParams;

@end

@interface CXWeChatPayParamsModel : NSObject

@property (nonatomic, copy, readonly) NSString *appId;
@property (nonatomic, copy, readonly) NSString *partnerId;
@property (nonatomic, copy, readonly) NSString *prepayId;
@property (nonatomic, copy, readonly) NSString *nonceStr;
@property (nonatomic, copy, readonly) NSString *package;
@property (nonatomic, copy, readonly) NSString *sign;
@property (nonatomic, assign, readonly) uint64_t timeStamp;

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> * _Nonnull)dictionary;

- (BOOL)isValidParams;

@end

NS_ASSUME_NONNULL_END
