//
//  GTAnalyticsTracker.m
//  Snuffy
//
//  Created by Michael Harrison on 4/1/14.
//
//

#import "GTTracker.h"
#import "GTConfig.h"
#import "CRUAnalyticsTracker.h"
#import "NewRelic.h"
#import "ABNotifier.h"
#import "TransformerKit.h"

/**
 *  Notification names
 */
NSString *const GTTrackerNotificationResourceDidOpen								= @"org.cru.godtools.gttracker.notification.name.resource-did-open";
NSString *const GTTrackerNotificationUserDidShareResource							= @"org.cru.godtools.gttracker.notification.name.user-did-share-resource";
NSString *const GTTrackerNotificationEverystudentDidSearch							= @"org.cru.godtools.gttracker.notification.name.everystudent-did-search";
NSString *const GTTrackerNotificationEverystudentDidOpenArticle						= @"org.cru.godtools.gttracker.notification.name.everystudent-did-open-article";

/**
 *  UserInfo Keys
 */
NSString *const GTTrackerNotificationUserInfoLanguageKey							= @"org.cru.godtools.gttracker.notification.userinfo.language";
NSString *const GTTrackerNotificationUserInfoPackageKey								= @"org.cru.godtools.gttracker.notification.userinfo.package";
NSString *const GTTrackerNotificationUserInfoVersionKey								= @"org.cru.godtools.gttracker.notification.userinfo.version";
NSString *const GTTrackerNotificationEverystudentDidSearchUserInfoSearchTerm		= @"org.cru.godtools.gttracker.notification.name.everystudent-did-search.userinfo.search-term";
NSString *const GTTrackerNotificationEverystudentDidOpenArticleUserInfoArticleName	= @"org.cru.godtools.gttracker.notification.name.everystudent-did-open-article.userinfo.article-code";

/**
 *  Analytics Event Names
 */
NSString *const GTTrackerEventNameForUserDidShareResource							= @"share-button";

/**
 *  Custom Dimension Indices
 */
NSInteger const GTTrackerCustomDimensionIndexForPackage								= 1;
NSInteger const GTTrackerCustomDimensionIndexForLanguage							= 2;
NSInteger const GTTrackerCustomDimensionIndexForVersion								= 3;


@interface GTTracker ()

@property (nonatomic, strong) GTConfig				*config;
@property (nonatomic, strong) CRUAnalyticsTracker	*analyticsTracker;

- (void)registerNotificationHandlers;
- (NSString *)screenNameFromNotification:(NSNotification *)notification;

- (void)userDidShareResourceHandlerForNotification:(NSNotification *)notification;
- (void)resourceDidOpenHandlerForNotification:(NSNotification *)notification;
- (void)everystudentDidSearchHandlerForNotification:(NSNotification *)notification;
- (void)everystudentDidOpenArticleHandlerForNotification:(NSNotification *)notification;

@end

@implementation GTTracker

+ (instancetype)sharedTracker {
	
    static GTTracker *_sharedTracker = nil;
    static dispatch_once_t onceToken;
	
    dispatch_once(&onceToken, ^{
		
        _sharedTracker = [[GTTracker alloc] initWithConfig:[GTConfig sharedConfig]];
		
    });
    
    return _sharedTracker;
}

- (instancetype)initWithConfig:(GTConfig *)config {
	
	self = [super init];
	
    if (self) {
        
		self.config	= config;
		
    }
	
    return self;
	
}

- (void)startTracking {
	
	//start error tracking
	[ABNotifier startNotifierWithAPIKey:self.config.apiKeyForErrbit
						environmentName:ABNotifierAutomaticEnvironment
								 useSSL:YES
							   delegate:nil];
	
	//start performance tracking
	[NewRelicAgent startWithApplicationToken:self.config.apiKeyForNewRelic];
	
	//start analytics tracking
	self.analyticsTracker	= [CRUAnalyticsTracker startTrackingWithTrackingID:self.config.apiKeyForGoogleAnalytics];
	
	[self registerNotificationHandlers];
	
}

- (void)registerNotificationHandlers {
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(userDidShareResourceHandlerForNotification:)
												 name:GTTrackerNotificationUserDidShareResource
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(resourceDidOpenHandlerForNotification:)
												 name:GTTrackerNotificationResourceDidOpen
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(everystudentDidSearchHandlerForNotification:)
												 name:GTTrackerNotificationEverystudentDidSearch
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(everystudentDidOpenArticleHandlerForNotification:)
												 name:GTTrackerNotificationEverystudentDidOpenArticle
											   object:nil];
	
}

