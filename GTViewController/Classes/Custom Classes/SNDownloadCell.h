//
//  SNDownloadButton.h
//  Snuffy
//
//  Created by Michael Harrison on 12/11/11.
//  Copyright 2010 CCCA. All rights reserved.
//

#import "SNDownloadButton.h"
#import "GTFileLoader.h"

@protocol SNDownloadCellDelegate <NSObject>

@optional
-(void)buttonPushedForIndexPath:(NSIndexPath *)indexPath;

@end

@interface SNDownloadCell : UITableViewCell <SNDownloadButtonDelegate>

@property (nonatomic, strong)	UIView						*progressBar;
@property (nonatomic, strong)	SNDownloadButton			*button;
@property (nonatomic, strong)   UIActivityIndicatorView     *spinnerview;

@property (nonatomic, assign)	SNDownloadStateOptions		state;

@property (nonatomic, weak)		id <SNDownloadCellDelegate>	delegate;
@property (nonatomic, strong)	NSIndexPath					*indexPath;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(id <SNDownloadCellDelegate>)delegate indexPath:(NSIndexPath *)indexPath;
-(void)setIconImage:(UIImage *)icon title:(NSString *)title subtitle:(NSString *)subtitle state:(SNDownloadStateOptions)state downloadPercentage:(CGFloat)percentage indexPath:(NSIndexPath *)indexPath;
-(void)startSpinner;
-(void)stopSpinner;
-(void)setDownloadState:(SNDownloadStateOptions)state;
-(void)setDownloadPercentage:(CGFloat)percentage animated:(BOOL)animated;


@end
