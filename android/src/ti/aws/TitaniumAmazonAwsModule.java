/**
 * Titanium AWS
 * Copyright (c) 2018-present by Hans Knöchel, Inc. All Rights Reserved.
 * Licensed under the terms of the MIT License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package ti.aws;

import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.annotations.Kroll;

import org.appcelerator.titanium.TiApplication;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.kroll.common.TiConfig;

@Kroll.module(name="TitaniumAmazonAws", id="ti.aws")
public class TitaniumAmazonAwsModule extends KrollModule
{
	private static final String LCAT = "TitaniumAmazonAwsModule";
	private static final boolean DBG = TiConfig.LOGD;

	@Kroll.constant
	public static final String REGION_UNKNOWN = "unknown";
	@Kroll.constant
	public static final String REGION_US_EAST_1 = "us-east-1";
	@Kroll.constant
	public static final String REGION_US_EAST_2 = "us-east-2";
	@Kroll.constant
	public static final String REGION_US_WEST_1 = "us-west-1";
	@Kroll.constant
	public static final String REGION_US_WEST_2 = "us-west-2";
	@Kroll.constant
	public static final String REGION_EU_WEST_1 = "eu-west-1";
	@Kroll.constant
	public static final String REGION_EU_WEST_2 = "eu-west-2";
	@Kroll.constant
	public static final String REGION_EU_WEST_3 = "eu-west-3";
	@Kroll.constant
	public static final String REGION_EU_CENTRAL_1 = "eu-central-1";
}
