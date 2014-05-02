//
//  FileLoader.m
//  Snuffy
//
//  Created by Tom Flynn on 12/11/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import "GTFileLoader.h"

@implementation GTFileLoader

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

- (id)initWithPackage:(NSString *)pack language:(NSString *)lang {
	
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
        
		self.isRetinaDisplay			= [GTFileLoader isRetina];
		self.imageCache					= [NSMutableDictionary dictionary];
		
    }
	
    return self;
}

-(NSString *)pathOfConfigFile {
	
	return [self pathOfFileWithFilename:[self.language stringByAppendingString:@".xml"]];
}

-(NSString *)pathOfFileWithFilename:(NSString *)filename {
	//NSLog(@"pathOfFileWithFileName:%@", filename);
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

-(NSString *)pathOfPackagedXmlWithFilename:(NSString *)filename {
	//NSLog(@"pathOfPackagedXmlWithWithFileName:%@", filename);
	NSString *path = [[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
																stringByAppendingPathComponent:self.language]
																stringByAppendingPathComponent:filename];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[[GTFileLoader pathOfPackagesDirectory]			stringByAppendingPathComponent:self.package]
																stringByAppendingPathComponent:filename];
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension]
											   ofType:[filename pathExtension]];
	}
	
	return path;
}

-(NSString *)pathOfBundledImageWithFilename:(NSString *)filename {
	//NSLog(@"pathOfBundledImageWithFileName:%@", filename);
	NSString *devspecfilename = [self filenameForDevicesResolutionWith:filename];
	//NSLog(@"Looking for image at %@",devspecfilename);
	NSString *path = [[NSBundle mainBundle] pathForResource:[devspecfilename stringByDeletingPathExtension]
										   ofType:[devspecfilename pathExtension]];
    
    //NSLog(@"devspecfilename stringbydeletingpathextension: %@",[devspecfilename stringByDeletingPathExtension]);
    //NSLog(@"filename stringbydeletingpathextension: %@",[filename stringByDeletingPathExtension]);    
	if (path == nil && ![filename isEqualToString:devspecfilename]) {
		path = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension]
											   ofType:[filename pathExtension]];
		//NSLog(@"No hi-res image found, replaced with lo-res image");
	}
	return path;
}

-(NSString *)pathOfSharedImageWithFilename:(NSString *)filename {
    
    NSString *devspecfilename = [self filenameForDevicesResolutionWith:filename];
    
    //look in /package/shared
    NSString *path = [[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
															stringByAppendingPathComponent:@"shared"]
															stringByAppendingPathComponent:devspecfilename];
	
	//use lo-res if hi-res not found
	if (![[NSFileManager defaultManager] fileExistsAtPath:path] && ![filename isEqualToString:devspecfilename]) {
		path = [[[[GTFileLoader pathOfPackagesDirectory]		stringByAppendingPathComponent:self.package]
															stringByAppendingPathComponent:@"shared"]
															stringByAppendingPathComponent:filename];
	}
	
	//look in /shared
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:@"shared"]
				stringByAppendingPathComponent:devspecfilename];
	}
	
	//use lo-res if hi-res not found
	if (![[NSFileManager defaultManager] fileExistsAtPath:path] && ![filename isEqualToString:devspecfilename]) {
		path = [[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:@"shared"]
				stringByAppendingPathComponent:filename];
	}
	
	//look in bundle
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[NSBundle mainBundle] pathForResource:[devspecfilename stringByDeletingPathExtension]
											   ofType:[devspecfilename pathExtension]]; //will return nil if it doesn't exist
	}
	
	//use lo-res if hi-res not found
	if (path == nil && ![filename isEqualToString:devspecfilename]) {
		path = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension]
											   ofType:[filename pathExtension]]; //will return nil if it doesn't exist
	}
	
	return path;
}

