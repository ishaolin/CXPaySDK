//
//  CXPayOrderParamsModel.m
//  Pods
//
//  Created by wshaolin on 2017/5/28.
//
//

#import "CXPayOrderParamsModel.h"
#import <CXFoundation/CXFoundation.h>

@implementation CXPayOrderParamsModel

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)dictionary{
    if(!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    
    if(self = [super init]){
        _unionPayEnvMode = @"00";
        _payChannel = [dictionary cx_numberForKey:@"currentPayChannel"].integerValue;
        _transactionId = [dictionary cx_stringForKey:@"transactionId"];
        
        NSDictionary<NSString *, id> *payParam = [dictionary cx_dictionaryForKey:@"payParam"];
        if(!payParam){
            payParam = [NSJSONSerialization cx_deserializeJSONToDictionary:[dictionary cx_stringForKey:@"payParam"]];
        }
        
        if(_payChannel == CXPayChannelAlipay){
            _payStr = [payParam cx_stringForKey:@"alipayStr"];
        }else if(_payChannel == CXPayChannelUnionPay){
            _payStr = [payParam cx_stringForKey:@"tn"];
        }else if(_payChannel == CXPayChannelWeChat){
            _weChatParams = [[CXWeChatPayParamsModel alloc] initWithDictionary:payParam];
        }else if(_payChannel == CXPayChannelApplePay){
            _mechantId = [payParam cx_stringForKey:@"merchantId"];
            _payStr = [payParam cx_stringForKey:@"tn"];
        }
    }
    
    return self;
}

- (BOOL)isValidParams{
    switch (_payChannel) {
        case CXPayChannelWeChat:{
            return [_weChatParams isValidParams];
        }
        case CXPayChannelAlipay:{
            return !CXStringIsEmpty(_payStr);
        }
        case CXPayChannelUnionPay:{
            if(CXStringIsEmpty(_payStr)){
                return NO;
            }
            
            return !CXStringIsEmpty(_unionPayEnvMode);
        }
        case CXPayChannelApplePay:{
            if(CXStringIsEmpty(_payStr)){
                return NO;
            }
            
            if(CXStringIsEmpty(_unionPayEnvMode)){
                return NO;
            }
            
            return !CXStringIsEmpty(_mechantId);
        }
        default:
            return NO;
    }
}

@end

@implementation CXWeChatPayParamsModel

- (instancetype)initWithDictionary:(NSDictionary<NSString *,id> *)dictionary{
    if(!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    
    if(self = [super init]){
        _appId = [dictionary cx_stringForKey:@"appid"];
        _partnerId = [dictionary cx_stringForKey:@"parternId"];
        _prepayId = [dictionary cx_stringForKey:@"prepayId"];
        _nonceStr = [dictionary cx_stringForKey:@"nonceStr"];
        _package = [dictionary cx_stringForKey:@"pack"];
        _sign = [dictionary cx_stringForKey:@"sign"];
        _timeStamp = [dictionary cx_numberForKey:@"timestamp"].unsignedLongLongValue;
    }
    
    return self;
}

- (BOOL)isValidParams{
    if(CXStringIsEmpty(_appId)){
        return NO;
    }
    
    if(CXStringIsEmpty(_partnerId)){
        return NO;
    }
    
    if(CXStringIsEmpty(_prepayId)){
        return NO;
    }
    
    if(CXStringIsEmpty(_nonceStr)){
        return NO;
    }
    
    if(CXStringIsEmpty(_package)){
        return NO;
    }
    
    if(CXStringIsEmpty(_sign)){
        return NO;
    }
    
    return _timeStamp > 0;
}

@end
