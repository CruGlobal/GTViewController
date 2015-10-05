//
//  GTPageStyle.h
//  GTViewController
//
//  Created by Michael Harrison on 10/5/15.
//  Copyright © 2015 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTPageStyle : NSObject

@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, strong) NSString *numberFontName;
@property (nonatomic, strong) NSString *headingFontName;
@property (nonatomic, strong) NSString *subheadingFontName;
@property (nonatomic, strong) NSString *peekHeadingFontName;
@property (nonatomic, strong) NSString *peekSubheadingFontName;
@property (nonatomic, strong) NSString *peekPanelFontName;
@property (nonatomic, strong) NSString *questionFontName;
@property (nonatomic, strong) NSString *straightQuestionFontName;
@property (nonatomic, strong) NSString *descriptionFontName;
@property (nonatomic, strong) NSString *instructionsFontName;
@property (nonatomic, strong) NSString *labelFontName;
@property (nonatomic, strong) NSString *boldLabelFontName;
@property (nonatomic, strong) NSString *italicsLabelFontName;
@property (nonatomic, strong) NSString *boldItalicsLabelFontName;

+ (UIColor *)colorForHex:(NSString *)hexColor;

@end