-(NSString *)pathOfPackagedImageWithFilename:(NSString *)filename {
		//NSLog(@"pathOfPackagedImageWithFileName:%@", filename);
	NSString *devspecfilename = [self filenameForDevicesResolutionWith:filename];
	
	//look in /<package>/<language>/images
	NSString *path = [[[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
																stringByAppendingPathComponent:self.language]
																stringByAppendingPathComponent:@"images"]
																stringByAppendingPathComponent:devspecfilename];
	
	//use lo-res if hi-res not found
	if (![[NSFileManager defaultManager] fileExistsAtPath:path] && ![filename isEqualToString:devspecfilename]) {
		path = [[[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
														stringByAppendingPathComponent:self.language]
														stringByAppendingPathComponent:@"images"]
														stringByAppendingPathComponent:filename];
	}
	
	//look in /<package>/<language>/thumbs
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
														stringByAppendingPathComponent:self.language]
														stringByAppendingPathComponent:@"thumbs"]
														stringByAppendingPathComponent:devspecfilename];
	}
	
	//use lo-res if hi-res not found
	if (![[NSFileManager defaultManager] fileExistsAtPath:path] && ![filename isEqualToString:devspecfilename]) {
		path = [[[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
														stringByAppendingPathComponent:self.language]
														stringByAppendingPathComponent:@"thumbs"]
														stringByAppendingPathComponent:filename];
	}
	
	//look in /<package>/icons
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
														stringByAppendingPathComponent:@"icons"]
														stringByAppendingPathComponent:devspecfilename];
	}
	
	//use lo-res if hi-res not found
	if (![[NSFileManager defaultManager] fileExistsAtPath:path] && ![filename isEqualToString:devspecfilename]) {
		path = [[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
														stringByAppendingPathComponent:@"icons"]
														stringByAppendingPathComponent:filename];
	}
	
	//look in /<package>/shared
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
				 stringByAppendingPathComponent:@"shared"]
				stringByAppendingPathComponent:devspecfilename];
	}
	
	//use lo-res if hi-res not found
	if (![[NSFileManager defaultManager] fileExistsAtPath:path] && ![filename isEqualToString:devspecfilename]) {
		path = [[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
				 stringByAppendingPathComponent:@"shared"]
				stringByAppendingPathComponent:filename];
	}
	
	//look in /shared
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:@"shared"]
														stringByAppendingPathComponent:devspecfilename];
	}
	
	//use lo-res if hi-res not found
	if (![[NSFileManager defaultManager] fileExistsAtPath:path] && ![filename isEqualToString:devspecfilename]) {
		path = [[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:@"shared"]
														stringByAppendingPathComponent:filename];
	}
	
	//look in bundle
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[NSBundle mainBundle] pathForResource:[devspecfilename stringByDeletingPathExtension]
											   ofType:[devspecfilename pathExtension]]; //will return nil if it doesn't exist
	}
	
	//use lo-res if hi-res not found
	if (path == nil && ![filename isEqualToString:devspecfilename]) {
		path = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension]
											   ofType:[filename pathExtension]]; //will return nil if it doesn't exist
	}
	
	return path;
}

-(NSString *)pathOfPackagedThumbWithFilename:(NSString *)filename {
//	NSLog(@"pathOfPackagedThumbWithFileName:%@", filename);
	NSString *devspecfilename = [self filenameForDevicesResolutionWith:filename];
	
	NSString *path = [[[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
																stringByAppendingPathComponent:self.language]
																stringByAppendingPathComponent:@"thumbs"]
																stringByAppendingPathComponent:devspecfilename];
	
	//use lo-res if hi-res not found
	if (![[NSFileManager defaultManager] fileExistsAtPath:path] && ![filename isEqualToString:devspecfilename]) {
		path = [[[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
														stringByAppendingPathComponent:self.language]
														stringByAppendingPathComponent:@"thumbs"]
														stringByAppendingPathComponent:filename];
	}
	
	//look in /<package>/shared
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
														stringByAppendingPathComponent:@"shared"]
														stringByAppendingPathComponent:devspecfilename];
	}
	
	//use lo-res if hi-res not found
	if (![[NSFileManager defaultManager] fileExistsAtPath:path] && ![filename isEqualToString:devspecfilename]) {
		path = [[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
														stringByAppendingPathComponent:@"shared"]
														stringByAppendingPathComponent:filename];
	}
	
	//look in /shared
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:@"shared"]
				stringByAppendingPathComponent:devspecfilename];
	}
	
	//use lo-res if hi-res not found
	if (![[NSFileManager defaultManager] fileExistsAtPath:path] && ![filename isEqualToString:devspecfilename]) {
		path = [[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:@"shared"]
				stringByAppendingPathComponent:filename];
	}
	
	//look in bundle
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[NSBundle mainBundle] pathForResource:[devspecfilename stringByDeletingPathExtension]
											   ofType:[devspecfilename pathExtension]]; //will return nil if it doesn't exist
	}
	
	//use lo-res if hi-res not found
	if (path == nil && ![filename isEqualToString:devspecfilename]) {
		path = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension]
											   ofType:[filename pathExtension]]; //will return nil if it doesn't exist
	}
	
	return path;
}

