/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2017 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiAwsMachineIoTModule.h"
#import "TiAwsMachineIoTDataManagerProxy.h"

@implementation TiAwsMachineIoTModule

- (TiAwsMachineIoTDataManagerProxy *)createPredictionManager:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    return [[TiAwsMachineIoTDataManagerProxy alloc] _initWithPageContext:[self pageContext] andProperties:args];
}

@end
