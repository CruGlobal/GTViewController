//
//  GTAnalyticsTracker.h
//  Snuffy
//
//  Created by Michael Harrison on 4/1/14.
//
//

#import <Foundation/Foundation.h>
#import "GTConfig.h"
#import "GTTrackerNotifications.h"

@interface GTTracker : NSObject

+ (instancetype)sharedTracker;

- (instancetype)initWithConfig:(GTConfig *)config;
- (void)startTracking;

@end
