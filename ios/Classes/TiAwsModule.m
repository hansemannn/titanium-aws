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

- (void)setLogLevel:(NSNumber *)value
{
  [[AWSDDLog sharedInstance] setLogLevel:value.intValue];
}

- (void)log:(id)args
{
    ENSURE_ARG_COUNT(args, 2);
    
    id level = [args objectAtIndex:0];
    id message = [args objectAtIndex:1];
  
  [[AWSDDLog sharedInstance] log:YES message:message];
}

MAKE_SYSTEM_PROP(LOG_LEVEL_OFF, AWSDDLogLevelOff);
MAKE_SYSTEM_PROP(LOG_LEVEL_WARNING, AWSDDLogLevelWarning);
MAKE_SYSTEM_PROP(LOG_LEVEL_INFO, AWSDDLogLevelInfo);
MAKE_SYSTEM_PROP(LOG_LEVEL_DEBUG, AWSDDLogLevelDebug);
MAKE_SYSTEM_PROP(LOG_LEVEL_VERBOSE, AWSDDLogLevelVerbose);

MAKE_SYSTEM_PROP(REGION_UNKNOWN, AWSRegionUnknown);
MAKE_SYSTEM_PROP(REGION_US_EAST_1, AWSRegionUSEast1);
MAKE_SYSTEM_PROP(REGION_US_EAST_2, AWSRegionUSEast2);
MAKE_SYSTEM_PROP(REGION_US_WEST_1, AWSRegionUSWest1);
MAKE_SYSTEM_PROP(REGION_US_WEST_2, AWSRegionUSWest2);
MAKE_SYSTEM_PROP(REGION_EU_WEST_1, AWSRegionEUWest1);
MAKE_SYSTEM_PROP(REGION_EU_WEST_2, AWSRegionEUWest2);
MAKE_SYSTEM_PROP(REGION_EU_WEST_3, AWSRegionEUWest3);
MAKE_SYSTEM_PROP(REGION_EU_CENTRAL_1, AWSRegionEUCentral1);

@end
