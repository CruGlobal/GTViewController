//
//  GTFileLoaderExample.m
//  GTViewController
//
//  Created by Michael Harrison on 8/17/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import "GTFileLoaderExample.h"

@implementation GTFileLoaderExample

+ (instancetype)fileLoader {
	
	return [[GTFileLoaderExample alloc] init];
}

- (NSString *)pathOfPackagesDirectory {
	return [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Packages"];
}

@end
