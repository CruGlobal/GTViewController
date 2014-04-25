//
//  CRUConfig.m
//  Snuffy
//
//  Created by Michael Harrison on 4/1/14.
//
//

#import "CRUConfig.h"

@implementation CRUConfig

+ (instancetype)sharedConfig {
	
	static id _sharedConfig;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		_sharedConfig					= [[self alloc] init];
		
	});
	
	return _sharedConfig;
	
}

- (id)init {
	
    self = [super init];
    
	if (self) {
        
		//read config file
		NSString *configFilePath		= [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
		_configValues					= [NSDictionary dictionaryWithContentsOfFile:configFilePath];
		
    }
	
    return self;
}

@end
