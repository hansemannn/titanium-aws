/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2017 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiAwsMachineIoTDataManagerProxy.h"
#import "TiUtils.h"

@implementation TiAwsMachineIoTDataManagerProxy

- (id)_initWithPageContext:(id<TiEvaluator>)context andProperties:(NSDictionary *)properties
{
    if (self = [super _initWithPageContext:context]) {
        AWSRegionType region = [TiUtils intValue:[properties objectForKey:@"region"] def:AWSRegionUnknown];
        NSString *poolId = [TiUtils stringValue:[properties objectForKey:@"poolId"]];
        NSString *identifier = [TiUtils stringValue:[properties objectForKey:@"identifier"]];
        
        AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:region
                                                                                                        identityPoolId:poolId];
        
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2
                                                                             credentialsProvider:credentialsProvider];
        
        [AWSIoTDataManager registerIoTDataManagerWithConfiguration:configuration forKey:identifier];
        
        IoTManager = [AWSIoTDataManager IoTDataManagerForKey:identifier];
    }
    
    return self;
}

- (void)connect:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    
    id clientId = [TiUtils stringValue:[args objectForKey:@"clientId"]];
    BOOL cleanSession = [TiUtils boolValue:[args objectForKey:@"cleanSession"] def:NO];
    id certificateId = [args objectForKey:@"certificateId"];
    id callback = [args objectForKey:@"callback"];
    TiAWSConnectionType connectionType = [TiUtils intValue:[args objectForKey:@"connectionType"] def:TiAWSConnectionTypeUnknown];
    
    ENSURE_TYPE(callback, KrollCallback);
    ENSURE_TYPE(clientId, NSString);

    void(^statusCallback)(AWSIoTMQTTStatus) = ^(AWSIoTMQTTStatus status) {
        NSDictionary *dict = @{@"status": NUMINTEGER(status)};
        NSArray *invocationArray = [[NSArray alloc] initWithObjects:&dict count:1];
        
        [callback call:invocationArray thisObject:self];
    };
    
    if (connectionType == TiAWSConnectionTypeSocket) {
        [IoTManager connectUsingWebSocketWithClientId:clientId
                                         cleanSession:cleanSession
                                       statusCallback:statusCallback];
    } else if(connectionType == TiAWSConnectionTypeCertificate) {
        [IoTManager connectWithClientId:clientId
                           cleanSession:cleanSession
                          certificateId:certificateId
                         statusCallback:statusCallback];
    } else {
        NSLog(@"[ERROR] No 'connectionType specified, aborting ...'");
    }
}

- (void)disconnect:(id)unused
{
    [IoTManager disconnect];
}

- (void)publishData:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    id data = [args objectForKey:@"data"];
    ENSURE_TYPE(data, TiBlob);
    
    id topic = [args objectForKey:@"topic"];
    ENSURE_TYPE(topic, NSString);
    
    id qos = [args objectForKey:@"qos"];
    ENSURE_TYPE(qos, NSNumber);
    
    [IoTManager publishData:[(TiBlob *)data data]
                    onTopic:topic
                        QoS:[TiUtils intValue:qos def:AWSIoTMQTTQoSMessageDeliveryAttemptedAtMostOnce]];
}

- (void)publishString:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    id str = [args objectForKey:@"string"];
    ENSURE_TYPE(str, NSString);
    
    id topic = [args objectForKey:@"topic"];
    ENSURE_TYPE(topic, NSString);
    
    id qos = [args objectForKey:@"qos"];
    ENSURE_TYPE(qos, NSNumber);
    
    [IoTManager publishString:str
                      onTopic:topic
                          QoS:[TiUtils intValue:qos def:AWSIoTMQTTQoSMessageDeliveryAttemptedAtMostOnce]];
}

- (void)subscribeToTopic:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    id topic = [args objectForKey:@"topic"];
    ENSURE_TYPE(topic, NSString);
    
    id qos = [args objectForKey:@"qos"];
    ENSURE_TYPE(qos, NSNumber);
    
    id callback = [args objectForKey:@"callback"];
    ENSURE_TYPE(callback, KrollCallback);
    
    [IoTManager subscribeToTopic:topic
                             QoS:[TiUtils intValue:qos def:AWSIoTMQTTQoSMessageDeliveryAttemptedAtMostOnce]
                 messageCallback:^(NSData *data) {
                     NSDictionary *dict = @{@"data": [[TiBlob alloc] _initWithPageContext:[self pageContext]
                                                                                  andData:data
                                                                                 mimetype:@"text/plain"]}; // FIXME: Is this the right mime-type?
                     NSArray *invocationArray = [[NSArray alloc] initWithObjects:&dict count:1];
                     
                     [callback call:invocationArray thisObject:self];
                 }];
}

- (void)subscribeToTopicExtended:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    id topic = [args objectForKey:@"topic"];
    ENSURE_TYPE(topic, NSString);
    
    id qos = [args objectForKey:@"qos"];
    ENSURE_TYPE(qos, NSNumber);
    
    id callback = [args objectForKey:@"callback"];
    ENSURE_TYPE(callback, KrollCallback);
    
    [IoTManager subscribeToTopic:topic
                             QoS:[TiUtils intValue:qos def:AWSIoTMQTTQoSMessageDeliveryAttemptedAtMostOnce]
                 extendedCallback:^(NSObject *mqttClient, NSString *topic, NSData *data) {
                     NSDictionary *dict = @{
                        @"data": [[TiBlob alloc] _initWithPageContext:[self pageContext]
                                                          andData:data
                                                         mimetype:@"text/plain"], // FIXME: Is this the right mime-type?
                        @"topic": topic
                        };
                     NSArray *invocationArray = [[NSArray alloc] initWithObjects:&dict count:1];
                     
                     [callback call:invocationArray thisObject:self];
                 }];
}

- (void)unsubscribeTopic:(id)value
{
    ENSURE_SINGLE_ARG(value, NSString);
    [IoTManager unsubscribeTopic:value];
}

@end
