/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2017 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiAwsS3Module.h"
#import "TiAwsS3TransferManagerProxy.h"

@implementation TiAwsS3Module

- (TiAwsS3TransferManagerProxy *)createTransferManager:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    return [[TiAwsS3TransferManagerProxy alloc] _initWithPageContext:[self pageContext]];
}

@end
