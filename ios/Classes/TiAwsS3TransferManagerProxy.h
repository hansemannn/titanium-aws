/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2017 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import <AWSS3/AWSS3.h>

@interface TiAwsS3TransferManagerProxy : TiProxy

/**
 Download a file from S3.
 
 @param args The arguments passed to the download request.
 @since 1.0.0
 
 */
- (void)download:(id)args;

/**
 Upload a file to S3.
 
 @param args The arguments passed to the upload request.
 @since 1.0.0
 
 */
- (void)upload:(id)args;

/**
 Cancel all pending upload- and download-requests.
 
 @param unused An unused parameter for proxy-generation.
 @since 1.0.0
 
 */
- (void)cancelAll:(id)unused;

/**
 Pause all pending upload- and download-requests.
 
 @param unused An unused parameter for proxy-generation.
 @since 1.0.0
 
 */
- (void)pauseAll:(id)unused;

/**
 Resume all pending upload- and download-requests.
 
 @param args The arguments passed to the download request
 @since 1.0.0
 
 */
- (void)resumeAll:(id)value;

/**
 Clear the S3 file-cache.
 
 @param unused An unused parameter for proxy-generation.
 @since 1.0.0
 
 */
- (void)clearCache:(id)unused;

@end
