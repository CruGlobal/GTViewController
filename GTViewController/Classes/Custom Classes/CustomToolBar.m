//
//  CustomToolBar.m
//  CustomBackButton
//
//  Created by Peter Boctor on 1/11/11.
//
//  Copyright (c) 2011 Peter Boctor
// 
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE

#import "CustomToolBar.h"

#define MAX_BACK_BUTTON_WIDTH 160.0

@implementation CustomToolBar

// If we have a custom background image, then draw it, othwerwise call super and draw the standard nav bar
- (void)drawRect:(CGRect)rect {
	
	if (self.navigationBarBackgroundImage) {
		[self.navigationBarBackgroundImage.image drawInRect:rect];
	} else {
		[super drawRect:rect];
	}
}

// Save the background image and call setNeedsDisplay to force a redraw
-(void) setBackgroundWith:(UIImage*)backgroundImage {
	
	self.navigationBarBackgroundImage = [[UIImageView alloc] initWithFrame:self.frame];
	self.navigationBarBackgroundImage.image = backgroundImage;
	[self setNeedsDisplay];
	
}

// clear the background image and call setNeedsDisplay to force a redraw
-(void) clearBackground {
	
	self.navigationBarBackgroundImage = nil;
	[self setNeedsDisplay];
	
}

// With a custom back button, we have to provide the action. We simply pop the view controller
- (IBAction)back:(id)sender {
	
	[self removeFromSuperview];
	
}

// Given the prpoer images and cap width, create a variable width back button
-(UIButton *) buttonWith:(UIImage*)buttonImage highlight:(UIImage*)buttonHighlightImage leftCapWidth:(CGFloat)capWidth target:(id)target selector:(SEL)selector {
	
	if (target == nil) {
		target = self;
	}

	if (![target respondsToSelector:selector]) {
		selector = @selector(back:);
	}

	// store the cap width for use later when we set the text
	self.backButtonCapWidth = capWidth;

	// Create stretchable images for the normal and highlighted states
	UIImage* stretchedButtonImage = [buttonImage stretchableImageWithLeftCapWidth:self.backButtonCapWidth topCapHeight:0.0];
	UIImage* stretchedButtonHighlightImage = [buttonHighlightImage stretchableImageWithLeftCapWidth:self.backButtonCapWidth topCapHeight:0.0];

	// Create a custom button
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];

	// Set the title to use the same font and shadow as the standard back button
	button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
	button.titleLabel.textColor = [UIColor whiteColor];
	button.titleLabel.shadowOffset = CGSizeMake(0,-1);
	button.titleLabel.shadowColor = [UIColor darkGrayColor];
	//button.titleLabel.textAlignment = UITextAlignmentCenter;

	// Set the break mode to truncate at the end like the standard back button
	button.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;

	// Inset the title on the left and right
	button.titleEdgeInsets = UIEdgeInsetsMake(0, 3.0, 0, 3.0);

	// Make the button as high as the passed in image
	button.frame = CGRectMake(0, 0, 0, buttonImage.size.height);

	// Just like the standard back button, use the title of the previous item as the default back text
	//[self setText:self.title onBackButton:button];

	// Set the stretchable images as the background for the button
	[button setBackgroundImage:stretchedButtonImage forState:UIControlStateNormal];
	[button setBackgroundImage:stretchedButtonHighlightImage forState:UIControlStateHighlighted];
	[button setBackgroundImage:stretchedButtonHighlightImage forState:UIControlStateSelected];

	// Add an action for going back
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];

	return button;
}

// Set the text on the custom back button
-(void) setText:(NSString*)text onButton:(UIButton*)button {
	
	// Measure the width of the text
	CGSize textSize = [text sizeWithFont:button.titleLabel.font];
	// Change the button's frame. The width is either the width of the new text or the max width
	button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, (textSize.width + (self.backButtonCapWidth * 1.5)) > MAX_BACK_BUTTON_WIDTH ? MAX_BACK_BUTTON_WIDTH : (textSize.width + (self.backButtonCapWidth * 1.5)), button.frame.size.height);

	// Set the text on the button
	[button setTitle:text forState:UIControlStateNormal];
	
}


@end
