//
//  SNDownloadHeaderView.m
//  Snuffy
//
//  Created by Michael Harrison on 14/11/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//

#import "SNDownloadHeaderView.h"

@interface SNDownloadHeaderView (privateMethods)

-(void)doLayoutForReadyToDownload;
-(void)doLayoutForDownloading;
-(void)doLayoutForDownloadComplete;
-(void)doLayoutForDownloadingError;
-(void)doLayoutForReadyToDelete;
-(void)doLayoutForDisabled;

@end

@implementation SNDownloadHeaderView

-(id)initWithIconImage:(UIImage *)icon title:(NSString*)title subtitle:(NSString *)subtitle numberOnButton:(NSInteger)number state:(SNDownloadStateOptions)state expanded:(BOOL)expanded downloadPercentage:(float)percentage section:(NSInteger)sectionNumber delegate:(id <SNDownloadHeaderViewDelegate>)delegate {
	
	self = [super init];
	
    if (self) {
		
		self.exclusiveTouch = NO;
		
		self.delegate	= delegate;
		self.expanded	= expanded;
		self.section	= sectionNumber;
		
		
		//configure header
		//[self setBackgroundColor:       [UIColor whiteColor]];
        UIImageView *backgroundImage =      [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Snuffy_DownloadAssets_CellGrad"]];
        [backgroundImage setFrame:          CGRectMake(0, 0, 320, 44) ];

        self.background = backgroundImage;
        
		/*
		//configure icon
		 
		 if (icon == nil) {
		 
			icon = [UIImage imageNamed:@"placeholdericon"];
		 
		 }
		 
		UIImageView *iconView   =       [UIImageView alloc];
        [iconView setFrame:             CGRectMake(20, 4, 35, 35)];
		iconView.exclusiveTouch	=		NO;
        iconView.image			=		icon;
        self.imageView = iconView;
        [iconView release];
		*/
        
		//configure title
		UILabel *titleView =            [[UILabel alloc] initWithFrame:       CGRectMake(4, 4, 269, 35)];
        [titleView setFont:             [UIFont systemFontOfSize:20]];
        [titleView setAdjustsFontSizeToFitWidth:NO];
        [titleView setMinimumScaleFactor:13.0/20.0];
        
        [titleView setTextColor:        [UIColor blackColor]];
        [titleView setBackgroundColor:  [UIColor clearColor]];
        [titleView setTextAlignment:    UITextAlignmentLeft];
        [titleView setNumberOfLines:    1];
        [titleView setText:             title];
		titleView.exclusiveTouch	=	NO;
        
        self.textLabel = titleView;
		
        
		//configure subtitle
		UILabel     *subtitleView   =   [[UILabel alloc] initWithFrame:    CGRectMake(4, 21, 269, 18)];
        [subtitleView setFont:          [UIFont systemFontOfSize:13]];
        [subtitleView setTextColor:     [UIColor darkGrayColor]];
        [subtitleView setBackgroundColor:[UIColor clearColor]];
        [subtitleView setTextAlignment: UITextAlignmentLeft];
        [subtitleView setText:          subtitle];
		subtitleView.exclusiveTouch	=	NO;
        
        self.subtitle = subtitleView;
		
        
		//configure progress bar
        UIProgressView *progressView =  [[UIProgressView alloc] initWithFrame:    CGRectMake(63, 30, 194, 9)];
        [progressView setProgress:      percentage];
        [progressView setHidden:        YES];
		progressView.exclusiveTouch	=	NO;
        
        self.progressBar = progressView;
        
        
		//configure button
		SNDownloadButton *downloadButton =  [[SNDownloadButton alloc] initWithDelegate:self andState:SNDownloadStateReadyToDownload];
        //[downloadButton setFrame:      CGRectMake(265, 4, 35, 35)];
        //[downloadButton setBackgroundColor: [UIColor whiteColor]];
        //[downloadButton setBackgroundImage: [UIImage imageNamed:@"Snuffy_DownloadAssets_Tray.png"]  forState:UIControlStateNormal];
        //configure number display (button title)
        //[[downloadButton titleLabel] setFont:           [UIFont fontWithName:@"System Bold" size:15]];
        //[[downloadButton titleLabel] setTextColor:      [UIColor blackColor]];
        //[[downloadButton titleLabel] setShadowColor:    [UIColor lightGrayColor]];
        //[[downloadButton titleLabel] setShadowOffset:   CGSizeMake(1, 1)];
        
        //set number to display
		[downloadButton setDisplayNumber:number];
        [[downloadButton numberLabel] setText:@"88"];
        
        self.button = downloadButton;
        
        
        
        //Add the components to the view
        [self addSubview:self.background];
        //[self addSubview:self.imageView];
        [self addSubview:self.textLabel];
        [self addSubview:self.subtitle];
        [self addSubview:self.progressBar];
        [self addSubview:self.button];
        
        //do downloadstate-specific config
		[self setDownloadState:state];
    }
	
    return self;
	
}


-(void)setIconImage:(UIImage *)icon title:(NSString *)title subtitle:(NSString *)subtitle numberOnButton:(NSInteger)number state:(SNDownloadStateOptions)state expanded:(BOOL)expanded downloadPercentage:(float)percentage section:(NSInteger)sectionNumber {
	
	if (icon == nil) {
		
		icon = [UIImage imageNamed:@"placeholdericon"];
		
	}
	
	[self.imageView setImage:icon];
	[self.textLabel setText:title];
	[self.subtitle setText:subtitle];
	[self.button setNumberToDisplay:number];
	[self setDownloadPercentage:percentage];
	self.section	= sectionNumber;
	self.expanded	= expanded;
	
	[self setDownloadState:state];
	
}

#pragma mark -
#pragma mark User Interaction methods

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
	
	//when tapped toggle open
	if ([touch tapCount] > 0) {
		
		[self toggleOpenWithUserAction:YES];
		
	}
	
}

