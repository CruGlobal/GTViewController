//
//  UIMultiButtonResponseView.m
//  GTViewController
//
//  Created by Ryan Carlson on 4/6/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UIMultiButtonResponseView.h"
#import "GTFileLoader.h"

@implementation UIMultiButtonResponseView


- (instancetype) initWithFirstElement:(TBXMLElement *)firstElement secondElement:(TBXMLElement *)secondElement yPosition:(CGFloat)y containerView:(UIView *)container {
    TBXMLElement *positiveElement                  = nil;
    TBXMLElement *negativeElement                  = nil;
    
    if ([[TBXML elementName:firstElement] isEqual:@"positive-button"]) {
        positiveElement = firstElement;
        negativeElement = secondElement;
    } else {
        positiveElement = secondElement;
        negativeElement = firstElement;
    }
    
    UIMultiButtonResponseView *responseView = [super initWithFrame:CGRectMake(0, y, container.frame.size.width, 70)];

    float buttonWidth = responseView.frame.size.width / 2.5 ;
    
    UISnuffleButton *negativeButton = [self createButtonFromElement:negativeElement
                                                          withFrame:CGRectMake(10,
                                                                               responseView.frame.origin.y,
                                                                               buttonWidth,
                                                                               50)
                                                          textColor:container.backgroundColor];

    UISnuffleButton *positiveButton = [self createButtonFromElement:positiveElement
                                                          withFrame:CGRectMake(responseView.frame.size.width - 10 - buttonWidth,
                                                                               responseView.frame.origin.y,
                                                                               buttonWidth,
                                                                               50)
                                                          textColor:container.backgroundColor];
    
    [responseView addSubview:negativeButton];
    [responseView addSubview:positiveButton];
    
    return responseView;
}


- (UISnuffleButton *)createButtonFromElement:(TBXMLElement *)element withFrame:(CGRect)frame textColor:(UIColor *)textColor {
    UISnuffleButton *button = [[UISnuffleButton alloc] initWithFrame:frame];
    NSArray *tapEvents = [[TBXML valueOfAttributeNamed:@"tap-events" forElement:element] componentsSeparatedByString:@","];
    
    [button setTitle:[TBXML textForElement:element] forState:UIControlStateNormal];
    [button setTitleColor:textColor forState:UIControlStateNormal];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [button setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [button setBackgroundImage:[[GTFileLoader sharedInstance] imageWithFilename:@"URL_Button.png"] forState:UIControlStateNormal];
    [button setTapEvents:tapEvents];
    
    return button;
}
@end