//
//  FileLoader.h
//  Snuffy
//
//  Created by Tom Flynn on 12/11/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GTFileLoader : NSObject

@property (nonatomic, strong)	NSString			*package;
@property (nonatomic, strong)	NSString			*language;

+ (GTFileLoader *)sharedInstance;
+ (GTFileLoader *)sharedInstanceWithPackage:(NSString *)pack language:(NSString *)lang;
+ (instancetype)fileLoaderWithPackage:(NSString *)pack language:(NSString *)lang;
- (instancetype)initWithPackage:(NSString *)pack language:(NSString *)lang;

+ (NSString *)pathOfPackagesDirectory;
- (NSString *)pathOfConfigFile;
- (NSString *)pathOfFileWithFilename:(NSString *)filename;

- (UIImage *)imageWithFilename:(NSString *)filename;

- (void)cacheImageWithFileName:(NSString *)filename;
- (void)cacheSharedImages;
- (void)clearCache;

+ (BOOL)isRetina;

@end
