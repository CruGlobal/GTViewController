//
//  CRUAnalyticsTracker.h
//  MissionHub
//
//  Created by Michael Harrison on 10/29/13.
//  Copyright (c) 2013 Cru. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const CRUAnalyticsCategoryUI;
extern NSString * const CRUAnalyticsCategoryBackgroundProcess;
extern NSString * const CRUAnalyticsCategoryButton;
extern NSString * const CRUAnalyticsCategoryCell;
extern NSString * const CRUAnalyticsCategoryCheckbox;
extern NSString * const CRUAnalyticsCategorySearchbar;
extern NSString * const CRUAnalyticsCategoryList;
extern NSString * const CRUAnalyticsCategoryPopover;
extern NSString * const CRUAnalyticsCategoryActivityBar;

extern NSString * const CRUAnalyticsActionTap;
extern NSString * const CRUAnalyticsActionSwipe;

@interface CRUAnalyticsTracker : NSObject

@property (nonatomic, assign)	BOOL developmentMode;

+ (instancetype)startTrackingWithTrackingID:(NSString *)trackingID;
+ (instancetype)sharedAnalyticsTrackerWithTrackingID:(NSString *)trackingID;
- (instancetype)initWithTrackingID:(NSString *)trackingID;

- (instancetype)setScreenName:(NSString *)screenName;

/**
 *  adds custom dimensions to the tracker. The keys must be of type NSNumber eg @{@1: @"en"}
 *
 *  @param customDimensions a dictionary with NSNumbers as keys. These should correspond with the index of your
 *  Google Analytics custom dimension index.
 *
 *  @return self for method chaining
 */
- (instancetype)setCustomDimensions:(NSDictionary *)customDimensions;

- (void)sendScreenView;
- (void)sendEventWithLabel:(NSString *)label;
- (void)sendEventWithCategory:(NSString *)category label:(NSString *)label;
- (void)sendEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;

- (void)sendScreenViewWithScreenName:(NSString *)screenName;
- (void)sendEventWithScreenName:(NSString *)screenName label:(NSString *)label;
- (void)sendEventWithScreenName:(NSString *)screenName category:(NSString *)category label:(NSString *)label;
- (void)sendEventWithScreenName:(NSString *)screenName category:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;

@end
