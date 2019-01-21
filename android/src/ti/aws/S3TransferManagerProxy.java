/**
 * Titanium AWS
 * Copyright (c) 2018-present by Hans Knöchel, Inc. All Rights Reserved.
 * Licensed under the terms of the MIT License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package ti.aws;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.KrollObject;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiC;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.kroll.common.TiConfig;
import org.appcelerator.titanium.TiApplication;

import android.content.Context;
import android.app.Activity;
import android.net.Uri;

import java.io.File;

import com.amazonaws.mobile.client.AWSMobileClient;
import com.amazonaws.mobile.client.AWSStartupResult;
import com.amazonaws.mobile.client.AWSStartupHandler;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferListener;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferState;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferUtility;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferObserver;
import com.amazonaws.services.s3.AmazonS3Client;

import com.amazonaws.regions.Regions;
import com.amazonaws.auth.CognitoCachingCredentialsProvider;
import com.amazonaws.regions.Region;

@Kroll.proxy(creatableInModule=TitaniumAmazonAwsModule.class)
public class S3TransferManagerProxy extends KrollProxy
{
	// Standard Debugging variables
	private static final String LCAT = "TiS3TransferManager";
	private static final boolean DBG = TiConfig.LOGD;

	private CognitoCachingCredentialsProvider credentialsProvider;

	// Methods
	@Kroll.method
	public void upload(KrollDict params)
	{
		if (credentialsProvider == null) {
			Log.e(LCAT, "Missing credentials provider! Please use 'configure(args)' before.");
			return;
		}

		final String file = params.getString("file");
		final String bucket = params.getString("bucket");
		final String key = params.getString("key");

		final KrollFunction success = (KrollFunction)params.get("success");
		final KrollFunction error = (KrollFunction)params.get("error");

		Context appContext = TiApplication.getInstance();
		if (appContext == null) return;

		AmazonS3Client s3Client = new AmazonS3Client(credentialsProvider);
		s3Client.setRegion(Region.getRegion(Regions.fromName("eu-central-1")));

		TransferUtility transferUtility =
				TransferUtility.builder()
						.context(appContext)
						.awsConfiguration(AWSMobileClient.getInstance().getConfiguration())
						.s3Client(new AmazonS3Client(AWSMobileClient.getInstance().getCredentialsProvider()))
						.build();

		
		File nativeFile = new File(Uri.parse(file).getPath());
		
		TransferObserver uploadObserver = transferUtility.upload(key, nativeFile);
		
		uploadObserver.setTransferListener(new TransferListener() {
			@Override
			public void onStateChanged(int id, TransferState state) {
				KrollObject krollObject = getKrollObject();
				if (krollObject == null) {
					return;
				}
				
				if (TransferState.COMPLETED == state) {
					KrollDict event = new KrollDict();
					event.put("body", key);

					success.callAsync(krollObject, event);
				}
			}
			
			@Override
			public void onProgressChanged(int id, long bytesCurrent, long bytesTotal) {}
			
			@Override
			public void onError(int id, Exception ex) {
				KrollObject krollObject = getKrollObject();
				if (krollObject == null) {
					return;
				}

				KrollDict event = new KrollDict();
				event.put("error", ex.getMessage());

				error.callAsync(krollObject, event);
			}
		});
	}

	@Kroll.method
	public void configure(KrollDict config) {
		String region = config.getString("region");
		String poolId = config.getString("poolId");
		Context appContext = TiApplication.getInstance();

		if (appContext == null) {
			Log.e(LCAT, "Application context is null!");
			return;
		}

		AWSMobileClient.getInstance().initialize(TiApplication.getInstance().getCurrentActivity()).execute();
		credentialsProvider = new CognitoCachingCredentialsProvider(appContext, poolId, Regions.fromName(region));
	}
}
