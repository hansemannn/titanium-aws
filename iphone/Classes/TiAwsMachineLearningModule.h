/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2017 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiModule.h"

@class TiAwsMachineLearningPredictionManagerProxy;

@interface TiAwsMachineLearningModule : TiModule {

}

- (TiAwsMachineLearningPredictionManagerProxy *)createPredictionManager:(id)args;

@end
