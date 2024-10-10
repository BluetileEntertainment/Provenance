//
//  PVMelonDSCore.h
//  PVMelonDS
//
//  Created by Joseph Mattiello on 4/6/18.
//  Copyright © 2018 Provenance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PVCoreBridgeRetro/PVCoreBridgeRetro.h>
#import <PVCoreObjCBridge/PVCoreObjCBridge.h>

@protocol PVDSSystemResponderClient;

#define GET_CURRENT_AND_RETURN(...) __strong __typeof__(_current) current = _current; if(current == nil) return __VA_ARGS__;
#define GET_CURRENT_OR_RETURN(...)  __strong __typeof__(_current) current = _current; if(current == nil) return __VA_ARGS__;

__attribute__((visibility("default")))
@interface PVMelonDSCoreBridge : PVLibRetroCoreBridge <PVDSSystemResponderClient>
{
@public
    dispatch_queue_t _callbackQueue;
}

@end
