//
//  SNDownloadHeaderView.h
//  Snuffy
//
//  Created by Michael Harrison on 14/11/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNDownloadButton.h"

@protocol SNDownloadHeaderViewDelegate;

@interface SNDownloadHeaderView : UIView

@property (nonatomic, strong)	UIImageView					*imageView;
@property (nonatomic, strong)	UILabel                     *textLabel;
@property (nonatomic, strong)	UILabel                     *subtitle;
@property (nonatomic, strong)	UIProgressView				*progressBar;
@property (nonatomic, strong)	SNDownloadButton			*button;
@property (nonatomic, strong)   UIImageView                 *background;

@property (nonatomic, assign)	SNDownloadStateOptions		state;

@property (nonatomic, weak)		id <SNDownloadHeaderViewDelegate> delegate;
@property (nonatomic, assign)	NSInteger					section;
@property (nonatomic, assign)	BOOL						expanded;

-(id)initWithIconImage:(UIImage *)icon title:(NSString*)title subtitle:(NSString *)subtitle numberOnButton:(NSInteger)number state:(SNDownloadStateOptions)state expanded:(BOOL)expanded downloadPercentage:(float)percentage section:(NSInteger)sectionNumber delegate:(id <SNDownloadHeaderViewDelegate>)delegate;
-(void)setIconImage:(UIImage *)icon title:(NSString *)title subtitle:(NSString *)subtitle numberOnButton:(NSInteger)number state:(SNDownloadStateOptions)state expanded:(BOOL)expanded downloadPercentage:(float)percentage section:(NSInteger)sectionNumber;
-(void)setDownloadState:(SNDownloadStateOptions)state;
-(void)setDownloadPercentage:(float)percentage;
-(void)toggleOpenWithUserAction:(BOOL)userAction;

@end


/*
 Protocol to be adopted by the section header's delegate; the section header tells its delegate when the section should be opened and closed.
 */
@protocol SNDownloadHeaderViewDelegate <NSObject>

@optional
-(void)buttonPushedForSection:(NSInteger)section;
-(void)sectionHeaderView:(SNDownloadHeaderView*)sectionHeaderView sectionOpened:(NSInteger)section;
-(void)sectionHeaderView:(SNDownloadHeaderView*)sectionHeaderView sectionClosed:(NSInteger)section;

@end
