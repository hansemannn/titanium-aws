/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2017 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiAwsMachineLearningPredictionManagerProxy.h"
#import "TiUtils.h"

@implementation TiAwsMachineLearningPredictionManagerProxy

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
        
        [AWSMachineLearning registerMachineLearningWithConfiguration:configuration forKey:identifier];
        
        predictionManager = [AWSMachineLearning MachineLearningForKey:identifier];
    }
    
    return self;
}

- (void)predict:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    
    // The model ID
    NSString *modelId;
    ENSURE_ARG_FOR_KEY(modelId, args, @"modelId", NSString);
    
    // The callback to be invoked upon error
    KrollCallback *error = nil;
    ENSURE_ARG_OR_NIL_FOR_KEY(error, args, @"error", KrollCallback);

    // The callback to be invoked upon progress
    KrollCallback *progress = nil;
    ENSURE_ARG_OR_NIL_FOR_KEY(progress, args, @"progress", KrollCallback);
    
    // The callback to be invoked upon success
    KrollCallback *success = nil;
    ENSURE_ARG_OR_NIL_FOR_KEY(success, args, @"success", KrollCallback);
    
    AWSMachineLearningGetMLModelInput *getMLModelInput = [AWSMachineLearningGetMLModelInput new];
    [getMLModelInput setMLModelId:modelId];
    
    [[predictionManager getMLModel:getMLModelInput] continueWithSuccessBlock:^id(AWSTask *task) {
        AWSMachineLearningGetMLModelOutput *getMLModelOutput = task.result;
        
        if (task.error) {
            [self handleAWSErrorWithError:task.error andCallback:error];
            return nil;
        }
        
        // Validate that the ML model is completed
        if (getMLModelOutput.status != AWSMachineLearningEntityStatusCompleted) {
            NSDictionary *dict = @{@"status": NUMINTEGER(getMLModelOutput.status),@"lastUpdatedAt": getMLModelOutput.lastUpdatedAt};
            NSArray *invocationArray = [[NSArray alloc] initWithObjects:&dict count:1];
            
            [progress call:invocationArray thisObject:self];

            return nil;
        }
        
        // Validate that the realtime endpoint is ready
        if (getMLModelOutput.endpointInfo.endpointStatus != AWSMachineLearningRealtimeEndpointStatusReady) {
            AWSMachineLearningPredictInput *predictInput = [AWSMachineLearningPredictInput new];
            [predictInput setPredictEndpoint:getMLModelOutput.endpointInfo.endpointUrl];
            [predictInput setMLModelId:modelId];
            
            // Call and return prediction
            AWSTask<AWSMachineLearningPredictOutput *> *predictOutput = [self->predictionManager predict:predictInput];
            
            NSDictionary *dict = @{
                @"url": getMLModelOutput.endpointInfo.endpointUrl,
                @"prediction": [TiAwsMachineLearningPredictionManagerProxy dictionaryFromPredictOutput:predictOutput]
            };
            NSArray *invocationArray = [[NSArray alloc] initWithObjects:&dict count:1];
            
            [success call:invocationArray thisObject:self];
            
            return nil;
        }
        
        return nil;
    }];
}

#pragma mark Utilities

+ (NSDictionary *)dictionaryFromPredictOutput:(AWSTask<AWSMachineLearningPredictOutput *> *)output
{
    return @{
        @"details": output.result.prediction.details,
        @"predictedLabel": output.result.prediction.predictedLabel,
        @"predictedValue": output.result.prediction.predictedValue,
        @"predictedScore": output.result.prediction.predictedScores
    };
}

- (void)handleAWSErrorWithError:(NSError *)error andCallback:(KrollCallback *)callback
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setObject:error.localizedDescription forKey:@"error"];
    [dict setObject:NUMINTEGER(error.code) forKey:@"code"];
    
    NSArray *invocationArray = [[NSArray alloc] initWithObjects:&dict count:1];
    
    [callback call:invocationArray thisObject:self];
}

@end
