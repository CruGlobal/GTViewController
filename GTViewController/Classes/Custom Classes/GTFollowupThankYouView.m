//
//  GTFollowupThankYouView.m
//  GTViewController
//
//  Created by Ryan Carlson on 4/12/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTFollowupThankYouView.h"
#import "GTLabel.h"

#import "GTPageInterpreter.h"
#import "UISnuffleButton.h"

@implementation GTFollowupThankYouView

- (instancetype) initFromElement:(TBXMLElement *) thankYouComponentElement withFrame:(CGRect)frame withPageStyle:(GTPageStyle *)style {
    
    self = [super initWithFrame:frame];
    [self setBackgroundColor:style.backgroundColor];
    
    int thankYouCurrentY = 20;
    
    TBXMLElement *thankYouElement = thankYouComponentElement->firstChild;
    
    while (thankYouElement) {
        NSString *thankYouElementName = [TBXML elementName:thankYouElement];
        
        if ([thankYouElementName isEqual:kName_Label]) {
            UILabel *label = [[GTLabel alloc]initFromElement:thankYouElement
                                         parentTextAlignment:UITextAlignmentLeft
                                                        xPos:-1
                                                        yPos:thankYouCurrentY
                                                   container:self
                                                       style:style];
            
            thankYouCurrentY += label.frame.size.height + label.frame.origin.y + 10;
            
            [self addSubview:label];
        } else if ([thankYouElementName isEqual:@"link-button"] || [thankYouElementName isEqual:kName_Button]) {
            UISnuffleButton *button = [[UISnuffleButton alloc]createButtonFromElement:thankYouElement
                                                                               addTag:0
                                                                                 yPos:thankYouCurrentY
                                                                            container:self
                                                                            withStyle:style
                                                                    buttonTapDelegate:nil];
            
            thankYouCurrentY += button.frame.size.height + button.frame.origin.y + 10;
            
            [self addSubview:button];
        }
        
        thankYouElement = thankYouElement->nextSibling;
    }
    
    return self;
}
@end