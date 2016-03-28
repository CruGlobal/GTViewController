//
//  UISnuffleButton.m
//  Snuffy
//
//  Created by Michael Harrison on 23/07/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import "UISnuffleButton.h"
#import "snuffyViewControllerTouchNotifications.h"
#import "HorizontalGestureRecognizer.h"

//button mode constants
extern NSString * const kButtonMode_big;
extern NSString * const kButtonMode_url;
extern NSString * const kButtonMode_phone;
extern NSString * const kButtonMode_email;
extern NSString * const kButtonMode_allurl;

@interface UISnuffleButton ()

@property (nonatomic, assign) BOOL           firstMoveOfTouch;
@property (nonatomic, assign) CGPoint        startTouchPosition;
@property (nonatomic, assign) NSTimeInterval startTimeStamp;
@property (nonatomic, assign) CGPoint        lastTouchPosition;
@property (nonatomic, assign) NSTimeInterval lastTimeStamp;
@property (nonatomic, assign) double         totalHorizontalDistance;
@property (nonatomic, assign) double         horizontalSpeed;

@end

@implementation UISnuffleButton

- (instancetype)initWithFrame:(CGRect)frame tapDelegate:(id<UISnuffleButtonTapDelegate>)tapDelegate {
	
	if ((self = [self initWithFrame:frame])) {
		
        // Initialization code
		self.tapDelegate = tapDelegate;
		
    }
	
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		
    }
	
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	//start highlighting
	if ([self.mode isEqual:kButtonMode_url] || [self.mode isEqual:kButtonMode_phone] || [self.mode isEqual:kButtonMode_email] || [self.mode isEqual:kButtonMode_allurl]) {
		
		[self setHighlighted:YES];
	}
	
	if (self.startTimeStamp == 0) {
		
        self.firstMoveOfTouch        = YES;
        self.startTouchPosition      = [touch locationInView:self.tapDelegate.viewOfPageViewController];
        self.startTimeStamp          = [touch timestamp];
        self.lastTouchPosition       = [touch locationInView:self.tapDelegate.viewOfPageViewController];
        self.lastTimeStamp           = [touch timestamp];
        self.totalHorizontalDistance = 0;
        self.horizontalSpeed         = 0;
		
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	//NSLog(@"UISnuffleButton: touchesMoved");//grab the attributes of the current touch object
	NSEnumerator *touchEnum = [touches objectEnumerator];
    UITouch *touch = nil;
	CGPoint previousLocationInView;
	
	//find the touch object with the same previous value as the lastTouchPosition
	while ((touch = [touchEnum nextObject])) {
		previousLocationInView = [touch previousLocationInView:self.tapDelegate.viewOfPageViewController];
		if (previousLocationInView.x == self.lastTouchPosition.x && previousLocationInView.y == self.lastTouchPosition.y) {
			break;
		}
		touch = nil;
	}
	
	//only do calculations if we are dealing with the correct touch object
	if (touch != nil) {
		
        CGPoint currentTouchPosition    = [touch locationInView:self.tapDelegate.viewOfPageViewController];
        NSTimeInterval currentTimeStamp = [touch timestamp];

		//calculate changes in direction and time since last call to touchesMoved
        double deltaX                   = fabs(currentTouchPosition.x - self.lastTouchPosition.x);
        double deltaT                   = currentTimeStamp - self.lastTimeStamp;

		//add the current change in distance to the total distance
        self.totalHorizontalDistance    += deltaX;

		//calculate instantanious speeds
        self.horizontalSpeed            = deltaX / deltaT;
        self.lastTouchPosition          = currentTouchPosition;
        self.lastTimeStamp              = currentTimeStamp;
		
		if (self.firstMoveOfTouch) {
			
			[[NSNotificationCenter defaultCenter] postNotificationName:snuffyViewControllerTouchNotificationTouchesBegan
																object:self
															  userInfo:@{snuffyViewControllerTouchNotificationTouchesKey:	touches,
																		 snuffyViewControllerTouchNotificationEventKey:		event}];
			
			self.firstMoveOfTouch = NO;
		}
	}
	
	if (!self.firstMoveOfTouch) {
		
		[[NSNotificationCenter defaultCenter] postNotificationName:snuffyViewControllerTouchNotificationTouchesMoved
															object:self
														  userInfo:@{snuffyViewControllerTouchNotificationTouchesKey:	touches,
																	 snuffyViewControllerTouchNotificationEventKey:		event}];
		
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[self setHighlighted:NO];
	
	//grab the attributes of the current touch object
    NSEnumerator *touchEnum = [touches objectEnumerator];
    UITouch *touch          = nil;
	CGPoint previousLocationInView, locationInView;
	
	//find the touch object with the same previous value as the lastTouchPosition
	while ((touch = [touchEnum nextObject])) {
		
        previousLocationInView = [touch previousLocationInView:self.tapDelegate.viewOfPageViewController];
        locationInView         = [touch locationInView:self.tapDelegate.viewOfPageViewController];
		
		if ((previousLocationInView.x == self.lastTouchPosition.x && previousLocationInView.y == self.lastTouchPosition.y) || (locationInView.x == self.lastTouchPosition.x && locationInView.y == self.lastTouchPosition.y)) {
			
			break;
		}
		touch = nil;
	}
	
	//only do calculations if we are dealing with the correct touch object
	if (touch != nil) {
		if (([touch tapCount] == 1 && (self.horizontalSpeed < HorizontalGestureRecognizerMinSwipeSpeed)) || self.firstMoveOfTouch || (self.totalHorizontalDistance < (0.5 * CGRectGetWidth(self.tapDelegate.viewOfPageViewController.frame)) && (self.horizontalSpeed < HorizontalGestureRecognizerMinSwipeSpeed))) {
			
			//based on the mode change the callback
			if ([self.mode isEqual:kButtonMode_url]) {
				
				if ([self.tapDelegate respondsToSelector:@selector(didReceiveTapOnURLButton:)]) {
					
					[self.tapDelegate didReceiveTapOnURLButton:self];
					
				}
				
			} else if ([self.mode isEqual:kButtonMode_phone]) {
				
				if ([self.tapDelegate respondsToSelector:@selector(didReceiveTapOnPhoneButton:)]) {
					
					[self.tapDelegate didReceiveTapOnPhoneButton:self];
					
				}
				
			} else if ([self.mode isEqual:kButtonMode_email]) {
				
				if ([self.tapDelegate respondsToSelector:@selector(didReceiveTapOnEmailButton:)]) {
					
					[self.tapDelegate didReceiveTapOnEmailButton:self];
					
				}
				
			} else if ([self.mode isEqual:kButtonMode_allurl]) {
				
				if ([self.tapDelegate respondsToSelector:@selector(didReceiveTapOnAllURLButton:)]) {
					
					[self.tapDelegate didReceiveTapOnAllURLButton:self];
					
				}
				
			} else {
				
				if ([self.tapDelegate respondsToSelector:@selector(didReceiveTapOnButton:)]) {
					
					[self.tapDelegate didReceiveTapOnButton:self];
					
				}
				
			}
		}
		
		[self reset];
	}
	
	if (!self.firstMoveOfTouch) {
		
		[[NSNotificationCenter defaultCenter] postNotificationName:snuffyViewControllerTouchNotificationTouchesEnded
															object:self
														  userInfo:@{snuffyViewControllerTouchNotificationTouchesKey:	touches,
																	 snuffyViewControllerTouchNotificationEventKey:		event}];
		
	}
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[self reset];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:snuffyViewControllerTouchNotificationTouchesCancelled
														object:self
													  userInfo:@{snuffyViewControllerTouchNotificationTouchesKey:	touches,
																 snuffyViewControllerTouchNotificationEventKey:		event}];
	
}

- (void)reset {
	
	[self setHighlighted:NO];
	
    self.startTouchPosition      = CGPointZero;
    self.startTimeStamp          = 0.0;
    self.lastTouchPosition       = CGPointZero;
    self.lastTimeStamp           = 0.0;
    self.totalHorizontalDistance = 0.0;
    self.horizontalSpeed         = 0.0;
    self.firstMoveOfTouch        = NO;
	
}

@end
