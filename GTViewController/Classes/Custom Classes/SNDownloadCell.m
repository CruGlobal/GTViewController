//
//  SNDownloadButton.m
//  Snuffy
//
//  Created by Michael Harrison on 12/11/11.
//  Copyright 2010 CCCA. All rights reserved.
//

#import "SNDownloadCell.h"

@interface SNDownloadCell (privateMethods)

-(void)doLayoutForReadyToDownload;
-(void)doLayoutForDownloading;
-(void)doLayoutForDownloadComplete;
-(void)doLayoutForDownloadingError;
-(void)doLayoutForReadyToDelete;
-(void)doLayoutForDisabled;

@end

@implementation SNDownloadCell

#pragma mark -
#pragma mark init Methods

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(id <SNDownloadCellDelegate>)delegate indexPath:(NSIndexPath *)indexPath {
	//NSLog(@"%@", style);
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	if (self) {
		
		self.delegate	= delegate;
		self.indexPath	= indexPath;
		
        //configure cell
		
		if ((indexPath.row % 2) == 0) {
			
			self.contentView.backgroundColor= [UIColor colorWithRed:(244.0/255.0) green:(244.0/255.0) blue:(244.0/255.0) alpha:1.0];
			
		} else {
			
			self.contentView.backgroundColor= [UIColor colorWithRed:(250.0/255.0) green:(250.0/255.0) blue:(250.0/255.0) alpha:1.0];
			
		}
        //[self setBackgroundColor:[UIColor blackColor]];
        
		//configure icon
        
        //[self.imageView setImage: [UIImage imageNamed:@"Snuffy.png"]];
        //[self.imageView setFrame:             CGRectMake(20, 4, 35, 35)];
        
		
        
		//configure title
        //[self.textLabel setFrame:       CGRectMake(50, 4, 50, 22)];
        //[self.textLabel setFont:             [UIFont fontWithName:@"System Bold" size:16]];
        //[self.textLabel setTextColor:        [UIColor blueColor]];
        //[self.textLabel setTextAlignment:    UITextAlignmentLeft];
        //[self.textLabel setText:             @"Title"];
        
        
		//configure subtitle
        //[self.detailTextLabel setFrame:    CGRectMake(50, 21, 194, 18)];
        //[self.detailTextLabel setFont:          [UIFont fontWithName:@"System" size:13]];
        //[self.detailTextLabel setTextColor:     [UIColor lightGrayColor]];
        //[self.detailTextLabel setTextAlignment: UITextAlignmentLeft];
        
		
		//configure progress bar
		UIView	*tempView	=	[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
		[tempView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"PkgDwnldScrn_Progress_Bar"]]];
        self.progressBar	=	tempView;
        //[self.progressBar setProgress:      0.00];
        //[self.progressBar setHidden:        YES];
        
        //self.progressBar = progressView;
        //[progressView release];
        
        
		//configure button
		SNDownloadButton *downloadButton = [[SNDownloadButton alloc] initWithDelegate:self andState:SNDownloadStateDownloadingError];
        //[downloadButton setFrame:   CGRectMake(265, 4, 35, 35)];
        //[downloadButton setBackgroundImage:[UIImage imageNamed:@"Snuffy_DownloadAssets_Arrow.png"] forState:UIControlStateNormal];
        [downloadButton setDownloadState:SNDownloadStateReadyToDownload];
        self.button = downloadButton;
        
        //Add the components to the view
        //[self addSubview:self.titleLabel];
        //[self addSubview:self.subtitleLabel];
        //[self addSubview:self.icon];
        [self addSubview:self.progressBar];
        [self addSubview:self.button];
        //[self addSubview:self.detailTextLabel];
	}
	
	return self;
	
}

#pragma mark -
#pragma mark Accessor Methods


-(void)setIconImage:(UIImage *)icon title:(NSString *)title subtitle:(NSString *)subtitle state:(SNDownloadStateOptions)state downloadPercentage:(CGFloat)percentage indexPath:(NSIndexPath *)indexPath {
	
	/*
    if (icon == nil) {
		
        
        //add an activity indicator to show the icons are downloading.
		[self startSpinner];
        
	} else {
		//hide the spinner
        [self stopSpinner];
        
        [self.imageView setImage:icon];
		
	}
	*/
	
	[self.textLabel setText:        title];
    //[self.textLabel setFrame:       CGRectMake(50, 4, 50, 22)];
	[self.detailTextLabel setText:  subtitle];
    
    /*
    if (self.detailTextLabel.text == @"") {
        //layout for no Subtitle
        [self.textLabel setFrame:                   CGRectMake(50, 0, 216, 44)];
        [self.detailTextLabel setFrame:             CGRectMake(50, 24, 216, 0)];
    } else {
        //layout for Subtitle
        [self.textLabel setFrame:                   CGRectMake(50, 4, 216, 28)];
        [self.detailTextLabel setFrame:             CGRectMake(50, 24, 216, 18)];
    }
     */
	
	[self setDownloadPercentage:percentage animated:YES];
	self.indexPath	= indexPath;
    
	[self setDownloadState:state];
}