-(NSString *)pathOfPackagedIconWithFilename:(NSString *)filename {
	//NSLog(@"pathOfPackagedThumbWithFileName:%@", filename);
	NSString *devspecfilename = [self filenameForDevicesResolutionWith:filename];
	
	NSString *path = [[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
																stringByAppendingPathComponent:@"icons"]
																stringByAppendingPathComponent:devspecfilename];
	
	//use lo-res if hi-res not found
	if (![[NSFileManager defaultManager] fileExistsAtPath:path] && ![filename isEqualToString:devspecfilename]) {
		path = [[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
														stringByAppendingPathComponent:@"icons"]
														stringByAppendingPathComponent:filename];
	}
	
	//look in /<package>/shared
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
				 stringByAppendingPathComponent:@"shared"]
				stringByAppendingPathComponent:devspecfilename];
	}
	
	//use lo-res if hi-res not found
	if (![[NSFileManager defaultManager] fileExistsAtPath:path] && ![filename isEqualToString:devspecfilename]) {
		path = [[[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:self.package]
				 stringByAppendingPathComponent:@"shared"]
				stringByAppendingPathComponent:filename];
	}
	
	//look in /shared
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:@"shared"]
				stringByAppendingPathComponent:devspecfilename];
	}
	
	//use lo-res if hi-res not found
	if (![[NSFileManager defaultManager] fileExistsAtPath:path] && ![filename isEqualToString:devspecfilename]) {
		path = [[[GTFileLoader pathOfPackagesDirectory]	stringByAppendingPathComponent:@"shared"]
				stringByAppendingPathComponent:filename];
	}
	
	//look in bundle
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[NSBundle mainBundle] pathForResource:[devspecfilename stringByDeletingPathExtension]
											   ofType:[devspecfilename pathExtension]]; //will return nil if it doesn't exist
	}
	
	//use lo-res if hi-res not found
	if (path == nil && ![filename isEqualToString:devspecfilename]) {
		path = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension]
											   ofType:[filename pathExtension]]; //will return nil if it doesn't exist
	}
	
	return path;
}

-(UIImage *)imageWithFilename:(NSString *)filename {
	//NSLog(@"imageWithFileName:%@", filename);
	NSString	*path	= [self pathOfFileWithFilename:[self filenameForDevicesResolutionWith:filename]];
	UIImage		*image	= [self.imageCache objectForKey:path];
	
	if (image == nil) {
		image = [UIImage imageWithContentsOfFile:path];
		[self.imageCache setObject:image forKey:path];
	} else {
		//NSLog(@"already cached: %@", filename);
	}
	
	return image;
}

-(UIImage *)imageWithPath:(NSString *)path {
//	NSLog(@"imageWithPath:%@", path);
	UIImage		*image	= [self.imageCache objectForKey:path];
	
	if (image == nil) {
		image = [UIImage imageWithContentsOfFile:path];
		[self.imageCache setObject:image forKey:path];
	} else {
		//NSLog(@"already cached: %@", filename);
	}
	
	return image;
}

-(UIImage *)imageFromBundleWithFilename:(NSString *)filename {
	//NSLog(@"imageFromBundleWithFileName:%@", filename);
	NSString	*path	= [self pathOfBundledImageWithFilename:filename];
	UIImage		*image	= [self.imageCache objectForKey:path];
	
	if (image == nil) {
		image = [UIImage imageWithContentsOfFile:path];
		[self.imageCache setObject:image forKey:path];
	} else {
		//NSLog(@"already cached: %@", filename);
	}

    return image;
	
}

-(UIImage *)imageFromSharedWithFilename:(NSString *)filename {
    //NSLog(@"imageFromSharedWithFilename:%@", filename);
	NSString	*path	= [self pathOfSharedImageWithFilename:filename];
	UIImage		*image	= [self.imageCache objectForKey:path];
	
	if (image == nil) {
		image = [UIImage imageWithContentsOfFile:path];
		[self.imageCache setObject:image forKey:path];
	} else {
		//NSLog(@"already cached: %@", filename);
	}
    
    return image;
}

-(UIImage *)imageFromPackageWithFilename:(NSString *)filename {
	NSString	*path	= [self pathOfPackagedImageWithFilename:filename];
    if (path == nil) {
        //look elsewhere if the image is not found.
        path = [self pathOfBundledImageWithFilename:filename];
    }
	UIImage		*image	= [self.imageCache objectForKey:path];
	//NSLog(@"imageFromPackageWithFileName:%@ - %@", filename, path);
	
	if (image == nil) {
		image = [UIImage imageWithContentsOfFile:path];
		[self.imageCache setObject:image forKey:path];
	} else {
		//NSLog(@"already cached: %@", filename);
	}
	//NSLog(@"%@", image);
	return image;
}

