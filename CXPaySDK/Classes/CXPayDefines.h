//
//  CXPayDefines.h
//  Pods
//
//  Created by wshaolin on 2018/12/26.
//

#ifndef CXPayDefines_h
#define CXPayDefines_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CXPayChannel){ // 支付渠道
    CXPayChannelAlipay   = 4,  // 支付宝
    CXPayChannelWeChat   = 5,  // 微信
    CXPayChannelUnionPay = 9,  // 银联
    CXPayChannelApplePay = 10  // 苹果支付
};

typedef NS_ENUM(NSInteger, CXPayStatus){ // 支付状态
    CXPayStatusSuccess       = 0, // 支付成功
    CXPayStatusCancel        = 1, // 支付取消
    CXPayStatusFailed        = 2, // 失败
    CXPayStatusCommonError   = 4, // 其他错误
    CXPayStatusNotInstalled  = 5, // 未安装APP（微信）
    CXPayStatusNotSupported  = 6  // 不支持
};

#endif /* CXPayDefines_h */
