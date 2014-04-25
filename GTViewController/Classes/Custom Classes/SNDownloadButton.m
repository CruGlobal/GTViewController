    //
//  SNDownloadButton.m
//  Snuffy
//
//  Created by Michael Harrison on 12/11/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//

#import "SNDownloadButton.h"

@implementation SNDownloadButton

- (id)initWithDelegate:(id)delegate andState:(SNDownloadStateOptions)state {
	
    self = [super init];
    
	if (self) {
		
		self.delegate	= delegate;
		[self clearDisplayNumber];
        
		//set up gesture detection
		[self setExclusiveTouch:YES];
        
        //set up the number display label
        self.numberLabel	= [[UILabel alloc] initWithFrame:CGRectMake(0, -4, 42, 35)];
        [self.numberLabel  setFont:            [UIFont boldSystemFontOfSize:15]];
        [self.numberLabel  setTextAlignment:   UITextAlignmentCenter];
        [self.numberLabel  setTextColor:       [UIColor blackColor]];
        //[self.numberLabel  setShadowColor:     [UIColor lightGrayColor]];
        //[self.numberLabel  setShadowOffset:    CGSizeMake(1, 1)];
        [self.numberLabel  setBackgroundColor: [UIColor clearColor]];
        
		[self addSubview:[self numberLabel]];
        
		//configure button
		[self setDownloadState:state];
		
    }
    
	return self;
}

#pragma mark -
#pragma mark User Interaction methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //[self setBackgroundImage:[UIImage imageNamed:@"Snuffy_DownloadAssets_X"]    forState:UIControlStateHighlighted];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //[self setDownloadState:self.state];
    //[self setHighlighted:NO];
	
	UITouch *touch = [touches anyObject];
	
	//when tapped pass message onto delegate
	if ([touch tapCount] > 0) {
		
		if ([self.delegate respondsToSelector:@selector(buttonPushedWithState:)]) {
			[self.delegate buttonPushedWithState:self.downloadState];
		}
		
	}
	
}

-(void)setDisplayNumber:(NSInteger)number {
	self.numberToDisplay	= number;
    if (number != -1) {
        [[self numberLabel] setText:[NSString stringWithFormat:@"%ld", (long)self.numberToDisplay]];
    } else {
        [[self numberLabel] setText:@""];
    }
}

-(void)clearDisplayNumber {
	[self setDisplayNumber: -1 ];
}

-(void)setDownloadState:(SNDownloadStateOptions)state {
    
	
	_downloadState	= state;
    
    //do button layout
    [self               setFrame:           CGRectMake(274, 4, 42, 35)];
    [self               setBackgroundColor: [UIColor clearColor]];
	
	switch (_downloadState) {
		case SNDownloadStateReadyToDownload:
            //NSLog(@"SNDownloadButton, setting state: ReadyToDownload");
            
			if (self.numberToDisplay < 0) {
				//display image for ready to download
                [self setBackgroundImage:[UIImage imageNamed:@"PkgDwnldScrn_Download_Button"]            forState:UIControlStateNormal];
                //[self setBackgroundImage:[UIImage imageNamed:@"Snuffy_DownloadAssets_Arrow_Pressed"]    forState:UIControlStateSelected];
                [self clearDisplayNumber];
			} else {
				//display number
                [self setBackgroundImage:[UIImage imageNamed:@"Snuffy_DownloadAssets_Tray"] forState:UIControlStateNormal];
                //[self setBackgroundImage:[UIImage imageNamed:@"Snuffy_DownloadAssets_Tray_Pressed"]    forState:UIControlStateSelected];
                [self setDisplayNumber:self.numberToDisplay];
			}
			
			break;
			
		case SNDownloadStateDownloading:
            //NSLog(@"SNDownloadButton, setting state: Downloading");
			//display image to invoke cancel
            [self setBackgroundImage:[UIImage imageNamed:@"PkgDwnldScrn_Cancel_Button"] forState:UIControlStateNormal];
            //[self setBackgroundImage:[UIImage imageNamed:@"Snuffy_DownloadAssets_X_Pressed"]    forState:UIControlStateSelected];
            [self clearDisplayNumber];
			break;
			
		case SNDownloadStateDownloadComplete:
            //NSLog(@"SNDownloadButton, setting state: DownloadComplete");
			//display image for download complete
            [self setBackgroundImage:[UIImage imageNamed:@"PkgDwnldScrn_Delete_Button"] forState:UIControlStateNormal];
            //[self setBackgroundImage:[UIImage imageNamed:@"Snuffy_DownloadAssets_Tick_Pressed"]    forState:UIControlStateSelected];
            [self clearDisplayNumber];
			break;
			
		case SNDownloadStateDownloadingError:
            //NSLog(@"SNDownloadButton, setting state: DownloadingError");
			//display image for downloading error
            [self setBackgroundImage:[UIImage imageNamed:@"PkgDwnldScrn_Reload_Button"] forState:UIControlStateNormal];
            //[self setBackgroundImage:[UIImage imageNamed:@"Snuffy_DownloadAssets_Bang_Pressed"]    forState:UIControlStateSelected];
            [self clearDisplayNumber];
			break;
			
		case SNDownloadStateReadyToDelete:
            
			if (self.numberToDisplay < 0) {
				//Cell Display
                [self setBackgroundImage:[UIImage imageNamed:@"PkgDwnldScrn_Delete_Button"]            forState:UIControlStateNormal];
                //[self setBackgroundImage:[UIImage imageNamed:@"Snuffy_DownloadAssets_Arrow_Pressed"]    forState:UIControlStateSelected];
                [self clearDisplayNumber];
			} else {
				//Header Display
                [self setBackgroundImage:[UIImage imageNamed:@"Snuffy_DownloadAssets_Tray_Red"] forState:UIControlStateNormal];
                //[self setBackgroundImage:[UIImage imageNamed:@"Snuffy_DownloadAssets_Tray_Pressed"]    forState:UIControlStateSelected];
                [self setDisplayNumber:self.numberToDisplay];
			}
            break;
			
		case SNDownloadStateDisabled:
            //NSLog(@"SNDownloadButton, setting state: Disabled");
			//display image for disabled
            [self setBackgroundImage:nil forState:UIControlStateNormal];
            //[self setBackgroundImage:[UIImage imageNamed:@"Snuffy_DownloadAssets_Tick_Pressed"]    forState:UIControlStateSelected];
            [self clearDisplayNumber];
			break;
			
		default:
			break;
	}
	
}


@end
