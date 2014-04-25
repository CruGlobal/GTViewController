//
//  MHConfig.m
//  MissionHub
//
//  Created by Michael Harrison on 10/28/13.
//  Copyright (c) 2013 Cru. All rights reserved.
//

#import "GTConfig.h"

@implementation GTConfig

- (NSString *)apiKeyForErrbit {
	
	return _configValues[@"errbit-api-key"];
}

- (NSString *)apiKeyForGoogleAnalytics {
	
	return _configValues[@"google-analytics-tracker-id"];
}

- (NSString *)apiKeyForNewRelic {
	
	return _configValues[@"newrelic-api-key"];
}

@end
