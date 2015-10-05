//
//  GTPageStyle.m
//  GTViewController
//
//  Created by Michael Harrison on 10/5/15.
//  Copyright © 2015 Michael Harrison. All rights reserved.
//

#import "GTPageStyle.h"

//font constants
NSString * const kFont_number			= @"STHeitiTC-Light";
NSString * const kFont_heading			= @"Helvetica-Bold";//default
NSString * const kFont_subheading		= @"STHeitiSC-Medium";
NSString * const kFont_peekheading		= @"STHeitiTC-Light";
NSString * const kFont_peeksubheading	= @"Helvetica";
NSString * const kFont_peekpanel		= @"HelveticaNeue-BoldItalic";
NSString * const kFont_question			= @"Helvetica-BoldOblique";
NSString * const kFont_straightquestion	= @"Helvetica-Bold";
NSString * const kFont_description		= @"Helvetica-Oblique";
NSString * const kFont_instructions		= @"Helvetica-Bold";
NSString * const kFont_label			= @"Helvetica";
NSString * const kFont_boldlabel		= @"Helvetica-Bold";
NSString * const kFont_italicslabel		= @"Helvetica-Oblique";
NSString * const kFont_bolditalicslabel	= @"Helvetica-BoldOblique";

@implementation GTPageStyle

- (NSString *)numberFontName {
	return kFont_number;
}

- (NSString *)headingFontName {
	return kFont_heading;
}

- (NSString *)subheadingFontName {
	return kFont_subheading;
}

- (NSString *)peekHeadingFontName {
	return kFont_peekheading;
}

- (NSString *)peekSubheadingFontName {
	return kFont_peeksubheading;
}

- (NSString *)peekPanelFontName {
	return kFont_peekpanel;
}

- (NSString *)questionFontName {
	return kFont_question;
}

- (NSString *)straightQuestionFontName {
	return kFont_straightquestion;
}

- (NSString *)descriptionFontName {
	return kFont_description;
}

- (NSString *)instructionsFontName {
	return kFont_instructions;
}

- (NSString *)labelFontName {
	return kFont_label;
}

- (NSString *)boldLabelFontName {
	return kFont_boldlabel;
}

- (NSString *)italicsLabelFontName {
	return kFont_italicslabel;
}

- (NSString *)boldItalicsLabelFontName {
	return kFont_bolditalicslabel;
}


@end
