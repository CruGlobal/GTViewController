//
//  FileLoader.h
//  Snuffy
//
//  Created by Tom Flynn on 12/11/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GTFileLoader : NSObject

@property (nonatomic, assign)	BOOL				isRetinaDisplay;
@property (nonatomic, strong)	NSString			*package;
@property (nonatomic, strong)	NSString			*language;
@property (nonatomic, strong)	NSMutableDictionary	*imageCache;

+ (GTFileLoader *)sharedInstance;
+ (GTFileLoader *)sharedInstanceWithPackage:(NSString *)pack language:(NSString *)lang;
+ (instancetype)fileLoaderWithPackage:(NSString *)pack language:(NSString *)lang;
-(id)initWithPackage:(NSString *)pack language:(NSString *)lang;
-(NSString *)pathOfConfigFile;
-(NSString *)pathOfFileWithFilename:(NSString *)filename;
-(NSString *)pathOfBundledImageWithFilename:(NSString *)filename;
-(NSString *)pathOfSharedImageWithFilename:(NSString *)filename;
-(NSString *)pathOfPackagedXmlWithFilename:(NSString *)filename;
-(NSString *)pathOfPackagedImageWithFilename:(NSString *)filename;
-(NSString *)pathOfPackagedThumbWithFilename:(NSString *)filename;
-(NSString *)pathOfPackagedIconWithFilename:(NSString *)filename;
-(UIImage *)imageWithFilename:(NSString *)filename;
-(UIImage *)imageWithPath:(NSString *)path;
-(UIImage *)imageFromBundleWithFilename:(NSString *)filename;
-(UIImage *)imageFromSharedWithFilename:(NSString *)filename;
-(UIImage *)imageFromPackageWithFilename:(NSString *)filename;
-(UIImage *)imageThumbFromPackageWithFilename:(NSString *)filename;
-(UIImage *)imageIconFromPackageWithFilename:(NSString *)filename;
-(UIImage *)imageIconReposIconAttribute:(NSString *)iconAttribute;
-(NSString *)filenameForDevicesResolutionWith:(NSString *)filename;
-(void)cacheImageWithFileName:(NSString *)filename;
-(void)cacheImageFromBundleWithFilename:(NSString *)filename;
-(void)cacheImageFromSharedWithFilename:(NSString *)filename;
-(void)cacheImageFromPackageWithFilename:(NSString *)filename;
-(void)cacheThumbFromPackageWithFilename:(NSString *)filename;
-(void)cacheIconFromPackageWithFilename:(NSString *)filename;
-(void)cacheSharedImages;
-(void)clearCache;

+(NSString *)pathOfLocalRepoFile;
+(NSString *)pathOfRemoteRepoFile;
+(NSString *)pathOfPackagesDirectory;
+(NSString *)pathOfIconFromReposIconAttribute:(NSString *)iconAttribute;
+(NSString *)pathOfXmlFileForPackage:(NSString *)packageID andLanguage:(NSString *)languageCode andFilename:(NSString *)filename;

//warning do not use
+(void)unzipPayloadWithPath:(NSString *)path;
+(void)removeLanguage:(NSString *)languageCode forPackage:(NSString *)packageID;

+(BOOL)isRetina;

@end
