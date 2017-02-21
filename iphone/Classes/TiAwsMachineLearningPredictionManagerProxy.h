/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2017 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import <AWSMachineLearning/AWSMachineLearning.h>

@interface TiAwsMachineLearningPredictionManagerProxy : TiProxy {
    AWSMachineLearning *predictionManager;
}

- (id)_initWithPageContext:(id<TiEvaluator>)context andProperties:(NSDictionary *)properties;

/**
 Predicts a new model value.
 
 @param args The arguments passed to the prediction request.
 @since 1.0.0
 
 */
- (void)predict:(id)args;

@end
