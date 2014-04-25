//
//  CRUAnalyticsTracker.m
//  MissionHub
//
//  Created by Michael Harrison on 10/29/13.
//  Copyright (c) 2013 Cru. All rights reserved.
//

#import "CRUAnalyticsTracker.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAITracker.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

NSString * const CRUAnalyticsCategoryUI					= @"ui";
NSString * const CRUAnalyticsCategoryBackgroundProcess	= @"background_process";
NSString * const CRUAnalyticsCategoryButton				= @"button";
NSString * const CRUAnalyticsCategoryCell				= @"cell";
NSString * const CRUAnalyticsCategoryCheckbox			= @"checkbox";
NSString * const CRUAnalyticsCategorySearchbar			= @"searchbar";
NSString * const CRUAnalyticsCategoryList				= @"list";
NSString * const CRUAnalyticsCategoryPopover			= @"popover";
NSString * const CRUAnalyticsCategoryActivityBar		= @"activity_bar";

NSString * const CRUAnalyticsActionTap					= @"tap";
NSString * const CRUAnalyticsActionSwipe				= @"swipe";

@interface CRUAnalyticsTracker ()

@property (nonatomic, strong) id<GAITracker> tracker;

@end

@implementation CRUAnalyticsTracker

+ (instancetype)startTrackingWithTrackingID:(NSString *)trackingID {
	
	return [self sharedAnalyticsTrackerWithTrackingID:trackingID];
}

+ (instancetype)sharedAnalyticsTrackerWithTrackingID:(NSString *)trackingID {
	
	static CRUAnalyticsTracker *sharedInstance;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		
		sharedInstance					= [[CRUAnalyticsTracker alloc] initWithTrackingID:trackingID];
		
	});
	
	return sharedInstance;
	
}

- (id)initWithTrackingID:(NSString *)trackingID {

    self = [super init];
    
	if (self) {
        
		[GAI sharedInstance].trackUncaughtExceptions = YES;
		self.tracker = [[GAI sharedInstance] trackerWithTrackingId:trackingID];
		
    }
	
    return self;
}

- (void)setDevelopmentMode:(BOOL)developmentMode {
	
	if (developmentMode) {
		
		[GAI sharedInstance].dryRun = YES;
		[[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
		
	} else {
		
		[GAI sharedInstance].dryRun = NO;
		[[GAI sharedInstance].logger setLogLevel:kGAILogLevelNone];
		
	}
	
}

- (instancetype)setScreenName:(NSString *)screenName {
	
	NSString *name = ( screenName ? screenName : @"" );
	
	[self.tracker set:kGAIScreenName value:name];
	
	return self;
	
}

- (instancetype)setCustomDimensions:(NSDictionary *)customDimensions {
	
	for (NSNumber *index in customDimensions) {
		
		[self.tracker set:[GAIFields customDimensionForIndex:[index integerValue]] value:customDimensions[index]];
		
	}
	
	return self;
}

- (void)sendScreenView {

	[self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
	
}

- (void)sendEventWithLabel:(NSString *)label {
	
	[self sendEventWithCategory:nil action:nil label:label value:nil];
	
}

- (void)sendEventWithCategory:(NSString *)category label:(NSString *)label {
	
	[self sendEventWithCategory:category action:nil label:label value:nil];
	
}

- (void)sendEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value {
	
	NSString *categoryName	= ( category	? category		: CRUAnalyticsCategoryButton );
	NSString *actionName	= ( action		? action		: CRUAnalyticsActionTap );
	NSString *labelName		= ( label		? label			: @"" );
	NSNumber *number		= ( value		? value			: nil );
	
	[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:categoryName		// Event category (required)
																action:actionName		// Event action (required)
																 label:labelName			// Event label
																 value:number] build]];
	
}

- (void)sendScreenViewWithScreenName:(NSString *)screenName {
	
	NSString *screen		= ( screenName	? screenName	: @"" );
	
	[self.tracker send:[[[GAIDictionaryBuilder createAppView] set:screen forKey:kGAIScreenName] build]];
	
}

- (void)sendEventWithScreenName:(NSString *)screenName label:(NSString *)label {
	
	[self sendEventWithScreenName:nil category:nil action:nil label:label value:nil];
	
}

- (void)sendEventWithScreenName:(NSString *)screenName category:(NSString *)category label:(NSString *)label {
	
	[self sendEventWithScreenName:screenName category:category action:nil label:label value:nil];
	
}

- (void)sendEventWithScreenName:(NSString *)screenName category:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value {
	
	NSString *screen		= ( screenName	? screenName	: @"" );
	NSString *categoryName	= ( category	? category		: CRUAnalyticsCategoryButton );
	NSString *actionName	= ( action		? action		: CRUAnalyticsActionTap );
	NSString *labelName		= ( label		? label			: @"" );
	NSNumber *number		= ( value		? value			: nil );
	
	[self.tracker send:[[[GAIDictionaryBuilder createEventWithCategory:categoryName		// Event category (required)
															   action:actionName		// Event action (required)
																label:labelName			// Event label
																 value:number]			// Event value
												set:screen forKey:kGAIScreenName]		// Screen Name Event was triggered on
												build]];
	
}

@end
