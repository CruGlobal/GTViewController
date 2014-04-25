//
//  SNPayloadDownloader.h
//  Snuffy
//
//  Created by Michael Harrison on 3/11/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Downloader.h"
//#import "SnuffyRepo.h"
#import "SNPayloadOptions.h"

enum {
	SNPayloadDownloaderTypePackage,
	SNPayloadDownloaderTypeLanguage,
	SNPayloadDownloaderTypeIcon
};
typedef NSUInteger SNPayloadDownloaderType;

@protocol SNPayloadDownloaderDelegate;

/*************************** NOTE *****************************
 *
 *	SNPayloadDownloader is designed to deal with one download
 *	at a time please either wait till the download is finished
 *	before using it for another one or just create a new
 *	instance for each download (the second is a better idea)
 *
 **************************************************************/

@interface SNPayloadDownloader : NSObject <DownloaderDelegate>

@property (nonatomic, strong)	Downloader				*packageDownloader;
//@property	(nonatomic, retain) SnuffyRepo	*repo;
//@property (nonatomic, retain)	NSString	*identifier;
@property (nonatomic, strong)	NSString				*packageID;
@property (nonatomic, strong)	NSString				*languageCode;
@property (nonatomic, assign)	SNPayloadDownloaderType	type;

@property (nonatomic, strong)	id						delegate;

-(id)initWithPackage:(NSString *)packageID language:(NSString *)languageCode delegate:(id <SNPayloadDownloaderDelegate>)delegate;
-(void)downloadPayloadWithOptions: (SNPayloadOptions *) options type:(SNPayloadDownloaderType)type;
-(void)cancelDownload;
-(NSMutableData *)getData;
-(float)getProgress;

@end

@protocol SNPayloadDownloaderDelegate <NSObject>

@optional
-(void)didFail:(SNPayloadDownloader *)downloader withError: (NSError *)error; //will be called each time the download fails
-(void)didReceiveData:(SNPayloadDownloader *)downloader; //will be called each time data has been received
-(void)didLoadData:(SNPayloadDownloader *)downloader withPath:(NSString *)path; //will be called when the download has finished
@end
