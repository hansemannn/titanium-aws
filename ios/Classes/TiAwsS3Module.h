/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2017 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiModule.h"

@class TiAwsS3TransferManagerProxy;

@interface TiAwsS3Module : TiModule {

}

- (TiAwsS3TransferManagerProxy *)createTransferManager:(id)args;

@end
