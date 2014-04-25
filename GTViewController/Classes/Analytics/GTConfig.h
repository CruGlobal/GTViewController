//
//  MHConfig.h
//  MissionHub
//
//  Created by Michael Harrison on 10/28/13.
//  Copyright (c) 2013 Cru. All rights reserved.
//

#import "CRUConfig.h"

@interface GTConfig : CRUConfig

@property (nonatomic, strong, readonly) NSString	*apiKeyForErrbit;
@property (nonatomic, strong, readonly) NSString	*apiKeyForGoogleAnalytics;
@property (nonatomic, strong, readonly) NSString	*apiKeyForNewRelic;

@end
