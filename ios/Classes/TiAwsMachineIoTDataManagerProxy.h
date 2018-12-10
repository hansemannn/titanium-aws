/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2017 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import <AWSIoT/AWSIoT.h>

typedef enum TiAWSConnectionType: NSUInteger {
    TiAWSConnectionTypeUnknown = 0,
    TiAWSConnectionTypeSocket,
    TiAWSConnectionTypeCertificate
} TiAWSConnectionType;

@interface TiAwsMachineIoTDataManagerProxy : TiProxy {
    AWSIoTDataManager *IoTManager;
}

- (id)_initWithPageContext:(id<TiEvaluator>)context andProperties:(NSDictionary *)properties;

/**
 Creates new keys and certificate for a given CSV.
 
 @param args The arguments passed to the certificate request.
 @since 1.0.0
 
 */
- (void)connect:(id)args;

- (void)disconnect:(id)unused;

- (void)publishData:(id)args;

- (void)publishString:(id)args;

- (void)subscribeToTopic:(id)args;

- (void)subscribeToTopicExtended:(id)args;

- (void)unsubscribeTopic:(id)value;

@end
