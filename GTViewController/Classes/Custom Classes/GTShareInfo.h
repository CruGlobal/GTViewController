//
//  GTShareInfo.h
//  GTViewController
//
//  Created by Michael Harrison on 8/28/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTShareInfo : NSObject

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSURL *shareURL;
@property (nonatomic, assign) BOOL addPackageInfo;
@property (nonatomic, assign) BOOL addCampaignInfo;

- (instancetype)initWithBaseURL:(NSURL *)baseURL packageCode:(NSString *)packageCode languageCode:(NSString *)languageCode;
- (void)setPackageCode:(NSString *)packageCode languageCode:(NSString *)languageCode pageNumber:(NSNumber *)pageNumber;
- (void)setGoogleAnalyticsCampaign:(NSString *)campaign source:(NSString *)source medium:(NSString *)medium;

@end