-(UIImage *)imageThumbFromPackageWithFilename:(NSString *)filename {
	//NSLog(@"imageThumbFromPackageWithFileName:%@", filename);
	NSString	*path	= [self pathOfPackagedThumbWithFilename:filename];
	UIImage		*image	= [self.imageCache objectForKey:path];
	
	if (image == nil) {
		image = [UIImage imageWithContentsOfFile:path];
		[self.imageCache setObject:image forKey:path];
	} else {
		//NSLog(@"already cached: %@", filename);
	}
	
	return image;
}

-(UIImage *)imageIconFromPackageWithFilename:(NSString *)filename {
	//NSLog(@"imageThumbFromPackageWithFileName:%@", filename);
	NSString	*path	= [self pathOfPackagedIconWithFilename:filename];
	UIImage		*image	= [self.imageCache objectForKey:path];
	
	if (image == nil) {
		image = [UIImage imageWithContentsOfFile:path];
		[self.imageCache setObject:image forKey:path];
	} else {
		//NSLog(@"already cached: %@", filename);
	}
	
	return image;
}

-(NSString *)filenameForDevicesResolutionWith:(NSString *)filename {
	//NSLog(@"filenameForDevicesResolutionWith:%@", filename);
	
	//is it an iPhone4 (ie retina display) and
	//the image file is not a hi-res image already
	//if([deviceType isEqualToString:@"iPhone3,1"] && [filename rangeOfString:@"@2x"].location == NSNotFound) {
	if(self.isRetinaDisplay && [filename rangeOfString:@"@2x"].location == NSNotFound) {
		filename = [NSString stringWithFormat:@"%@@2x.%@",[filename stringByDeletingPathExtension], [filename pathExtension]];
	}
	
	return filename;
}

-(void)cacheImageWithFileName:(NSString *)filename {
	//NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSString *path = [self pathOfFileWithFilename:[self filenameForDevicesResolutionWith:filename]];
	//NSLog(@"cacheImageWithFileName:%@", filename);
	
	if ([self.imageCache objectForKey:path] == nil) {
		UIImage *image = [UIImage imageWithContentsOfFile:path];
		[self.imageCache setObject:image
							forKey:path];
	} else {
		//NSLog(@"already cached: %@", filename);
	}
	//[pool release];
}

-(void)cacheImageFromBundleWithFilename:(NSString *)filename {
	//NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self imageFromBundleWithFilename:filename];
	//NSLog(@"cacheImageFromBundleWithFileName:%@", filename);
	//[pool release];
}

-(void)cacheImageFromSharedWithFilename:(NSString *)filename {
	//NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self imageFromSharedWithFilename:filename];
	//NSLog(@"cacheImageFromBundleWithFileName:%@", filename);
	//[pool release];
}

-(void)cacheImageFromPackageWithFilename:(NSString *)filename {
	//NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self imageFromPackageWithFilename:filename];
	//NSLog(@"cacheImageFromPackageWithFileName:%@", filename);
	//[pool release];
}

-(void)cacheThumbFromPackageWithFilename:(NSString *)filename {
	//NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self imageThumbFromPackageWithFilename:filename];
	//NSLog(@"cacheThumbFromPackageWithFileName:%@", filename);
	//[pool release];
}

-(void)cacheIconFromPackageWithFilename:(NSString *)filename {
	//NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self imageIconFromPackageWithFilename:filename];
	//NSLog(@"cacheIconFromPackageWithFileName:%@", filename);
	//[pool release];
}

-(void)cacheSharedImages {
	
	NSString	*sharedDirectory	= [[GTFileLoader pathOfPackagesDirectory] stringByAppendingPathComponent:@"shared"];
	
	NSFileManager *localFileManager	= [[NSFileManager alloc] init];
	NSDirectoryEnumerator *dirEnum	= [localFileManager enumeratorAtPath:sharedDirectory];
	
	NSString *imageFilename;
	while (imageFilename = [dirEnum nextObject]) {
		[self imageWithPath:[sharedDirectory stringByAppendingPathComponent:imageFilename]];
	}
	
	
}

-(void)clearCache {
	[self.imageCache removeAllObjects];
}

+(NSString *)pathOfPackagesDirectory {
	return [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Packages"];
	//return [[NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"] stringByAppendingPathComponent:@"Packages"];
}

+(NSString *)pathOfXmlFileForPackage:(NSString *)packageID andLanguage:(NSString *)languageCode andFilename:(NSString *)filename {
	
	return [[[[GTFileLoader pathOfPackagesDirectory] stringByAppendingPathComponent:packageID] stringByAppendingPathComponent:languageCode] stringByAppendingPathComponent:filename];
	
}

+(BOOL)isRetina {
	
	if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0)) {
		return YES;
	} else {
		return NO;
	}
	
}

-(void)dealloc {

	[self clearCache];
	
}

@end