-(void)toggleOpenWithUserAction:(BOOL)userAction {
	
	//make any changes to layout for expanded or not
	
	
	// If this was a user action, send the delegate the appropriate message.
    if (userAction) {
		
        if (self.expanded) {
			
            if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
                [self.delegate sectionHeaderView:self sectionClosed:self.section];
            }
			
        } else {
			
			if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)]) {
                [self.delegate sectionHeaderView:self sectionOpened:self.section];
            }
			
        }
		
    }
	
}

-(void)setDownloadPercentage:(float)percentage {
	[self.progressBar setProgress:percentage animated:YES];
}

-(void)setDownloadState:(SNDownloadStateOptions)state {
	
	self.state	= state;
	
	switch (self.state) {
		case SNDownloadStateReadyToDownload:
			
			[self doLayoutForReadyToDownload];
			
			break;
			
		case SNDownloadStateDownloading:
			
			[self doLayoutForDownloading];
			
			break;
			
		case SNDownloadStateDownloadComplete:
			
			[self doLayoutForDownloadComplete];
			
			break;
			
		case SNDownloadStateDownloadingError:
			
			[self doLayoutForDownloadingError];
			
			break;
			
		case SNDownloadStateReadyToDelete:
			
			[self doLayoutForReadyToDelete];
			
			break;
			
		case SNDownloadStateDisabled:
			
			[self doLayoutForDisabled];
			
			break;
			
		default:
			
			[self doLayoutForReadyToDownload];
			
			break;
	}
	
}

#pragma mark -
#pragma mark SNDownloadButtonDelegate Methods

-(void)buttonPushedWithState:(SNDownloadStateOptions)state {
	
	if (state == SNDownloadStateDownloadComplete) {
		
		[self toggleOpenWithUserAction:YES];
		
	} else {
		
		if ([self.delegate respondsToSelector:@selector(buttonPushedForSection:)]) {
			[self.delegate buttonPushedForSection:self.section];
		}
		
	}
	
}

#pragma mark -
#pragma mark Mem Management Methods


@end

#pragma mark -
#pragma mark Private Methods

@implementation SNDownloadHeaderView (privateMethods)


//layout methods

-(void)doLayoutForReadyToDownload {
	[self.button setDownloadState:SNDownloadStateReadyToDownload];
}

-(void)doLayoutForDownloading {
	[self.button setDownloadState:SNDownloadStateDownloading];
}

-(void)doLayoutForDownloadComplete {
	[self.button setDownloadState:SNDownloadStateDownloadComplete];
}

-(void)doLayoutForDownloadingError {
	[self.button setDownloadState:SNDownloadStateDownloadingError];
}

-(void)doLayoutForReadyToDelete {
	[self.button setDownloadState:SNDownloadStateReadyToDelete];
}

-(void)doLayoutForDisabled {
	[self.button setDownloadState:SNDownloadStateDisabled];
}


@end