-(void)startSpinner {
    [self.imageView setImage:[UIImage imageNamed:@"placeholdericon"]];
    
    if (!self.spinnerview) {
        //if the spinner does not already exist
        //add a new spinner
        self.spinnerview = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        //NSLog(@"imageView w:%f, h:%f", self.imageView.frame.size.width, self.imageView.frame.size.height);
        self.spinnerview.center = CGPointMake(22,22);
        self.spinnerview.hidesWhenStopped = YES;
        [self addSubview:self.spinnerview];
    }
    
    [self.spinnerview startAnimating];
}

-(void)stopSpinner {
    [self.spinnerview stopAnimating];
    //[self.spinnerview release];
}

-(void)setDownloadPercentage:(CGFloat)percentage animated:(BOOL)animated {
	
	CGFloat cellWidth	= self.frame.size.width;
	CGFloat barWidth	= percentage * cellWidth;
    
	NSLog(@"setDownloadPercentage: %f%%, %f", percentage, barWidth);
	
	if (animated) {
	
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:0.25];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		
	}
	
	[self.progressBar setFrame:CGRectMake(0, 0, barWidth, self.frame.size.width)];
	
	if (animated) {
	
		//run animations
		[UIView commitAnimations];
    
	}
		
    /*
    if (percentage > 0) {
        //re-configure the layout
        [self.detailTextLabel setHidden:            YES];
        [self.progressBar setHidden:                NO];
    } else {
        //hide the progress bar
        [self.progressBar setHidden:                YES];
        [self.detailTextLabel setHidden:            NO];
        
        //reshuffle labels
        //set up animation
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [self.textLabel setFrame:                   CGRectMake(50, 0, 216, 44)];
        
        //run animations
        [UIView commitAnimations];
    }
     */
}

