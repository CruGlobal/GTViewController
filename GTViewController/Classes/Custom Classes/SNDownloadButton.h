//
//  SNDownloadButton.h
//  Snuffy
//
//  Created by Michael Harrison on 12/11/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HorizontalGestureRecognizer.h"
#import "GTFileLoader.h"

enum {
	SNDownloadStateReadyToDownload,
	SNDownloadStateReadyToDelete,
	SNDownloadStateDownloading,
	SNDownloadStateDownloadingError,
	SNDownloadStateDownloadComplete,
	SNDownloadStateDisabled
};
typedef NSUInteger SNDownloadStateOptions;

@protocol SNDownloadButtonDelegate <NSObject>

@optional
-(void)buttonPushedWithState:(SNDownloadStateOptions)state;

@end

@interface SNDownloadButton : UIButton

@property (nonatomic, weak)		id <SNDownloadButtonDelegate>	delegate;
@property (nonatomic, assign)	SNDownloadStateOptions			downloadState;
@property (nonatomic, assign)	NSInteger						numberToDisplay;
@property (nonatomic, strong)   UILabel                         *numberLabel;

-(id)initWithDelegate:(id)delegate andState:(SNDownloadStateOptions)state;
-(void)setDisplayNumber:(NSInteger)number;
-(void)clearDisplayNumber;

@end
