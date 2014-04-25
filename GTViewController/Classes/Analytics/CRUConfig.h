//
//  CRUConfig.h
//  Snuffy
//
//  Created by Michael Harrison on 4/1/14.
//
//

#import <Foundation/Foundation.h>

@interface CRUConfig : NSObject {
	
	@protected
	NSDictionary *_configValues;
	
}

+ (instancetype)sharedConfig;

@end