-(void)setDownloadState:(SNDownloadStateOptions)state {
	
	self.state	= state;
	
	switch (self.state) {
		case SNDownloadStateReadyToDownload:
			
			[self doLayoutForReadyToDownload];
			
			break;
            
		case SNDownloadStateDownloading:
			NSLog(@"SNDownloadCell: setDownloadState: Downloading");
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
	NSLog(@"buttonPushedWithState");
	//pass the message on to the delegate
	if ([self.delegate respondsToSelector:@selector(buttonPushedForIndexPath:)]) {
		[self.delegate buttonPushedForIndexPath:self.indexPath];
	}
	
}

#pragma mark -
#pragma mark Mem Management Methods


@end

#pragma mark -
#pragma mark Private Methods

@implementation SNDownloadCell (privateMethods)


//layout methods

-(void)layoutSubviews {
    [super layoutSubviews];
//    NSLog(@"SNDownloadCell: layoutSubviews, state=%i", self.state);
    
    //[self setBackgroundColor:[UIColor whiteColor]];
    /*
    if (self.detailTextLabel.text == @"") {
        [self.textLabel setFrame:                   CGRectMake(50, 0, 216, 44)];
    } else {
        [self.textLabel setFrame:                   CGRectMake(50, 0, 216, 33)];
    }
    
    if (self.state == SNDownloadStateDownloading) {
        [self.textLabel setFrame:       CGRectMake(50, 0, 216, 33)];
    } 
    */
    
    //[self.textLabel setFrame:                   CGRectMake(50, 0, 216, 33)];
    [self.textLabel setBackgroundColor:         [UIColor clearColor]];
    [self.textLabel setFont:                    [UIFont systemFontOfSize:18]];
    [self.textLabel setAdjustsFontSizeToFitWidth:NO];
    [self.textLabel setMinimumScaleFactor:		13.0/18.0];
    
    //[self.detailTextLabel setFrame:             CGRectMake(50, 24, 216, 20)];
    //[self.detailTextLabel setBackgroundColor:   [UIColor clearColor]];
    //[self.detailTextLabel setText:              @"Subtitle!"];
    
    //[self.imageView setFrame:                   CGRectMake(0, 0, 43, 43)];
    
    //[self.progressBar setHidden:                YES];
    
    //[self.imageView setFrame:                   CGRectInset([self.imageView frame], 4, 4) ];
}

-(void)doLayoutForReadyToDownload {
    NSLog(@"SNDownloadCell: doLayoutForReadyToDownload");
	
	[self.imageView setImage: [UIImage imageNamed:@"PkgDwnldScrn_NotDownloaded_Badge"]];
    
    //Title textLabel
    //[self.textLabel setFrame:                   CGRectMake(50, 0, 216, 44)];
    [self.textLabel setTextColor:               [UIColor blackColor]];
    
    //Subtitle detailTextLabel
    [self.detailTextLabel setHidden:            YES];

    //[self.detailTextLabel setFrame:             CGRectMake(50, 31, 216, 13)];
    //[self.detailTextLabel setBackgroundColor:   [UIColor clearColor]];
    
    //hide the progress bar
    [self.progressBar setHidden:                YES];
    [self setDownloadPercentage:				0.0		animated:NO];
	
	//make sure selection is being displayed
	[self setSelectionStyle:					UITableViewCellSelectionStyleGray];
	
	[self.button setDownloadState:              SNDownloadStateReadyToDownload];
}

-(void)doLayoutForDownloading {
    NSLog(@"SNDownloadCell: doLayoutForDownloading");
    
	[self.imageView setImage: nil];
	
    //Title textLabel
    /*
    //animation
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:2.25];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    */
    //[self.textLabel setFrame:                   CGRectMake(50, 0, 216, 33)];
    [self.textLabel setTextColor:               [UIColor blackColor]];
    
    //[UIView commitAnimations];
    //animate
    
    //Subtitle detailTextLabel
    [self.detailTextLabel setHidden:            YES];
    
    //Progress Bar
    //[self.progressBar setFrame:                 CGRectMake(50, 31, 216, 4)];
    //[self.progressBar setHidden:                NO];
	[self setDownloadPercentage:				0.0		animated:NO];
	
	//make sure selection is being displayed
	[self setSelectionStyle:					UITableViewCellSelectionStyleGray];
	
	[self.button setDownloadState:              SNDownloadStateDownloading];
}

-(void)doLayoutForDownloadComplete {
    NSLog(@"SNDownloadCell: doLayoutForDownloadComplete");
    
	[self.imageView setImage: [UIImage imageNamed:@"PkgDwnldScrn_Downloaded_Badge"]];
	
    //Title textLabel
    //[self.textLabel setFrame:                   CGRectMake(50, 0, 216, 44)];
    [self.textLabel setTextColor:               [UIColor blackColor]];
    
    //Subtitle detailTextLabel
    [self.detailTextLabel setHidden:            YES];
    //[self.detailTextLabel setFrame:             CGRectMake(50, 24, 216, 0)];
    //[self.detailTextLabel setBackgroundColor:   [UIColor clearColor]];
    
    //hide the progress bar
    //[self.progressBar setHidden:                YES];
	[self setDownloadPercentage:				0.0		animated:NO];
	
	//make sure selection is being displayed
	[self setSelectionStyle:					UITableViewCellSelectionStyleGray];
	
	[self.button setDownloadState:SNDownloadStateDownloadComplete];
}

-(void)doLayoutForDownloadingError {
    NSLog(@"SNDownloadCell: doLayoutForDownloadingError");
    
	[self.imageView setImage: [UIImage imageNamed:@"PkgDwnldScrn_Fail_Badge"]];
	
    //Title textLabel
    //[self.textLabel setFrame:                   CGRectMake(50, 0, 216, 44)];
    [self.textLabel setTextColor:               [UIColor blackColor]];
    
    //Subtitle detailTextLabel
    [self.detailTextLabel setHidden:            YES];
    //[self.detailTextLabel setFrame:             CGRectMake(50, 24, 216, 0)];
    //[self.detailTextLabel setBackgroundColor:   [UIColor clearColor]];
    
    //hide the progress bar
    //[self.progressBar setHidden:                YES];
	[self setDownloadPercentage:				0.0		animated:YES];
	
	//make sure selection is being displayed
	[self setSelectionStyle:					UITableViewCellSelectionStyleGray];
    
	[self.button setDownloadState:              SNDownloadStateDownloadingError];
}

-(void)doLayoutForReadyToDelete {
    NSLog(@"SNDownloadCell: doLayoutForDelete");
	
	[self.imageView setImage: nil];
    
    //Title textLabel
    //[self.textLabel setFrame:                   CGRectMake(50, 0, 216, 44)];
    [self.textLabel setTextColor:               [UIColor blackColor]];
    
    //Subtitle detailTextLabel
    [self.detailTextLabel setHidden:            NO];
    //[self.detailTextLabel setFrame:             CGRectMake(50, 24, 216, 0)];
    //[self.detailTextLabel setBackgroundColor:   [UIColor clearColor]];
    
    //hide the progress bar
    //[self.progressBar setHidden:                YES];
	[self setDownloadPercentage:				0.0		animated:NO];
	
	//make sure selection is being displayed
	[self setSelectionStyle:					UITableViewCellSelectionStyleGray];
    
	[self.button setDownloadState:              SNDownloadStateReadyToDelete];
}

-(void)doLayoutForDisabled {
    NSLog(@"SNDownloadCell: doLayoutForDisabled");
	
	[self.imageView setImage: nil];
    
    //Title textLabel
    [self.textLabel setTextColor:               [UIColor darkGrayColor]];
    
    //Subtitle detailTextLabel
    //[self.detailTextLabel setTextColor:         [UIColor lightGrayColor]];
    [self.detailTextLabel setHidden:            YES];
    
    //hide the progress bar
    //[self.progressBar setHidden:                YES];
	[self setDownloadPercentage:				0.0		animated:NO];
	
	//stop selection being displayed
	[self setSelectionStyle:					UITableViewCellSelectionStyleNone];
    
	[self.button setDownloadState:              SNDownloadStateDisabled];
}


@end