- (void)removeNotificationHandlers {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GTTrackerNotificationUserDidShareResource object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GTTrackerNotificationResourceDidOpen object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GTTrackerNotificationEverystudentDidSearch object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GTTrackerNotificationEverystudentDidOpenArticle object:nil];
	
}

- (NSString *)screenNameFromNotification:(NSNotification *)notification {
	
	NSString *packageCode	= ( notification.userInfo[GTTrackerNotificationUserInfoPackageKey]	? : @"" );
	
	return packageCode;
}

- (NSDictionary *)customDimensionsForNotification:(NSNotification *)notification {

	NSString *languageCode			= ( notification.userInfo[GTTrackerNotificationUserInfoLanguageKey]	? : nil );
	NSString *packageCode			= ( notification.userInfo[GTTrackerNotificationUserInfoPackageKey]	? : nil );
	NSNumber *versionNumber			= ( notification.userInfo[GTTrackerNotificationUserInfoVersionKey]	? : nil );
	NSMutableDictionary *dimensions	= [NSMutableDictionary dictionary];
	
	if (languageCode) {
		dimensions[@(GTTrackerCustomDimensionIndexForLanguage)]	= languageCode;
	}
	
	if (packageCode) {
		dimensions[@(GTTrackerCustomDimensionIndexForPackage)]	= packageCode;
	}
	
	if (languageCode && packageCode && versionNumber) {
		dimensions[@(GTTrackerCustomDimensionIndexForVersion)]	= [NSString stringWithFormat:@"%@-%@-%@", languageCode, packageCode, versionNumber];;
	}
	
	return dimensions;
}

- (void)userDidShareResourceHandlerForNotification:(NSNotification *)notification {
	
	NSString *screenName	= [self screenNameFromNotification:notification];
	NSDictionary *dimensions= [self customDimensionsForNotification:notification];
	
//	NSLog(@"userDidShareResource: %@ - %@", screenName, dimensions);
	[[self.analyticsTracker setCustomDimensions:dimensions] sendEventWithScreenName:screenName
																		   category:CRUAnalyticsCategoryButton
																			 action:CRUAnalyticsActionTap
																			  label:GTTrackerEventNameForUserDidShareResource
																			  value:nil];
	
}

- (void)resourceDidOpenHandlerForNotification:(NSNotification *)notification {
	
	NSString *screenName	= [self screenNameFromNotification:notification];
	NSDictionary *dimensions= [self customDimensionsForNotification:notification];
	
//	NSLog(@"resourceDidOpen: %@ - %@", screenName, dimensions);
	[[self.analyticsTracker setCustomDimensions:dimensions] sendScreenViewWithScreenName:screenName];
	
}

- (void)everystudentDidSearchHandlerForNotification:(NSNotification *)notification {
	
	NSString *screenName	= [[self screenNameFromNotification:notification] stringByAppendingString:@"-search"];
	NSDictionary *dimensions= [self customDimensionsForNotification:notification];
	NSString *searchTerm	= ( notification.userInfo[GTTrackerNotificationEverystudentDidSearchUserInfoSearchTerm]	? : @"" );
	
//	NSLog(@"everystudentDidSearch: %@ %@ - %@", screenName, searchTerm, dimensions);
	[[self.analyticsTracker setCustomDimensions:dimensions] sendEventWithScreenName:screenName
																		   category:CRUAnalyticsCategorySearchbar
																			 action:CRUAnalyticsActionTap
																			  label:searchTerm
																			  value:nil];
	
}

- (void)everystudentDidOpenArticleHandlerForNotification:(NSNotification *)notification {
	
	NSString *articleCode	= ( notification.userInfo[GTTrackerNotificationEverystudentDidOpenArticleUserInfoArticleName]	? : @"" );
	//remove punction
	articleCode				= [[articleCode componentsSeparatedByCharactersInSet:[NSCharacterSet punctuationCharacterSet]] componentsJoinedByString:@""];
	//covert to lowercase
	articleCode				= [[NSValueTransformer valueTransformerForName:TTTLowercaseStringTransformerName] transformedValue:articleCode];
	//convert to traincase
	articleCode				= [[NSValueTransformer valueTransformerForName:TTTTrainCaseStringTransformerName] transformedValue:articleCode];
	NSString *screenName	= [[self screenNameFromNotification:notification] stringByAppendingFormat:@"-%@", articleCode];
	NSDictionary *dimensions= [self customDimensionsForNotification:notification];
	
//	NSLog(@"everystudentDidOpenArticle: %@ %@ - %@", screenName, articleCode, dimensions);
	[[self.analyticsTracker setCustomDimensions:dimensions] sendScreenViewWithScreenName:screenName];
	
}

- (void)dealloc {
	
	[self removeNotificationHandlers];
	
}

@end
