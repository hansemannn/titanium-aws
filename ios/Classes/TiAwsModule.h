/**
 * titanium-amazon-aws
 *
 * Created by Hans Knoechel
 * Copyright (c) 2017 Your Company. All rights reserved.
 */

#import "TiModule.h"

@interface TiAwsModule : TiModule {

}

- (void)setDefaultConfiguration:(id)args;

- (void)setLogLevel:(id)value;

- (void)log:(id)args;

@end
