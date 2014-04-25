//
//  SNInstructions.h
//  Snuffy
//
//  Created by Michael Harrison on 6/18/12.
//  Copyright (c) 2012 CCCA. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
	SNTextDirectionModeLeftToRight,
	SNTextDirectionModeRightToLeft
};
typedef NSUInteger SNTextDirectionMode;


@interface SNInstructions : NSObject

@property	(nonatomic, assign)	NSInteger				textDirection;

@property	(nonatomic, strong) UIView					*parentView;
@property	(nonatomic, strong) UIImageView				*pointerImage;
@property	(nonatomic, strong) UIImageView				*pointerShadowImage;
@property	(nonatomic, strong) UIImageView				*tapImage;

@property	(nonatomic, weak)	id						delegate;

@property	(nonatomic, assign)	NSInteger				counter;

-(void)showIntructionsInView:(UIView *)view forDirection:(SNTextDirectionMode)textDirection withDelegate:(id)delegate;
-(void)stopAnimations;

@end