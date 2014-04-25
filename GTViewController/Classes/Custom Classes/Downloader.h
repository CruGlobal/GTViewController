//
//  Downloader.h
//  Snuffy
//
//  Created by Michael Harrison on 3/11/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//	adapted from http://jayes-dev.blogspot.com/2010/12/asynchronous-downloadrequest-with.html
//

#import <Foundation/Foundation.h>

enum {
	SNDownloadToFile,
	SNDownloadToMemory
};
typedef NSUInteger SNDownloaderToOptions;

@protocol DownloaderDelegate;

/*************************** NOTE *****************************
 *
 *	Downloader is designed to deal with one download at a time
 *	please either wait till the download is finished before
 *	using it for another one or just create a new instance for
 *	each download (the second is a better idea)
 *
 **************************************************************/

@interface Downloader : NSObject <NSURLConnectionDelegate>

@property(nonatomic, assign) SNDownloaderToOptions mode;
@property(nonatomic, strong) NSMutableData *downloadData;
@property(nonatomic, strong) NSString* localPath;
@property(nonatomic, weak) id <DownloaderDelegate> delegate;
@property(nonatomic, strong) NSURLConnection* connection;
@property(nonatomic, assign) CGFloat floatTotalData;
@property(nonatomic, assign) CGFloat floatReceivedData;

-(void)loadDataFrom: (NSString *)fileUrl withFilename: (NSString *)filename mode:(SNDownloaderToOptions)mode; //This will download a file from fileUrl and store it at /Documents/tmp/<filename>
-(void)cancel;
-(float)getProgress;

@end

@protocol DownloaderDelegate <NSObject>

@optional
-(void)downloaderDidFail:(Downloader *)downloader withError: (NSError *)error; //will be called each time the download fails
-(void)downloaderDidReceiveData:(Downloader *)downloader; //will be called each time data has been received
-(void)downloaderDidLoadData:(Downloader *)downloader withPath:(NSString *)path; //will be called when the download has finished
@end
