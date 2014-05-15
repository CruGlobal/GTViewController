//
//  FileLoader.m
//  Snuffy
//
//  Created by Tom Flynn on 12/11/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import "GTFileLoader.h"

@interface GTFileLoader ()

@property (nonatomic, strong)	NSMutableDictionary	*imageCache;

- (NSString *)findPathForFileWithFilename:(NSString *)filename;
- (NSString *)filenameForDevicesResolutionWith:(NSString *)filename;

- (UIImage *)imageWithPath:(NSString *)path;

@end

@implementation GTFileLoader

#pragma mark - initialization methods

+ (instancetype)sharedInstance {
	
	static GTFileLoader *sharedInstance;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		
		sharedInstance					= [[GTFileLoader alloc] init];
		
	});
	
	return sharedInstance;
	
}

+ (instancetype)sharedInstanceWithPackage:(NSString *)pack language:(NSString *)lang {
	
	[GTFileLoader sharedInstance].package		= pack;
	[GTFileLoader sharedInstance].language		= lang;
	
	return [GTFileLoader sharedInstance];
}

+ (instancetype)fileLoaderWithPackage:(NSString *)pack language:(NSString *)lang {
	
	return [[GTFileLoader alloc] initWithPackage:pack language:lang];
}

- (instancetype)initWithPackage:(NSString *)pack language:(NSString *)lang {
	
	self = [super init];
    if (self) {
        
		self.package	= pack;
		self.language	= lang;
		
    }
	
    return self;
}

- (id)init {
	
    self = [super init];
    if (self) {
        
		self.imageCache					= [NSMutableDictionary dictionary];
		
    }
	
    return self;
}

#pragma mark - path methods

+ (NSString *)pathOfPackagesDirectory {
	return [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Packages"];
	//return [[NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"] stringByAppendingPathComponent:@"Packages"];
}

- (NSString *)pathOfConfigFile {
	
	return [self pathOfFileWithFilename:[self.language stringByAppendingString:@".xml"]];
}

- (NSString *)pathOfFileWithFilename:(NSString *)filename {
	
	NSString *devspecfilename	= [self filenameForDevicesResolutionWith:filename];
	NSString *path				= [self findPathForFileWithFilename:devspecfilename];
	
	if (!path) {
		path	= [self findPathForFileWithFilename:filename];
	}
	
	return path;
}

- (NSString *)findPathForFileWithFilename:(NSString *)filename {
	
	NSString *path = [[GTFileLoader pathOfPackagesDirectory] stringByAppendingPathComponent:filename];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
														stringByAppendingPathComponent:filename];
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
														stringByAppendingPathComponent:self.language]
														stringByAppendingPathComponent:filename];
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
														stringByAppendingPathComponent:self.language]
														stringByAppendingPathComponent:@"thumbs"]
														stringByAppendingPathComponent:filename];
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
														stringByAppendingPathComponent:self.language]
														stringByAppendingPathComponent:@"images"]
														stringByAppendingPathComponent:filename];
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
														stringByAppendingPathComponent:@"icons"]
														stringByAppendingPathComponent:filename];
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
				 stringByAppendingPathComponent:@"shared"]
				stringByAppendingPathComponent:filename];
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:@"shared"]
														stringByAppendingPathComponent:filename];
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension]
											   ofType:[filename pathExtension]]; //will return nil if it doesn't exist
	}
	
	return path;
}

#pragma mark - image methods

- (UIImage *)imageWithFilename:(NSString *)filename {
	
	NSString	*path	= [self pathOfFileWithFilename:filename];
	UIImage		*image	= self.imageCache[path];
	
	if (!image) {
		image = [UIImage imageWithContentsOfFile:path];
		self.imageCache[path]	= image;
	}
	
	return image;
}

#pragma mark - cache methods

- (void)cacheImageWithFileName:(NSString *)filename {
	
	NSString *path = [self pathOfFileWithFilename:filename];
	
	if (!self.imageCache[path]) {
		UIImage *image			= [UIImage imageWithContentsOfFile:path];
		self.imageCache[path]	= image;
	}
	
}

- (void)cacheSharedImages {
	
	NSString	*sharedDirectory	= [[GTFileLoader pathOfPackagesDirectory] stringByAppendingPathComponent:@"shared"];
	
	NSFileManager *localFileManager	= [[NSFileManager alloc] init];
	NSDirectoryEnumerator *dirEnum	= [localFileManager enumeratorAtPath:sharedDirectory];
	
	NSString *imageFilename;
	while (imageFilename = [dirEnum nextObject]) {
		[self imageWithPath:[sharedDirectory stringByAppendingPathComponent:imageFilename]];
	}
	
	
}

- (UIImage *)imageWithPath:(NSString *)path {
	
	UIImage		*image	= self.imageCache[path];
	
	if (image == nil) {
		image = [UIImage imageWithContentsOfFile:path];
		self.imageCache[path] = image;
	}
	
	return image;
}

- (void)clearCache {
	[self.imageCache removeAllObjects];
}

#pragma mark - misc methods

+ (BOOL)isRetina {
	
	if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0)) {
		return YES;
	} else {
		return NO;
	}
	
}

- (NSString *)filenameForDevicesResolutionWith:(NSString *)filename {
	
	//is it an iPhone4 (ie retina display) and
	//the image file is not a hi-res image already
	//if([deviceType isEqualToString:@"iPhone3,1"] && [filename rangeOfString:@"@2x"].location == NSNotFound) {
	if([[filename pathExtension] isEqualToString:@"png"] && [GTFileLoader isRetina] && [filename rangeOfString:@"@2x"].location == NSNotFound) {
		filename = [NSString stringWithFormat:@"%@@2x.%@",[filename stringByDeletingPathExtension], [filename pathExtension]];
	}
	
	return filename;
}

#pragma mark - dealloc

- (void)dealloc {

	[self clearCache];
	
}

@end
