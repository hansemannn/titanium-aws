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


@end
