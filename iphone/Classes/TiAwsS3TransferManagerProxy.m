/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2017 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiAwsS3TransferManagerProxy.h"
#import "TiUtils.h"

@implementation TiAwsS3TransferManagerProxy

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
        
        [AWSS3TransferManager registerS3TransferManagerWithConfiguration:configuration forKey:identifier];
        
        transferManager = [AWSS3TransferManager S3TransferManagerForKey:identifier];
 }
    
    return self;
}

- (void)download:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    // Name of the downloaded file
    NSString *file;
    ENSURE_ARG_FOR_KEY(file, args, @"file", NSString);
    
    // Name of the bucket
    NSString *bucket;
    ENSURE_ARG_FOR_KEY(bucket, args, @"bucket", NSString);
    
    // Name of the file key (optional - falls back to the filename if not specified)
    NSString *key;
    ENSURE_ARG_OR_NIL_FOR_KEY(key, args, @"key", NSString);
    
    // The callback to be invoked upon error
    KrollCallback *error = nil;
    ENSURE_ARG_OR_NIL_FOR_KEY(error, args, @"error", KrollCallback);
    
    // The callback to be invoked upon success
    KrollCallback *success = nil;
    ENSURE_ARG_OR_NIL_FOR_KEY(success, args, @"success", KrollCallback);    
    
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    
    [downloadRequest setBucket:bucket];
    [downloadRequest setKey:key ?: file];
    [downloadRequest setDownloadingFileURL:[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:file]]];
    
    [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                           withBlock:^id(AWSTask *task) {
                                                               if (task.error) {
                                                                   [self handleAWSErrorWithTask:task andCallback:error];
                                                               }
                                                               
                                                               if (task.result) {
                                                                   AWSS3TransferManagerDownloadOutput *downloadOutput = task.result;
                                                                   NSDictionary *dict = @{@"body": downloadOutput.body}; // TODO: Expose whole response
                                                                   NSArray *invocationArray = [[NSArray alloc] initWithObjects:&dict count:1];
                                                                   
                                                                   [success call:invocationArray thisObject:self];
                                                               }
                                                               
                                                               return nil;
                                                           }];
}

- (void)upload:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    // Name of the downloaded file
    NSString *file;
    ENSURE_ARG_FOR_KEY(file, args, @"file", NSString);
    
    // Name of the bucket
    NSString *bucket;
    ENSURE_ARG_FOR_KEY(bucket, args, @"bucket", NSString);
    
    // Name of the file key (optional - falls back to the filename if not specified)
    NSString *key;
    ENSURE_ARG_OR_NIL_FOR_KEY(key, args, @"key", NSString);
    
    // The callback to be invoked upon error
    KrollCallback *error = nil;
    ENSURE_ARG_OR_NIL_FOR_KEY(error, args, @"error", KrollCallback);
    
    // The callback to be invoked upon success
    KrollCallback *success = nil;
    ENSURE_ARG_OR_NIL_FOR_KEY(success, args, @"success", KrollCallback);
    
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    
    [uploadRequest setBucket:bucket];
    [uploadRequest setKey:key];
    [uploadRequest setBody:[TiUtils toURL:file proxy:self]];
    
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                           withBlock:^id(AWSTask *task) {
                                                               if (task.error) {
                                                                   [self handleAWSErrorWithTask:task andCallback:error];
                                                               }
                                                               
                                                               if (task.result) {
                                                                   AWSS3TransferManagerDownloadOutput *uploadOutput = task.result;
                                                                   NSDictionary *dict = @{@"body": uploadOutput.body}; // TODO: Expose whole response
                                                                   NSArray *invocationArray = [[NSArray alloc] initWithObjects:&dict count:1];
                                                                   
                                                                   [success call:invocationArray thisObject:self];
                                                               }
                                                               
                                                               return nil;
                                                           }];
}

- (void)cancelAll:(id)unused
{
    [transferManager cancelAll];
}

- (void)pauseAll:(id)unused
{
    [transferManager pauseAll];
}

- (void)resumeAll:(id)value
{
    ENSURE_SINGLE_ARG_OR_NIL(value, KrollCallback);
    
    [transferManager resumeAll:^(AWSRequest *request) {
        if (value != nil) {
            NSDictionary *dict = @{};
            NSArray *invocationArray = [[NSArray alloc] initWithObjects:&dict count:1];
            
            [value call:invocationArray thisObject:self];
        }
    }];
}

- (void)clearCache:(id)unused
{
    [transferManager clearCache];
}

#pragma mark Utilities

- (void)handleAWSErrorWithTask:(AWSTask *)task andCallback:(KrollCallback *)callback
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setObject:task.error.localizedDescription forKey:@"error"];
    [dict setObject:NUMINTEGER(task.error.code) forKey:@"code"];
    
    NSArray *invocationArray = [[NSArray alloc] initWithObjects:&dict count:1];
    
    [callback call:invocationArray thisObject:self];
}

@end
