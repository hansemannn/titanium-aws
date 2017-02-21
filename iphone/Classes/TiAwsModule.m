/**
 * titanium-amazon-aws
 *
 * Created by Hans Knoechel
 * Copyright (c) 2017 Your Company. All rights reserved.
 */

#import "TiAwsModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import <AWSCore/AWSCore.h>

@implementation TiAwsModule

#pragma mark Internal

- (id)moduleGUID
{
	return @"73bc1782-8697-4dbb-88f9-f0231280ce02";
}

- (NSString *)moduleId
{
	return @"ti.aws";
}

#pragma mark Lifecycle

- (void)startup
{
	[super startup];

	NSLog(@"[DEBUG] %@ loaded",self);
}

#pragma Public APIs

- (void)setDefaultConfiguration:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    AWSRegionType region = [TiUtils intValue:[args objectForKey:@"region"] def:AWSRegionUnknown];
    NSString *poolId = [TiUtils stringValue:[args objectForKey:@"poolId"]];
    
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:region
                                                          identityPoolId:poolId];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:region
                                                                         credentialsProvider:credentialsProvider];
    
    [[AWSServiceManager defaultServiceManager] setDefaultServiceConfiguration:configuration];
}

- (void)setLogLevel:(id)value
{
    ENSURE_TYPE(value, NSNumber);
    [[AWSLogger defaultLogger] setLogLevel:[TiUtils intValue:value def:AWSLogLevelDebug]];
}

- (void)log:(id)args
{
    ENSURE_ARG_COUNT(args, 2);
    
    id level = [args objectAtIndex:0];
    id message = [args objectAtIndex:1];
    
    [[AWSLogger defaultLogger] log:[TiUtils intValue:level def:AWSLogLevelDebug]
                            format:@"%@", message];
}

@end
