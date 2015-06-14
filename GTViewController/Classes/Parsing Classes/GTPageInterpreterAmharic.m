//
//  XMLParser.m
//  Snuffy
//
//  Created by Tom Flynn on 8/10/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import "GTPageInterpreterAmharic.h"

#import <sys/utsname.h>
#import "TBXML.h"
#import	"UISnuffleButton.h"
#import	"UISnufflePanel.h"
#import "UIRoundedView.h"
#import	"UIDisclosureIndicator.h"

//////////Compiler Constants///////////
#define DEFAULTOFFSET 10.0
#define DEFAULT_PANEL_OFFSET_X 0.0
#define DEFAULT_PANEL_OFFSET_Y 5.0
#define DEFAULT_QUESTION_OFFSET_X 0.0
#define DEFAULT_QUESTION_OFFSET_Y 0
#define DEFAULTOFFSET 10.0
#define BUTTONXOFFSET 10
#define	LARGEBUTTONXOFFSET 20
#define DROPSHADOW_INSET 10.0
#define ROUNDRECT_RADIUS 10.0
#define	DROPSHADOW_LENGTH 30.0
#define DROPSHADOW_SUBLENGTH 20.0

#define DEFAULT_TEXTSIZE_LABEL 17.0
#define DEFAULT_TEXTSIZE_BUTTON 20.0
#define DEFAULT_TEXTSIZE_QUESTION_NORMAL 20.0
#define DEFAULT_TEXTSIZE_QUESTION_STRAIGHT 17.0
#define DEFAULT_TEXTSIZE_TITLE_PEEKHEADING_MAX 30
#define DEFAULT_TEXTSIZE_TITLE_PEEKHEADING_MIN 6
#define DEFAULT_TEXTSIZE_TITLE_SUBHEADING 17
#define DEFAULT_TEXTSIZE_TITLE_NUMBER 68
#define DEFAULT_TEXTSIZE_TITLE_HEADING_PEEKMODE 30
#define DEFAULT_TEXTSIZE_TITLE_HEADING_NORMALMODE 17


//////////Run-Time Constants///////////

// Constants for the XML element names that will be considered during the parse.
extern NSString * const kName_Title;
extern NSString * const kName_TitleNumber;
extern NSString * const kName_TitleHeading;
extern NSString * const kName_TitleSubHeading;
extern NSString * const kName_TitlePeek;
extern NSString * const kName_Button;
extern NSString * const kName_ButtonText;
extern NSString * const kName_Label;
extern NSString * const kName_Image;
extern NSString * const kName_Panel;
extern NSString * const kName_PanelLabel;
extern NSString * const kName_PanelImage;
extern NSString * const kName_Description;
extern NSString * const kName_Instructions;
extern NSString * const kName_Question;

// Constants for the XML attribute names
extern NSString * const kAttr_backgroundImage;
extern NSString * const kAttr_numOfButtons;
extern NSString * const kAttr_numOfBigButtons;
extern NSString * const kAttr_mode;
extern NSString * const kAttr_shadows;
extern NSString * const kAttr_watermark;

extern NSString * const kAttr_color;
extern NSString * const kAttr_alpha;
extern NSString * const kAttr_textalign;
extern NSString * const kAttr_align;
extern NSString * const kAttr_size;
extern NSString * const kAttr_x;
extern NSString * const kAttr_y;
extern NSString * const kAttr_width;
extern NSString * const kAttr_height;

extern NSString * const kAttr_yoff;
extern NSString * const kAttr_xoff;

extern NSString * const kAttr_modifier;

extern NSString * const kAttr_urlText;

//text alignment constants
extern NSString * const kAlignment_left;//default
extern NSString * const kAlignment_center;
extern NSString * const kAlignment_right;

//title mode constants
extern NSString * const kTitleMode_plain;
extern NSString * const kTitleMode_singlecurve;
extern NSString * const kTitleMode_doublecurve;//default
extern NSString * const kTitleMode_straight;
extern NSString * const kTitleMode_clear;

//title mode constants
extern NSString * const kTitleMode_peek;

//button mode constants
extern NSString * const kButtonMode_big;
extern NSString * const kButtonMode_url;
extern NSString * const kButtonMode_phone;
extern NSString * const kButtonMode_email;
extern NSString * const kButtonMode_allurl;

//label modifer constants
extern NSString * const kLabelModifer_normal;
extern NSString * const kLabelModifer_bold;
extern NSString * const kLabelModifer_italics;
extern NSString * const kLabelModifer_bolditalics;

//font constants
NSString * const  GTPageInterpreterAmharicFont_number			= @"AbyssinicaSIL";
NSString * const  GTPageInterpreterAmharicFont_heading			= @"NotoSansEthiopic-Bold";//default
NSString * const  GTPageInterpreterAmharicFont_subheading		= @"AbyssinicaSIL";
NSString * const  GTPageInterpreterAmharicFont_peekheading		= @"AbyssinicaSIL";
NSString * const  GTPageInterpreterAmharicFont_peeksubheading	= @"NotoSansEthiopic";
NSString * const  GTPageInterpreterAmharicFont_peekpanel		= @"NotoSansEthiopic";
NSString * const  GTPageInterpreterAmharicFont_question			= @"NotoSansEthiopic-Bold";
NSString * const  GTPageInterpreterAmharicFont_straightquestion	= @"NotoSansEthiopic-Bold";
NSString * const  GTPageInterpreterAmharicFont_description		= @"NotoSansEthiopic";
NSString * const  GTPageInterpreterAmharicFont_instructions		= @"NotoSansEthiopic-Bold";
NSString * const  GTPageInterpreterAmharicFont_label			= @"NotoSansEthiopic";
NSString * const  GTPageInterpreterAmharicFont_boldlabel		= @"NotoSansEthiopic-Bold";
NSString * const  GTPageInterpreterAmharicFont_italicslabel		= @"NotoSansEthiopic";
NSString * const  GTPageInterpreterAmharicFont_bolditalicslabel	= @"NotoSansEthiopic-Bold";

//font sizes


@interface GTPageInterpreterAmharic ()

@property (nonatomic, strong)	GTFileLoader	*fileLoader;

@property (nonatomic, strong)	TBXML			*xmlRepresentation;
@property (nonatomic, assign)	TBXMLElement	*pageElement;

@property (nonatomic, assign)	BOOL			pageElementsHaveBeenParsed;
@property (nonatomic, assign)	BOOL			buttonElementsHaveBeenParsed;

@property (nonatomic, strong)	UIColor			*backgroundColor;
@property (nonatomic, strong)	UIView			*pageView;
@property (nonatomic, assign)	CGRect			titleFrame;
@property (nonatomic, assign)	CGRect			questionFrame;

//object creation functions (take an xml element return an iphone interface object, ie a subclass of UIView)
- (id)createButtonFromElement:					(TBXMLElement *)element		addTag:(NSInteger)tag			yPos:(CGFloat)yPos		container:(UIView *)container;
- (id)createButtonLinesFromButtonElement:		(TBXMLElement *)element		buttonTag:(NSInteger)buttonTag	yPos:(CGFloat)yPos		container:(UIView *)container;
- (id)createDisclosureIndicatorFromButtonTag:	(NSInteger)buttonTag		container:(UIView *)container;
- (id)createImageFromElement:					(TBXMLElement *)element		xPos:(CGFloat)xpostion			yPos:(CGFloat)ypostion	container:(UIView *)container;
- (id)createLabelFromElement:					(TBXMLElement *)element		parentTextAlignment:(NSTextAlignment)panelAlign			xPos:(CGFloat)xpostion			yPos:(CGFloat)ypostion	container:(UIView *)container;
- (id)createPanelFromElement:					(TBXMLElement *)element		buttonTag:(NSInteger)buttonTag;
- (id)createQuestionFromElement:				(TBXMLElement *)element		container:(UIView *)container;
- (id)createQuestionLabelFromElement:			(TBXMLElement *)element		container:(UIView *)container;
- (id)createTitleFromElement:					(TBXMLElement *)element;
- (id)createSubTitleFromElement:				(TBXMLElement *)element		underTitle:(UIView *)titleView;
- (id)createTitleNumberFromElement:				(TBXMLElement *)element		titleMode:(NSString *)titleMode;
- (id)createTitleHeadingFromElement:			(TBXMLElement *)element		titleMode:(NSString *)titleMode;
- (id)createTitleSubheadingFromElement:			(TBXMLElement *)element		titleMode:(NSString *)titleMode;
- (UILabel *)createLabelWithFrame:				(CGRect)frame				autoResize:(BOOL)resize			text:(NSString *)text	color:(UIColor *)color	bgColor:(UIColor *)bgColor	alpha:(CGFloat)alpha	alignment:(NSTextAlignment)textAlignment	font:(NSString *)font	size:(NSUInteger)size;

//attribute parsing functions
- (UIColor *)colorForHex:						(NSString *)hexColor;

@end


@implementation GTPageInterpreterAmharic

- (instancetype)initWithXMLPath:(NSString *)xmlPath fileLoader:(GTFileLoader *)fileLoader pageView:(UIView *)view panelTapDelegate:(id<UIRoundedViewTapDelegate>)panelDelegate buttonTapDelegate:(id<UISnuffleButtonTapDelegate>)buttonDelegate {
	
	self = [self init];
	if (self) {
		
		self.fileLoader			= fileLoader;
		self.panelDelegate		= panelDelegate;
		self.buttonDelegate		= buttonDelegate;
		
		//parse and store xml
		NSData *data			= [NSData dataWithContentsOfFile:xmlPath];
		self.xmlRepresentation	= [[TBXML alloc] initWithXMLData:data error:nil];
		
		//holds a reference to the view that will hold this page
		self.pageView			= view;
		
		//holds a ref to the page element
		self.pageElement		= self.xmlRepresentation.rootXMLElement;
		
		//holds a ref to the background colour
		self.backgroundColor	= [self colorForHex:[TBXML valueOfAttributeNamed:kAttr_color forElement:self.pageElement]];
		if (self.backgroundColor == nil) {
			self.backgroundColor = [UIColor yellowColor];
		}
		
		//add background image if attribute is set
		if ([TBXML valueOfAttributeNamed:kAttr_backgroundImage forElement:self.pageElement]) {
			
			UIImageView *bgimage	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:[TBXML valueOfAttributeNamed:kAttr_backgroundImage forElement:self.pageElement]]];
			[bgimage setTag:900];
			[bgimage setFrame:[self.pageView frame]];
			[self.pageView insertSubview:bgimage atIndex:0];
		}
		
		//init flags
		self.pageElementsHaveBeenParsed		= NO;
		self.buttonElementsHaveBeenParsed	= NO;
		
	}
	
	return self;
}

- (CGRect)pageFrame {
	
	return self.pageView.frame;
}

/**
 * Description: Parses xml file and stores its xml representation for later interpretation
 *				keeps a reference to the page's view, the background colour
 * param:		path - the path of the xml file to be parsed
 * param:		view - reference to the view that will display the page
 */
//- (id)initWithXMLPath:(NSString *)path pageView:(UIView *)view rootViewController:(id)rootViewController {
//	//NSLog(@"%@", path);
//	// grab instance of root view controller
//	self.snuffleViewController = rootViewController;
//
//	//parse and store xml
//	self.xmlRepresentation			= [[TBXML alloc] initWithXMLPath:path];
//
//	//holds a reference to the view that will hold this page
//	self.pageView			= view;
//
//	//holds a ref to the page element
//	self.pageElement		= self.xmlRepresentation.rootXMLElement;
//
//	//holds a ref to the background colour
//	self.backgroundColor	= [self colorForHex:[TBXML valueOfAttributeNamed:kAttr_color forElement:self.pageElement]];
//	if (self.backgroundColor == nil) {
//		self.backgroundColor = [UIColor yellowColor];
//	}
//
//	//add background image if attribute is set
//	if ([TBXML valueOfAttributeNamed:kAttr_backgroundImage forElement:self.pageElement]) {
//
//		UIImageView *bgimage	= [[UIImageView alloc] initWithImage:[[(snuffyViewController *)self.snuffleViewController fileLoader] imageWithFilename:[TBXML valueOfAttributeNamed:kAttr_backgroundImage forElement:self.pageElement]]];
//		[bgimage setTag:900];
//		[bgimage setFrame:[self.pageView frame]];
//		[self.pageView insertSubview:bgimage atIndex:0];
//	}
//
//	//init flags
//	self.pageElementsHaveBeenParsed		= NO;
//	self.buttonElementsHaveBeenParsed	= NO;
//
//	//[self parseXMLPage];
//
//	return self;
//}

-(NSMutableArray *)arrayWithUrls {
	TBXMLElement	*button_el		= [TBXML childElementNamed:kName_Button parentElement:self.pageElement];
	TBXMLElement	*savedButton_el	= nil;
	BOOL			moveToNextSibling= false;
	NSString		*button_mode	= nil;
	TBXMLElement	*urlbutton_el	= nil;
	NSMutableArray	*urlArray		= [NSMutableArray array];
	NSMutableDictionary	*urlDict	= nil;
	
	while (true) {
		
		if (button_el == nil) {
			if (savedButton_el != nil) {
				
				button_el		= [TBXML nextSiblingNamed:kName_Button searchFromElement:savedButton_el];
				savedButton_el	= nil;
				
				if (button_el == nil) {
					break;
				}
				
			} else {
				break;
			}
		}
		
		button_mode	= [TBXML valueOfAttributeNamed:kAttr_mode forElement:button_el];
		
		if (button_mode == nil) {
			savedButton_el	= button_el;
			button_el		= [TBXML childElementNamed:kName_Button parentElement:[TBXML childElementNamed:kName_Panel parentElement:button_el]];
			moveToNextSibling= false;
			urlbutton_el	= nil;
		} else if ([button_mode isEqual:kButtonMode_url]) {
			urlbutton_el	= button_el;
		} else {
			urlbutton_el	= nil;
		}
		
		if (urlbutton_el != nil) {
			
			urlDict = [NSMutableDictionary dictionary];
			
			if ([TBXML valueOfAttributeNamed:kAttr_urlText forElement:urlbutton_el] == nil) {
				[urlDict setObject:[TBXML textForElement:urlbutton_el] forKey:@"title"];
				[urlDict setObject:[TBXML textForElement:urlbutton_el] forKey:@"url"];
			} else {
				[urlDict setObject:[TBXML valueOfAttributeNamed:kAttr_urlText forElement:urlbutton_el] forKey:@"title"];
				[urlDict setObject:[TBXML textForElement:urlbutton_el] forKey:@"url"];
			}
			
			[urlArray addObject:urlDict];
			
		}
		
		if (moveToNextSibling) {
			button_el	= [TBXML nextSiblingNamed:kName_Button searchFromElement:button_el];
		}
		
		moveToNextSibling = true;
	}
	
	return urlArray;
}

#pragma mark -
#pragma mark Parser Functions

/**
 * Description: Identify all the page elements except buttons, call their 'create' functions and add them to the page's view
 */
- (void)renderPage {
	
	if (self.pageElement && !self.pageElementsHaveBeenParsed) {
		
		//init xml elements for interpretation
		TBXMLElement	*title_el			= [TBXML childElementNamed:kName_Title parentElement:self.pageElement];
		//TBXMLElement	*label_el			= [TBXML childElementNamed:kName_Label parentElement:self.pageElement];
		//TBXMLElement	*image_el			= [TBXML childElementNamed:kName_Image parentElement:self.pageElement];
		TBXMLElement	*question_el		= [TBXML childElementNamed:kName_Question parentElement:self.pageElement];
		TBXMLElement	*second_question_el	= nil;
		if (question_el != nil) {
			second_question_el				= [TBXML nextSiblingNamed:kName_Question searchFromElement:question_el];
		}
		
		//init objects that will be used to add interpreted elements to the page
		UIView			*titleView			= nil;
		UIRoundedView	*subTitleView		= nil;
        UIView          *subTitleContainer  = nil;
		UILabel			*questionLabel		= nil;
		UILabel			*secondQuestionLabel= nil;
		UIImageView		*questionShadowTop	= nil;
		UIImageView		*questionShadowBot	= nil;
		UIImageView		*question2ShadowTop	= nil;
		UIImageView		*question2ShadowBot	= nil;
		
		//grab page shadow mode
		NSString		*shadows			= [TBXML valueOfAttributeNamed:kAttr_shadows forElement:self.pageElement];
		//grab title mode
		NSString		*mode				= nil;
		
		//add shadows if the user wants them
		if (shadows == nil || [shadows isEqual:@"yes"]) {
			////Add a gradiated shadow to the top and bottom of the page
			//Create the imageviews
			UIImageView *grad_shad_top	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_top.png"]];
			UIImageView *grad_shad_bot	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_bot.png"]];
			
			//Set the imageview properties
			[grad_shad_top	setFrame:CGRectMake(CGRectGetMinX(self.pageView.frame),		CGRectGetMinY(self.pageView.frame),			self.pageView.frame.size.width,	30)];
			[grad_shad_bot	setFrame:CGRectMake(CGRectGetMinX(self.pageView.frame),		CGRectGetMaxY(self.pageView.frame) - 30,	self.pageView.frame.size.width,	30)];
			
            [grad_shad_top setTag:90];
            [grad_shad_bot setTag:91];
            
			//Insert the imageviews into the main view
			[self.pageView addSubview:grad_shad_top];
			[self.pageView addSubview:grad_shad_bot];
			
			//Put the shadow behind everything else
			//IMPORTANT: if at any other point, sendSubviewToBack is called, it will put it behind these, which may not be desirable
			
		}
		
		//set background color
		[self.pageView setBackgroundColor:self.backgroundColor];
		
		//create title from xml element
		if (title_el) {
			titleView		= [self createTitleFromElement:title_el];
			mode			= [TBXML valueOfAttributeNamed:kAttr_mode forElement:title_el];
			self.titleFrame = titleView.frame;
			subTitleView	= [self createSubTitleFromElement:title_el underTitle:titleView];
            
            //create a container view to clip the peek panel above the title
            subTitleContainer = [[UIView alloc] initWithFrame:  CGRectMake(self.titleFrame.origin.x, self.titleFrame.origin.y,    subTitleView.frame.size.width,  self.pageView.frame.size.height)];   //container in page
																																																	   //subTitleView.frame =                                CGRectMake(0,                   0,                      subTitleView.frame.size.width,  subTitleView.frame.size.height);     //peek panel in container
            [subTitleContainer setTag:550];         //make the container accessible in the page
            [subTitleView setTag:555];                //make the peek panel accessible in the container
            subTitleContainer.clipsToBounds = YES;  //clip the contents
            subTitleContainer.userInteractionEnabled = NO;
            //subTitleContainer.backgroundColor = [UIColor yellowColor];
            
            //set the title mode flags to peek
			if (subTitleView != nil && [subTitleView.titleMode isEqual:kTitleMode_peek]) {
				mode=kTitleMode_peek;
				((UIRoundedView *)(titleView)).titleMode = kTitleMode_peek;
			}
			
		} else {
			self.titleFrame = CGRectMake(0, 20, self.pageView.frame.size.width, 20);
		}
		
		//Add the subtitle (peekpanel) to the pageview
		if (subTitleView){
            
            //add the peek panel to the container
            [subTitleContainer addSubview:subTitleView];
            //add the container to the page
            [self.pageView insertSubview:subTitleContainer belowSubview:titleView];
            
            //[self.pageView addSubview:subTitleView];
            
			///TODO: use send rather than insert
            
            //[self.pageView insertSubview:[self.pageView viewWithTag:99] aboveSubview:subTitleView]; //stick the gapfiller above the subtitle
            [self.pageView insertSubview:[self.pageView viewWithTag:90] atIndex:0];           //put the top shadow to back
            [self.pageView insertSubview:[self.pageView viewWithTag:91] atIndex:0];           //put the bottom shadow to back
        }
		
		
		//create question from xml element
		if (question_el) {
			questionLabel = [self createQuestionFromElement:question_el container:nil];
			self.questionFrame = questionLabel.frame;
			
			//add shadows if its mode is straight
			if ([[TBXML valueOfAttributeNamed:kAttr_mode forElement:question_el] isEqual:kTitleMode_straight]) {
				//Create the imageviews
				questionShadowTop	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_bot.png"]];
				questionShadowBot	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_top.png"]];
				
				//Set the imageview properties
				[questionShadowTop	setFrame:CGRectMake(CGRectGetMinX(self.questionFrame),		CGRectGetMinY(self.questionFrame) - 10,		self.questionFrame.size.width,	30)];
				[questionShadowBot	setFrame:CGRectMake(CGRectGetMinX(self.questionFrame),		CGRectGetMaxY(self.questionFrame) - 5,		self.questionFrame.size.width,	30)];
			}
		} else {
			//self.questionFrame		= CGRectMake(10, self.pageView.frame.size.height - 30, 300, 10);
		}
		
		
		//create question from xml element
		if (second_question_el) {
			secondQuestionLabel		= [self createQuestionFromElement:second_question_el container:nil];
			
			//add shadows if its mode is straight
			if ([[TBXML valueOfAttributeNamed:kAttr_mode forElement:second_question_el] isEqual:kTitleMode_straight]) {
				//Create the imageviews
				question2ShadowTop	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_bot.png"]];
				question2ShadowBot	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_top.png"]];
				
				CGRect qframe = secondQuestionLabel.frame;
				
				//Set the imageview properties
				[question2ShadowTop	setFrame:CGRectMake(CGRectGetMinX(qframe),		CGRectGetMinY(qframe) - 10,		qframe.size.width,	30)];
				[question2ShadowBot	setFrame:CGRectMake(CGRectGetMinX(qframe),		CGRectGetMaxY(qframe) - 5,		qframe.size.width,	30)];
			} else {
				//destroy the second question if it is not a straight question
				secondQuestionLabel = nil;
			}
			
		}
		
		//Add the shadows to the title based on the title mode
		if ([mode isEqual:kTitleMode_doublecurve] || mode == nil) {
			////Add a gradiated shadow to the title
			//Create the imageviews
			UIImageView *grad_shad_NE	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_NE.png"]];
			UIImageView *grad_shad_E	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_E.png"]];
			UIImageView *grad_shad_SE	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_SE.png"]];
			UIImageView *grad_shad_S	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_S.png"]];
			
			//Set the imageview properties
			[grad_shad_NE	setFrame:CGRectMake(titleView.frame.origin.x + titleView.frame.size.width - 10,
												titleView.frame.origin.y,
												30.0,
												30.0 )];
			
			[grad_shad_E	setFrame:CGRectMake(titleView.frame.origin.x + titleView.frame.size.width - 10,
												grad_shad_NE.frame.origin.y		+ grad_shad_NE.frame.size.height,
												30.0,
												titleView.frame.size.height - grad_shad_NE.frame.size.height - 10 )];
			
			[grad_shad_SE	setFrame:CGRectMake(titleView.frame.origin.x + titleView.frame.size.width - 10,
												titleView.frame.origin.y + titleView.frame.size.height - 10,
												30.0,
												30.0 )];
			
			[grad_shad_S	setFrame:CGRectMake(titleView.frame.origin.x,
												grad_shad_SE.frame.origin.y,
												titleView.frame.size.width - 10,
												30.0 )];
			
			//Insert the imageviews into the main view
			[self.pageView insertSubview:grad_shad_NE	belowSubview:titleView];
			[self.pageView insertSubview:grad_shad_E	belowSubview:titleView];
			[self.pageView insertSubview:grad_shad_SE	belowSubview:titleView];
			[self.pageView insertSubview:grad_shad_S	belowSubview:titleView];
			
		} else if ([mode isEqual:kTitleMode_singlecurve]) {
			////Add a gradiated shadow to the title
			//Create the imageviews
			UIImageView *grad_shad_NE	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_NE.png"]];
			UIImageView *grad_shad_E	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_E.png"]];
			UIImageView *grad_shad_SE	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_SE.png"]];
			UIImageView *grad_shad_S	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_S.png"]];
			
			//Set the imageview properties
			[grad_shad_NE	setFrame:CGRectMake(titleView.frame.origin.x + titleView.frame.size.width - 10,
												titleView.frame.origin.y,
												30.0,
												30.0 )];
			
			[grad_shad_E	setFrame:CGRectMake(titleView.frame.origin.x + titleView.frame.size.width - 10,
												grad_shad_NE.frame.origin.y		+ grad_shad_NE.frame.size.height,
												30.0,
												titleView.frame.size.height - grad_shad_NE.frame.size.height - 10 )];
			
			[grad_shad_SE	setFrame:CGRectMake(titleView.frame.origin.x + titleView.frame.size.width - 10,
												titleView.frame.origin.y + titleView.frame.size.height - 10,
												30.0,
												30.0 )];
			
			[grad_shad_S	setFrame:CGRectMake(titleView.frame.origin.x,
												titleView.frame.origin.y + titleView.frame.size.height - 10,
												titleView.frame.size.width - 10,
												30.0 )];
			
			//Insert the imageviews into the main view
			[self.pageView insertSubview:grad_shad_NE	belowSubview:titleView];
			[self.pageView insertSubview:grad_shad_E	belowSubview:titleView];
			[self.pageView insertSubview:grad_shad_SE	belowSubview:titleView];
			[self.pageView insertSubview:grad_shad_S	belowSubview:titleView];
			
		} else if ([mode isEqual:kTitleMode_straight]) {
			////Add a gradiated shadow to the top and bottom of the title
			//Create the imageviews
			UIImageView *title_grad_shad_top	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_bot.png"]];
			UIImageView *title_grad_shad_bot	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_top.png"]];
			
			//Set the imageview properties
			[title_grad_shad_top	setFrame:CGRectMake(CGRectGetMinX(titleView.frame),		CGRectGetMinY(titleView.frame) + 10,		titleView.frame.size.width,	30)];
			[title_grad_shad_bot	setFrame:CGRectMake(CGRectGetMinX(titleView.frame),		CGRectGetMaxY(titleView.frame) - 10,		titleView.frame.size.width,	30)];
			
			//Insert the imageviews into the main view
			[self.pageView insertSubview:title_grad_shad_top belowSubview:titleView];
			[self.pageView insertSubview:title_grad_shad_bot belowSubview:titleView];
			
		} else if ([mode isEqual:kTitleMode_peek]) {
			
			
			////Add a gradiated shadow to the title
			//Create the imageviews
			UIImageView *grad_shad_NE_title		= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_NE.png"]];
			UIImageView *grad_shad_E			= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_E.png"]];
			UIImageView *grad_shad_E_title		= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_E.png"]];
			UIImageView *grad_shad_SE			= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_SE.png"]];
			UIImageView *grad_shad_SE_title		= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_SE.png"]];
			UIImageView *grad_shad_SE_static	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_SE.png"]];
			UIImageView *grad_shad_S			= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_S.png"]];
			UIImageView *grad_shad_S_title		= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_S.png"]];
			UIImageView *grad_shad_S_static		= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_S.png"]];
			
			//Set the imageview properties
			[grad_shad_NE_title		setFrame:CGRectMake(titleView.frame.size.width - DROPSHADOW_INSET,
														titleView.frame.origin.y,
														DROPSHADOW_LENGTH,
														DROPSHADOW_LENGTH
														)];
			
			[grad_shad_E			setFrame:CGRectMake(subTitleView.frame.size.width - DROPSHADOW_INSET,
														titleView.frame.size.height - (ROUNDRECT_RADIUS * 2),
														DROPSHADOW_SUBLENGTH,
														(ROUNDRECT_RADIUS * 2)
														)];
			
			[grad_shad_E_title		setFrame:CGRectMake(titleView.frame.size.width - DROPSHADOW_INSET,
														titleView.frame.origin.y + (subTitleView ? DROPSHADOW_LENGTH : 0),
														DROPSHADOW_LENGTH,
														titleView.frame.size.height - DROPSHADOW_INSET - (subTitleView ? DROPSHADOW_LENGTH : 0)
														)];
			
			[grad_shad_SE			setFrame:CGRectMake(subTitleView.frame.size.width - DROPSHADOW_INSET,
														subTitleView.frame.origin.y + subTitleView.frame.size.height - DROPSHADOW_INSET,
														DROPSHADOW_SUBLENGTH,
														DROPSHADOW_SUBLENGTH
														)];
			
			[grad_shad_SE_title		setFrame:CGRectMake(titleView.frame.origin.x + titleView.frame.size.width - DROPSHADOW_INSET,
														titleView.frame.origin.y + titleView.frame.size.height - DROPSHADOW_INSET,
														DROPSHADOW_LENGTH,
														DROPSHADOW_LENGTH
														)];
			
			[grad_shad_SE_static	setFrame:CGRectMake(titleView.frame.origin.x + titleView.frame.size.width - DROPSHADOW_SUBLENGTH,
														titleView.frame.origin.y + titleView.frame.size.height - DROPSHADOW_INSET,
														(ROUNDRECT_RADIUS * 2),
														(ROUNDRECT_RADIUS * 2)
														)];
			
			[grad_shad_S			setFrame:CGRectMake(subTitleView.frame.origin.x,
														subTitleView.frame.origin.y + subTitleView.frame.size.height - DROPSHADOW_INSET,
														subTitleView.frame.size.width - DROPSHADOW_INSET,
														DROPSHADOW_SUBLENGTH
														)];
			
			[grad_shad_S_title		setFrame:CGRectMake(titleView.frame.origin.x,
														titleView.frame.origin.y + titleView.frame.size.height - DROPSHADOW_INSET,
														titleView.frame.size.width - (subTitleView ? DROPSHADOW_SUBLENGTH : DROPSHADOW_INSET),
														(subTitleView ? (ROUNDRECT_RADIUS * 2): DROPSHADOW_LENGTH)
														)];
			
			[grad_shad_S_static		setFrame:CGRectMake(titleView.frame.origin.x,
														titleView.frame.origin.y + titleView.frame.size.height - DROPSHADOW_INSET,
														titleView.frame.size.width - DROPSHADOW_INSET,
														DROPSHADOW_LENGTH
														)];
			
			//adds tags to the shadows for later reference (550/560  + numpad location)
			[grad_shad_E            setTag:556];
			[grad_shad_E_title      setTag:566];
			[grad_shad_S            setTag:552];
			[grad_shad_S_title      setTag:562];
			[grad_shad_S_static     setTag:572];
            [grad_shad_SE           setTag:553];
			[grad_shad_SE_title     setTag:563];
            [grad_shad_SE_static    setTag:573];
			
			//Insert the imageviews into the main view
			if(subTitleView){	[self.pageView insertSubview:grad_shad_NE_title		belowSubview:titleView];}
			if(subTitleView){	[self.pageView insertSubview:grad_shad_E			belowSubview:subTitleView];}
			[self.pageView insertSubview:grad_shad_E_title		belowSubview:titleView];
			if(subTitleView){	[self.pageView insertSubview:grad_shad_SE			belowSubview:subTitleView];}
			[self.pageView insertSubview:grad_shad_SE_title		belowSubview:titleView];
			if(subTitleView){	[self.pageView insertSubview:grad_shad_SE_static	belowSubview:titleView];}
			if(subTitleView){	[self.pageView insertSubview:grad_shad_S			belowSubview:subTitleView];}
			[self.pageView insertSubview:grad_shad_S_title		belowSubview:titleView];
			if(subTitleView){	[self.pageView insertSubview:grad_shad_S_static		belowSubview:subTitleView];}
			
		}
		
		//add the question and the title to the pages view
		if (titleView)					{[self.pageView addSubview:titleView];}
		//moved up: if (subTitleView)				{[self.pageView addSubview:subTitleView];}
		if (questionLabel)				{[self.pageView insertSubview:questionLabel aboveSubview:titleView];}
		if (secondQuestionLabel)		{[self.pageView insertSubview:secondQuestionLabel aboveSubview:titleView];}
		
		//add question shadows if they are there (ie mode="straight" for the question tag)
		if (questionShadowTop != nil) {
			[self.pageView insertSubview:questionShadowTop belowSubview:questionLabel];
			[self.pageView insertSubview:questionShadowBot belowSubview:questionLabel];
		}
		
		//add question shadows if they are there (ie mode="straight" for the question tag)
		if (question2ShadowTop != nil) {
			[self.pageView insertSubview:question2ShadowTop belowSubview:secondQuestionLabel];
			[self.pageView insertSubview:question2ShadowBot belowSubview:secondQuestionLabel];
		}
		
		//set flag
		self.pageElementsHaveBeenParsed = YES;
	} else {
		//throw exception if pre requiste functions have not been called
		if (!self.pageElement) {
			NSException* parseException = [NSException exceptionWithName:@"parseException"
																  reason:@"The initialiser may not have been called yet, please check this!"
																userInfo:nil];
			@throw parseException;
		}
	}
	
}

/**
 * Description: Identify all the objects on the page, call their 'create' functions and add them to the page's view
 */
- (void)renderButtonsOnPage {
    
	if (self.pageElement && self.pageElementsHaveBeenParsed && !self.buttonElementsHaveBeenParsed) {
		
        //NSMutableArray      *pageObjects        = [NSMutableArray alloc];
        
		//init xml elements for interpretation
		TBXMLElement		*object_el			= self.pageElement->firstChild;//[TBXML childElementNamed:kName_Button parentElement:self.pageElement];
		
		//init variables for xml attributes
		NSString			*button_mode		= nil;
		
		//init objects that will be used to add interpreted elements to the page
		UIImageView			*buttonLinesTemp	= nil;
		UISnuffleButton		*buttonTemp			= nil;
		UIDisclosureIndicator *arrowTemp		= nil;
        
		UILabel             *labelLabel			= nil;
		UIImageView         *imageImage			= nil;
		
		//init variables used to hold element attribute values
		NSInteger			numOfButtons		= 0;//[[TBXML valueOfAttributeNamed:kAttr_numOfButtons forElement:self.pageElement] intValue];
		NSInteger			numOfBigButtons		= 0;//[[TBXML valueOfAttributeNamed:kAttr_numOfBigButtons forElement:self.pageElement] intValue];
        NSInteger           numOfTextLabels     = 0;
        CGFloat             combinedHeightOfTextLabels = 0;
        NSInteger           numOfImages         = 0;
		
        //NSLog(@"\nObject CountLoop:");
        
		////////////////////////////////////////////////////////
		////First loop for counting of objects for placement////
		////////////////////////////////////////////////////////
        
        //Loop through all objects in the page
        while (object_el != nil) {
            //NSLog(@"%@", [TBXML elementName:object_el]);
            
			////title
            if([[TBXML elementName:object_el] isEqual:kName_Title]) {
                //title creation is not handled here
            }
            
			////button
			if ([[TBXML elementName:object_el] isEqual:kName_Button]) {
                //get the button mode
                button_mode		= [TBXML valueOfAttributeNamed:kAttr_mode forElement:object_el];
                if ([button_mode isEqual:kButtonMode_big]) {
					numOfBigButtons++;
                } else {
                    numOfButtons++;
                }
            }
            
			////text label
            if ([[TBXML elementName:object_el] isEqual:kName_Label]) {
                numOfTextLabels++;
                
                //note: because of the unpredictable height of text labels, we need to calculate their combined height
				
                //create a temporary text label and add it's height to the tally
                labelLabel = [self createLabelFromElement:object_el parentTextAlignment:NSTextAlignmentLeft xPos:0 yPos:0 container:nil];
                combinedHeightOfTextLabels += fmaxf(labelLabel.frame.size.height,40);
                
            }
            
			////image
            if ([[TBXML elementName:object_el] isEqual:kName_Image]) {
                numOfImages++;
            }
            
            object_el = object_el->nextSibling;
            //object_el = [TBXML nextSiblingNamed:kName_Button searchFromElement:object_el];
        }
        //NSLog(@"\nCountLoop found:\n %ld regular buttons,\n %ld big buttons,\n %ld text labels,\n %ld images", (long)numOfButtons, (long)numOfBigButtons, (long)numOfTextLabels, (long)numOfImages);
        
        
		///////////////////////////////////
		//Second loop for object creation//
		///////////////////////////////////
        
		//init variables for button placment
		CGFloat				spaceBetweenObjects;
		CGFloat				previousObjectYMax;
        NSInteger           buttonCount         = 1;
        NSInteger           labelCount          = 1;
		//NSInteger			object_yoffset		= 0;
        NSInteger           object_ypos         = 0;
		//NSInteger			object_xoffset		= 0;
        NSInteger           object_xpos         = 0;
        
        //reset object_el to the first object
        object_el = self.pageElement->firstChild;//[TBXML childElementNamed:kName_Button parentElement:self.pageElement];
		
		
        //////////////////////
        ////Object Spacing////
        //////////////////////
        
        //calculate the top limit for objects to be spaced - bottom of the title, with extra if there is a peek panel
        NSInteger topOfPageSpace = ([TBXML childElementNamed:kName_TitlePeek parentElement:object_el] ? CGRectGetMaxY(self.titleFrame) + ROUNDRECT_RADIUS : CGRectGetMaxY(self.titleFrame));
        //NSLog(@"topOfPageSpace = %ld", (long)topOfPageSpace);
        
        //calculate the bottom limit for objects to be spaced - top of question if it exists, or bottom of page if it doesn't
        NSInteger bottomOfPageSpace = ([TBXML childElementNamed:kName_Question parentElement:self.pageElement] ? CGRectGetMinY(self.questionFrame) : CGRectGetMaxY(self.pageView.frame));
        //NSLog(@"bottomOfPageSpace = %ld", (long)bottomOfPageSpace);
        
        spaceBetweenObjects = round(((       bottomOfPageSpace                          // top of question/bottom of page
									  - topOfPageSpace)                          // bottom of title
									 - (numOfButtons * 40)						// combined height of normal buttons
									 - (numOfBigButtons * 140)					// combined height of big buttons
									 - combinedHeightOfTextLabels               // combined height of text labels (assuming single line of text)
									 - (numOfImages * 140))                     // combined height of images (assuming 140 height)
									/ (numOfButtons + numOfBigButtons + numOfTextLabels + numOfImages + 1));	// divided by the number of spaces needed between objects
																												//NSLog(@"spaceBetweenObjects = %f", spaceBetweenObjects);
		
        
        //set the bottom of the title for the first object
        previousObjectYMax			= topOfPageSpace; //the bottom of the title
        
        
		////Loop through all objects in the page
        while (object_el != nil) {
            
            
            
            //y position handling
            //object_yoffset = [[TBXML valueOfAttributeNamed:kAttr_yoff forElement:object_el] integerValue];
            object_ypos = [[TBXML valueOfAttributeNamed:kAttr_y forElement:object_el] integerValue];
            if (object_ypos == 0) {
                object_ypos = (previousObjectYMax + spaceBetweenObjects);
            }
			
			//x position handling
            //object_xoffset = [[TBXML valueOfAttributeNamed:kAttr_xoff forElement:object_el] integerValue];
            object_xpos = [[TBXML valueOfAttributeNamed:kAttr_x forElement:object_el] integerValue];
            if (object_xpos == 0) {
                object_xpos = (10);
            }
            
            ////TITLE
            if([[TBXML elementName:object_el] isEqual:kName_Title]) {
                //title creation is not handled here
                //NSLog(@"Title already created");
            }
            
            ////BUTTON
			if ([[TBXML elementName:object_el] isEqual:kName_Button]) {
                //get the button mode
                button_mode		= [TBXML valueOfAttributeNamed:kAttr_mode forElement:object_el];
                
                
                //create the lines around the button and add it to the page's view
                buttonLinesTemp	= [self createButtonLinesFromButtonElement:object_el buttonTag:buttonCount yPos:object_ypos container:nil];
                [self.pageView addSubview:buttonLinesTemp];
                
                //create the button and add it to the page's view
                buttonTemp		= [self createButtonFromElement:object_el addTag:buttonCount yPos:object_ypos container:nil];
                [self.pageView addSubview:buttonTemp];
                
                //create the arrow and add it to the page's view
                arrowTemp		= [self createDisclosureIndicatorFromButtonTag:buttonCount container:nil];
                [self.pageView addSubview:arrowTemp];
                
                /*
				 if ([button_mode isEqual:kButtonMode_big]) {
				 //NSLog(@"BigButton created with frame: x:%f y:%f w:%f h:%f", buttonTemp.frame.origin.x, buttonTemp.frame.origin.y, buttonTemp.frame.size.width, buttonTemp.frame.size.height);
				 } else {
				 //NSLog(@"Button created with frame: x:%f y:%f w:%f h:%f", buttonTemp.frame.origin.x, buttonTemp.frame.origin.y, buttonTemp.frame.size.width, buttonTemp.frame.size.height);
				 }
				 */
                previousObjectYMax = CGRectGetMaxY(buttonLinesTemp.frame);
                buttonCount++;
            }
            
            ////TEXT LABEL - note: some defaults are overridden here since existing text label defaults are for within panels, not page objects.
            if ([[TBXML elementName:object_el] isEqual:kName_Label]) {
                
                labelLabel = [self createLabelFromElement:object_el parentTextAlignment:NSTextAlignmentLeft xPos:object_xpos yPos:object_ypos container:nil];
                
                [labelLabel setTag:(800+labelCount)];
                if (labelLabel.alpha == 1) {
                    labelLabel.alpha = 0;
                }
                
				/*
				 //set ypos if not set in snml
				 if ([TBXML valueOfAttributeNamed:kAttr_y forElement:object_el] == nil) {
				 labelLabel.frame = CGRectMake(labelLabel.frame.origin.x, object_ypos, labelLabel.frame.size.width, labelLabel.frame.size.height);
				 }
				 
				 //set xpos if not set in snml
				 if ([TBXML valueOfAttributeNamed:kAttr_x forElement:object_el] == nil && [TBXML valueOfAttributeNamed:kAttr_align forElement:object_el] == nil ) {
				 labelLabel.frame = CGRectMake(object_xpos, labelLabel.frame.origin.y, labelLabel.frame.size.width, labelLabel.frame.size.height);
				 }
				 */
                
                //add created label
                [self.pageView insertSubview:labelLabel atIndex:1];
                
                //NSLog(@"Text Label created with frame: x:%f y:%f w:%f h:%f", buttonTemp.frame.origin.x, buttonTemp.frame.origin.y, buttonTemp.frame.size.width, buttonTemp.frame.size.height);
                //NSLog(@"Text Label created with Tag:%d", 800+labelCount);
                
                previousObjectYMax = CGRectGetMaxY(labelLabel.frame);
                labelCount++;
            }
            
            ////IMAGE
            if ([[TBXML elementName:object_el] isEqual:kName_Image]) {
                numOfImages++;
                
                imageImage = [self createImageFromElement:object_el xPos:object_xpos yPos:object_ypos container:nil];
				
				/*
				 //set ypos if not set in snml
				 if ([TBXML valueOfAttributeNamed:kAttr_y forElement:object_el] == nil) {
				 imageImage.frame = CGRectMake(imageImage.frame.origin.x, object_ypos, imageImage.frame.size.width, imageImage.frame.size.height);
				 }
				 
				 //set xpos if not set in snml
				 if ([TBXML valueOfAttributeNamed:kAttr_x forElement:object_el] == nil && [TBXML valueOfAttributeNamed:kAttr_align forElement:object_el] == nil ) {
				 imageImage.frame = CGRectMake(object_xpos, imageImage.frame.origin.y, imageImage.frame.size.width, imageImage.frame.size.height);
				 }
				 */
                
                [self.pageView insertSubview:imageImage atIndex:1];
                
                //NSLog(@"Image created with frame: x:%f y:%f w:%f h:%f", buttonTemp.frame.origin.x, buttonTemp.frame.origin.y, buttonTemp.frame.size.width, buttonTemp.frame.size.height);
                
                previousObjectYMax = CGRectGetMaxY(imageImage.frame);
            }
            
            //NSLog(@"previousObjectYMax = %f\n", previousObjectYMax);
            
            //iterate to the next object
            object_el = object_el->nextSibling;
            //object_el = [TBXML nextSiblingNamed:kName_Button searchFromElement:object_el];
            //NSLog(@"Button Loop found %d regular buttons and %d big buttons.", numOfButtons, numOfBigButtons);
			
			
        }
        
        
        /*
		 ////
		 ////process all the objects
		 
		 while (object_el != nil) {
		 //for (NSInteger buttonCount = 1; buttonCount <= (numOfButtons + numOfBigButtons); buttonCount++) {
		 
		 
		 //grab the mode of the button
		 button_mode		= [TBXML valueOfAttributeNamed:kAttr_mode forElement:object_el];
		 
		 //create the lines around the button and add it to the page's view
		 buttonLinesTemp	= [self createButtonLinesFromButtonElement:object_el buttonTag:buttonCount yPos:previousObjectYMax container:nil];
		 [self.pageView addSubview:buttonLinesTemp];
		 
		 //create the button and add it to the page's view
		 buttonTemp		= [self createButtonFromElement:object_el addTag:buttonCount yPos:previousObjectYMax container:nil];
		 [self.pageView addSubview:buttonTemp];
		 
		 //create the arrow and add it to the page's view
		 arrowTemp		= [self createDisclosureIndicatorFromButtonTag:buttonCount container:nil];
		 [self.pageView addSubview:arrowTemp];
		 
		 //clean up
		 [buttonLinesTemp release];
		 [buttonTemp release];
		 [arrowTemp release];
		 
		 //move to the next button and find the position of that button
		 object_el = [TBXML nextSiblingNamed:kName_Button searchFromElement:object_el];
		 
		 //if there is a new button and the user is setting the offset; grab offset of new button and add it to the last y position
		 if (object_el != nil && object_yoffset != nil) {
		 object_yoffset = [TBXML valueOfAttributeNamed:kAttr_yoff forElement:object_el];
		 
		 //set space to user defined or default (0)
		 if (object_yoffset != nil) {
		 spaceBetweenButtons = [object_yoffset floatValue];
		 } else {
		 spaceBetweenButtons = 0;
		 }
		 
		 }
		 //calculate the buttons position from the offset
		 previousObjectYMax += (([button_mode isEqual:kButtonMode_big] ? 140 : 40) + spaceBetweenButtons);
		 
		 object_el = object_el->nextSibling;
		 }
		 */
		
		//set flag
		self.buttonElementsHaveBeenParsed = YES;
	} else {
		//throw exception if pre requiste functions have not been called
		if (!self.pageElement) {
			NSException* parseException = [NSException exceptionWithName:@"parseException"
																  reason:@"The initialiser may not have been called yet, please check this!"
																userInfo:nil];
			@throw parseException;
		}
		
		//throw exception if pre requiste functions have not been called
		if (!self.pageElementsHaveBeenParsed) {
			NSException* parseException = [NSException exceptionWithName:@"parseException"
																  reason:@"The parseXMLPage function may not have been called yet, please check this!"
																userInfo:nil];
			@throw parseException;
		}
	}
}

//Identify the elements in the button pop-out panel and call its 'create' function
- (void)renderPanelOnPageForButtonTag:(NSInteger)tag {
	
	if (self.pageElement && self.buttonElementsHaveBeenParsed) {
		
		//init xml elements for interpretation
		TBXMLElement	*button_el			= [TBXML childElementNamed:kName_Button parentElement:self.pageElement];
		TBXMLElement	*panel_el			= nil;
		
		
		//find button
		for (NSInteger buttonCount = 1; buttonCount < tag; buttonCount++) {
			button_el				=		[TBXML nextSiblingNamed:kName_Button searchFromElement:button_el];
		}
		
		//grab xml element for panel
		panel_el					=		[TBXML childElementNamed:kName_Panel parentElement:button_el];
		
		//create, add and release panel
		UISnufflePanel		*tempPanel	=		[self createPanelFromElement:panel_el buttonTag:tag];
		if (![self.pageView viewWithTag:tempPanel.tag]) {
			[self.pageView	addSubview:tempPanel];
		}
		
	} else {
		//throw exception if pre requiste functions have not been called
		if (!self.pageElement) {
			NSException* parseException = [NSException exceptionWithName:@"parseException"
																  reason:@"The initialiser may not have been called yet, please check this!"
																userInfo:nil];
			@throw parseException;
		}
		
		//throw exception if pre requiste functions have not been called
		if (!self.buttonElementsHaveBeenParsed) {
			NSException* parseException = [NSException exceptionWithName:@"parseException"
																  reason:@"The parseXMLButtons function may not have been called yet, please check this!"
																userInfo:nil];
			@throw parseException;
		}
	}
	
}

- (UIImageView *)watermark {
	NSString *filename = [TBXML valueOfAttributeNamed:kAttr_watermark forElement:self.pageElement];
	UIImageView *watermark = nil;
	
	if (filename != nil) {
		watermark = [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:filename]];
		[watermark setFrame:self.pageView.frame];
	}
	
	return watermark;
}

#pragma mark -
#pragma mark Cache Functions

- (void)cacheImages {
	
	//NSLog(@"Caching Images...");
	TBXMLElement *element = self.pageElement;
	while (element) {
		NSString *bgImageFilename	= [TBXML valueOfAttributeNamed:kAttr_backgroundImage forElement:element];
		//NSLog(@"Caching bgimage: %@", bgImageFilename);
		NSString *watermarkFilename = [TBXML valueOfAttributeNamed:kAttr_watermark forElement:element];
		//NSLog(@"Caching watermark: %@", watermarkFilename);
		NSString *elementText		= [TBXML textForElement:element];
		//NSLog(@"Caching elementtext: %@", elementText);
		
		//NSLog(@"Caching Loop: %@:%@", [TBXML elementName:element], elementText);
		
		if (bgImageFilename) {
			[self.fileLoader cacheImageWithFileName:bgImageFilename];
		}
		if (watermarkFilename) {
			[self.fileLoader cacheImageWithFileName:watermarkFilename];
		}
		
		NSRange substrFound;
		substrFound = [[elementText lowercaseString] rangeOfString:@".png"];
		
		if (substrFound.location != NSNotFound) {
			//text contains ".png"; is an image filename
			[self.fileLoader cacheImageWithFileName:elementText];
		}
		
		
		TBXMLElement *nextelement;// = element->firstChild;
		if (element->firstChild != nil) {
			nextelement = element->firstChild;
		} else if (element->nextSibling != nil){
			nextelement = element->nextSibling;
		} else {
			
			nextelement = element->parentElement->nextSibling;
		}
		
		if (element->firstChild == nil && element->nextSibling == nil && element->parentElement->nextSibling == nil && element->parentElement->parentElement != nil) {
			nextelement = element->parentElement;
			nextelement = nextelement->parentElement->nextSibling;
		}
		
		
		element = nextelement;
		
	}
	
	
	//check for BGImg
	//Check for Watermark
	
	//Loop through every element in the page, checking for referenced images, and cache them
}

#pragma mark -
#pragma mark Create Functions

/**
 *	Description:	Creates a UISnuffleButton given a button element
 *	Parameters:		element:	The TBXMLElement that describes the button
 *					Tag:		The number that identifies the button
 *					yPos:		The y position of the button (which starts with the 2px line at the top)
 *	Returns:		A UISnuffleButton object with parameters set to what is described in the xml element.
 */
- (id)createButtonFromElement:(TBXMLElement *)element addTag:(NSInteger)tag yPos:(CGFloat)yPos container:(UIView *)container {
	
	if (element != nil) {
		
		//init variables for xml elements
		TBXMLElement						*button_label		= [TBXML childElementNamed:kName_ButtonText		parentElement:element];
		TBXMLElement						*button_image		= [TBXML childElementNamed:kName_Image			parentElement:element];
		
		//init button's xml attributes
		NSString							*mode				= [TBXML valueOfAttributeNamed:kAttr_mode		forElement:element];
		NSString							*text				= nil;
        NSString                            *urlTarget          = nil;
		NSString							*textColorString	= nil;
		NSString							*textSizeString		= nil;
		NSString							*y					= nil;
		NSString							*image				= nil;
		
		if ([mode isEqual:kButtonMode_url] || [mode isEqual:kButtonMode_email] || [mode isEqual:kButtonMode_phone]) {
			text				= [TBXML valueOfAttributeNamed:kAttr_urlText forElement:element];
            if (text == nil) {
                text            = [TBXML textForElement:element];
            } else {
                urlTarget       = [TBXML textForElement:element];
            }
			textColorString		= [TBXML valueOfAttributeNamed:kAttr_color	forElement:element];
			textSizeString		= [TBXML valueOfAttributeNamed:kAttr_size	forElement:element];
			y					= [TBXML valueOfAttributeNamed:kAttr_y		forElement:element];
		} else if ([mode isEqual:kButtonMode_allurl]) {
			text				= [TBXML textForElement:element];
			textColorString		= [TBXML valueOfAttributeNamed:kAttr_color	forElement:element];
			textSizeString		= [TBXML valueOfAttributeNamed:kAttr_size	forElement:element];
			y					= [TBXML valueOfAttributeNamed:kAttr_y		forElement:element];
		} else {
			text				= [TBXML textForElement:button_label];
			textColorString		= [TBXML valueOfAttributeNamed:kAttr_color	forElement:button_label];
			textSizeString		= [TBXML valueOfAttributeNamed:kAttr_size	forElement:button_label];
			y					= [TBXML valueOfAttributeNamed:kAttr_y		forElement:button_label];
		}
		
		//grab the image path if it exists
		if (button_image) {
			image		= [TBXML textForElement:button_image];
		}
		
		//set container to the page if not set
		if (container == nil) {
			container	= self.pageView;
		}
		
		//if y attr is set then overwrite yPos
		if (y != nil) {
			yPos		= [y floatValue];
		}
		
		//init object ptr to store the button
		UISnuffleButton						*buttonTemp			= nil;
		
		//init variables for button parameters
		UIImage								*bgImage			= nil;
		UIColor								*bgColor			= nil;
		UIColor								*textColor			= [self colorForHex:textColorString];
		CGRect								frame;
		CGFloat								size				= DEFAULT_TEXTSIZE_BUTTON;
		UIControlContentHorizontalAlignment	contentHorizontalAlignment;
		UIControlContentVerticalAlignment	contentVerticalAlignment;
		UIEdgeInsets						edgeInset			= UIEdgeInsetsZero;
		BOOL								hide				= YES;
		
		//set defaults based on mode
		if ([mode isEqual:kButtonMode_big]) {
			frame						= CGRectMake(LARGEBUTTONXOFFSET, yPos + 2, container.frame.size.width - (2 * LARGEBUTTONXOFFSET), 136);
			bgColor						= [UIColor clearColor]; //self.backgroundColor;
			if (textColor == nil) {
				textColor				= [UIColor whiteColor];
			}
			contentHorizontalAlignment	= UIControlContentHorizontalAlignmentCenter;
			contentVerticalAlignment	= UIControlContentVerticalAlignmentBottom;
			edgeInset					= UIEdgeInsetsMake(0, 0, 7, 0);
		} else if ([mode isEqual:kButtonMode_url] || [mode isEqual:kButtonMode_email] || [mode isEqual:kButtonMode_phone]) {
			frame						= CGRectMake(BUTTONXOFFSET,
                                                     yPos + 2,
                                                     container.frame.size.width - (2 * BUTTONXOFFSET),
                                                     50); //JJ: height of url button
			
			tag							+= 110;
			bgColor						= [UIColor clearColor];
			if (textColor == nil) {
				textColor				= self.backgroundColor;
			}
			if (image == nil) {
				bgImage = [self.fileLoader imageWithFilename:@"URL_Button.png"];
			}
			hide						= NO;
			contentHorizontalAlignment	= UIControlContentHorizontalAlignmentCenter;
			contentVerticalAlignment	= UIControlContentVerticalAlignmentCenter;
		} else if ([mode isEqual:kButtonMode_allurl]) {
			frame						= CGRectMake(BUTTONXOFFSET, yPos + 2, container.frame.size.width - (2 * BUTTONXOFFSET), 36);
			bgColor						= [UIColor clearColor];//self.backgroundColor;
			if (textColor == nil) {
				textColor				= [UIColor whiteColor];
			}
			contentHorizontalAlignment	= UIControlContentHorizontalAlignmentCenter;
			contentVerticalAlignment	= UIControlContentVerticalAlignmentCenter;
		} else {
			frame						= CGRectMake(BUTTONXOFFSET, yPos + 2, container.frame.size.width - (2 * BUTTONXOFFSET), 36);
			bgColor						= [UIColor clearColor];//self.backgroundColor;
			if (textColor == nil) {
				textColor				= [UIColor whiteColor];
			}
			contentHorizontalAlignment	= UIControlContentHorizontalAlignmentLeft;
			contentVerticalAlignment	= UIControlContentVerticalAlignmentCenter;
			edgeInset					= UIEdgeInsetsMake(0, 10, 0, 0);
		}
		
		
		
		//load background image if it exists
		if (image != nil) {
			bgImage = [self.fileLoader imageWithFilename:image];
		}
		
		//if size defined then multiply it by that factor
		if (textSizeString != nil) {
			size = round(size * [textSizeString floatValue] / 100);
		}
		
		//create, set up and return button
		buttonTemp = [[UISnuffleButton alloc] initWithFrame:frame tapDelegate:self.buttonDelegate];
		[buttonTemp setMode:mode];						//record the button's mode for later use
		[buttonTemp setBackgroundColor:bgColor];
		[buttonTemp setTitle:text forState:UIControlStateNormal];
        //use urlTarget if label text is specified
        if (urlTarget != nil) {
            [buttonTemp setUrlTarget:urlTarget];
        }
        
		buttonTemp.titleLabel.font = [UIFont fontWithName:GTPageInterpreterAmharicFont_label size:size];
		if (bgImage) {
			[buttonTemp setBackgroundImage:bgImage forState:UIControlStateNormal];
		}
		[buttonTemp setAdjustsImageWhenHighlighted:YES];
		[buttonTemp setTitleColor:textColor forState:UIControlStateNormal];
		[buttonTemp setContentHorizontalAlignment:contentHorizontalAlignment];
		[buttonTemp setContentVerticalAlignment:contentVerticalAlignment];
		[buttonTemp setContentEdgeInsets:edgeInset];
		[buttonTemp setTag:tag];
		[buttonTemp setHidden:hide];
		
		return buttonTemp;
		
	} else {
		return nil;
	}
}

/**
 *	Description:	Creates an image view for the lines around the button given a button element
 *	Parameters:		Tag:	The number that identifies the button associated with this disclosure indicator
 *	Returns:		A DisclosureIndicator object with parameters set to associate it with its button.
 */
- (id)createButtonLinesFromButtonElement:(TBXMLElement *)element buttonTag:(NSInteger)buttonTag yPos:(CGFloat)yPos container:(UIView *)container {
	
	if (element != nil) {
		
		//init variables for attributes
		NSString	*filename	= nil;
		NSString	*mode		= [TBXML valueOfAttributeNamed:kAttr_mode forElement:element];
		CGFloat		xPos, width, height;
		
		//set container to the page if not set
		if (container == nil) {
			container = self.pageView;
		}
		
		//set vaiables based on the button's mode
		if ([mode isEqual:kButtonMode_big]) {
			filename			= @"Buttonlines_large.png";
			xPos				= LARGEBUTTONXOFFSET;
			width				= container.frame.size.width - (2 * LARGEBUTTONXOFFSET);
			height				= 140;
		} else {
			filename			= @"Buttonlines.png";
			xPos				= BUTTONXOFFSET;
			width				= container.frame.size.width - (2 * BUTTONXOFFSET);
			height				= 40;
		}
		
		//create, set up and return button lines image
		UIImageView *buttonLinesTemp = [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:filename]];
		[buttonLinesTemp setFrame:CGRectMake(xPos, yPos, width, height)];
		[buttonLinesTemp setOpaque:NO];
		[buttonLinesTemp setTag:(30 + buttonTag)];
		[buttonLinesTemp setHidden:YES];
		
		return buttonLinesTemp;
		
	} else {
		return nil;
	}
}

/**
 *	Description:	Creates an image view from an image element
 *	Parameters:		Tag:	The number that identifies the button associated with this disclosure indicator
 *	Returns:		A DisclosureIndicator object with parameters set to associate it with its button.
 */
- (id)createDisclosureIndicatorFromButtonTag:(NSInteger)buttonTag container:(UIView *)container {
	
	//set container to the page if not set
	if (container == nil) {
		container	= self.pageView;
	}
	
	//find the Disclosure Indicator's (arrow's) button
	UISnuffleButton *arrowsButton = (UISnuffleButton *)[container viewWithTag:buttonTag];
	
	if (arrowsButton != nil && !([arrowsButton.mode isEqual:kButtonMode_allurl] || [arrowsButton.mode isEqual:kButtonMode_url])) {
		//calculate frame from the arrow's button
		CGRect frame = CGRectMake(CGRectGetMaxX(arrowsButton.frame) - 20 ,
								  CGRectGetMaxY(arrowsButton.frame) - 25,
								  14,
								  14);
		
		//create, set up and return the disclosure indicator
		UIDisclosureIndicator *arrowTemp = [[UIDisclosureIndicator alloc] initWithFrame:frame];
		[arrowTemp setBackgroundColor:[UIColor clearColor]];
		[arrowTemp setTag:(20 + buttonTag)];
		[arrowTemp setHidden:YES];
		
		return arrowTemp;
		
	} else {
		return nil;
	}
}

/**
 *	Description:	Creates an image view from an image element
 *	Parameters:		Element:	The TBXMLElement for the image
 *	Returns:		A UIImageView object from the attributes specified in the passed TBXML element.
 */
- (id)createImageFromElement:(TBXMLElement *)element xPos:(CGFloat)xpostion yPos:(CGFloat)ypostion container:(UIView *)container {
	
	//set container to the page if not set
	if (container == nil) {
		container	= self.pageView;
	}
	
	//set default value if not set
	if (!(xpostion >= 0)) {
		xpostion = DEFAULT_PANEL_OFFSET_X;
	}
	
	if (!(ypostion >= 0)) {
		ypostion = DEFAULT_PANEL_OFFSET_Y;
	}
	
	if (element != nil) {
		//NSLog(@"%@",[TBXML textForElement:element]);
		
		NSString	*filename	=						[TBXML textForElement:element];
		NSString	*align		=						[TBXML valueOfAttributeNamed:kAttr_align	forElement:element];
		CGFloat		x			=						[[TBXML valueOfAttributeNamed:kAttr_x		forElement:element] floatValue];
		CGFloat		y			=						[[TBXML valueOfAttributeNamed:kAttr_y		forElement:element] floatValue];
		CGFloat		w			=						[[TBXML valueOfAttributeNamed:kAttr_width	forElement:element] floatValue];
		CGFloat		h			=						[[TBXML valueOfAttributeNamed:kAttr_height	forElement:element] floatValue];
		CGFloat		xoffset		=						round([[TBXML valueOfAttributeNamed:kAttr_xoff		forElement:element] floatValue]);
		CGFloat		yoffset		=						round([[TBXML valueOfAttributeNamed:kAttr_yoff		forElement:element] floatValue]);
		
		//load the image into an image view
		UIImageView *imageTemp = [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:filename]];
		
		x						=						(x == 0 ? xpostion						: x);
		y						=						(y == 0 ? ypostion						: y);
		w						=						(w == 0 ? imageTemp.frame.size.width	: w);
		h						=						(h == 0 ? imageTemp.frame.size.height	: h);
		
		//grab frame from attributes
		CGRect tempFrame =  CGRectMake(x,
									   y,
									   w,
									   h);
		
		//if alignment is found calculate position based on alignment
		if ([align isEqualToString:kAlignment_left]) {
			
			tempFrame	= CGRectMake( DEFAULT_PANEL_OFFSET_X, y, w, h);
			
		} else if ([align isEqualToString:kAlignment_center]) {
			
			tempFrame	= CGRectMake( ( 0.5 * container.frame.size.width ) - ( 0.5 * w ), y, w, h);
			
		} else if ([align isEqualToString:kAlignment_right]) {
			
			tempFrame	= CGRectMake( container.frame.size.width - w - DEFAULT_PANEL_OFFSET_X, y, w, h);
			
		}
		
		//apply offset
		tempFrame.origin.x			+= xoffset;
		tempFrame.origin.y			+= yoffset;
		
		if (!CGRectIsEmpty(tempFrame)) {
			[imageTemp setFrame:tempFrame];
		}
		
		//set up image
		[imageTemp setBackgroundColor:[UIColor clearColor]];
		
		return imageTemp;
		
	} else {
		return nil;
	}
	
}

/**
 *	Description:	Creates an UILabel from a label element
 *	Parameters:		Element:	The TBXMLElement for the label
 *	Returns:		A UILabel object from the attributes specified in the passed TBXML element.
 */
- (id)createLabelFromElement:(TBXMLElement *)element parentTextAlignment:(NSTextAlignment)panelAlign xPos:(CGFloat)xpostion yPos:(CGFloat)ypostion container:(UIView *)container {
	
	//set container to the page if not set
	if (container == nil) {
		container	= self.pageView;
	}
	
	//set default value if not set
	if (!(xpostion >= 0)) {
		xpostion = DEFAULT_PANEL_OFFSET_X;
	}
	
	if (!(ypostion >= 0)) {
		ypostion = DEFAULT_PANEL_OFFSET_Y;
	}
	
	if (element != nil) {
		
		//read attributes for label
		NSString	*text		=						[TBXML textForElement:element];
		NSString	*modifier	=						[TBXML valueOfAttributeNamed:kAttr_modifier forElement:element];
		UIColor		*color		=	[self colorForHex:	[TBXML valueOfAttributeNamed:kAttr_color	forElement:element]];
		NSString	*alpha		=						[TBXML valueOfAttributeNamed:kAttr_alpha	forElement:element];
		NSString	*align		=						[TBXML valueOfAttributeNamed:kAttr_align	forElement:element];
		NSString	*textalign	=						[TBXML valueOfAttributeNamed:kAttr_textalign	forElement:element];
		NSString	*size		=						[TBXML valueOfAttributeNamed:kAttr_size		forElement:element];
		NSString	*x			=						[TBXML valueOfAttributeNamed:kAttr_x		forElement:element];
		NSString	*y			=						[TBXML valueOfAttributeNamed:kAttr_y		forElement:element];
		NSString	*w			=						[TBXML valueOfAttributeNamed:kAttr_width	forElement:element];
		NSString	*h			=						[TBXML valueOfAttributeNamed:kAttr_height	forElement:element];
		CGFloat		xoffset		=						round([[TBXML valueOfAttributeNamed:kAttr_xoff		forElement:element] floatValue]);
		CGFloat		yoffset		=						round([[TBXML valueOfAttributeNamed:kAttr_yoff		forElement:element] floatValue]);
		
		//init variables for object parameters
		CGRect			frame			= CGRectZero;
		NSTextAlignment textAlignment	= panelAlign;
		BOOL			resize			= YES;
		UIColor			*bgColor		= nil;
		NSUInteger		textSize		= DEFAULT_TEXTSIZE_LABEL;
		NSString		*font			=  GTPageInterpreterAmharicFont_label;
		CGFloat			labelAlpha		= 1.0;
		
		//set parameters to attribute val or defaults	//attribute value															//default value
		//note: these defaults only apply to text labels inside panels
        if		(x)										{frame.origin.x		=	round([x floatValue]);}								else	{frame.origin.x		= xpostion;}
		if		(y)										{frame.origin.y		=	round([y floatValue]);}								else	{frame.origin.y		= ypostion;}
		if		(w)										{frame.size.width	=	round([w floatValue]);}								else	{frame.size.width	= 280;}
		if		(h)										{frame.size.height	=	round([h floatValue]);}								else	{frame.size.height	= 40;}
		if		((w != nil) && (h != nil))				{resize				= NO;}
		
		if		(!bgColor)																											{bgColor			= [UIColor clearColor];}
		if		(!color)																											{color				= [UIColor whiteColor];}
		if		(size)									{textSize			= round(textSize * [size floatValue] / 100);}
		
		//if alignment is found calculate position based on alignment
		if ([align isEqualToString:kAlignment_left]) {
			
			frame.origin.x		= DEFAULT_PANEL_OFFSET_X;
			
		} else if ([align isEqualToString:kAlignment_center]) {
			
			frame.origin.x		= ( 0.5 * container.frame.size.width ) - ( 0.5 * frame.size.width );
			
		} else if ([align isEqualToString:kAlignment_right]) {
			
			frame.origin.x		= container.frame.size.width - frame.size.width - DEFAULT_PANEL_OFFSET_X;
			
		}
		
		//apply offset
		frame.origin.x			+= xoffset;
		frame.origin.y			+= yoffset;
		
		if (alpha) {
			labelAlpha = [alpha floatValue];
		}
		
		if (modifier) {
			if		([modifier isEqual:kLabelModifer_bold])			{font		=  GTPageInterpreterAmharicFont_boldlabel;}
			else if	([modifier isEqual:kLabelModifer_italics])		{font		=  GTPageInterpreterAmharicFont_italicslabel;}
			else if	([modifier isEqual:kLabelModifer_bolditalics])	{font		=  GTPageInterpreterAmharicFont_bolditalicslabel;}
		}
		
		if (textalign) {
			if		([textalign isEqual:kAlignment_right])	{textAlignment		= NSTextAlignmentRight;}
			else if ([textalign isEqual:kAlignment_center])	{textAlignment		= NSTextAlignmentCenter;}
			else if ([textalign isEqual:kAlignment_left])	{textAlignment		= NSTextAlignmentLeft;}
		}
		
		
		return [self createLabelWithFrame:frame autoResize:resize text:text color:color bgColor:bgColor alpha:labelAlpha alignment:textAlignment font:font size:textSize];
		
	} else {
		return nil;
	}
	
}

/**
 *	Description:	Creates an UISnufflePanel from a panel element
 *	Parameters:		Element:	The TBXMLElement for the panel
 *	Returns:		A UISnufflePanel object from the attributes specified in the passed TBXML element.
 */
- (id)createPanelFromElement:(TBXMLElement *)element buttonTag:(NSInteger)buttonTag {
	
	//if panel exists create panel
	if (element) {
		
		//Fetch and store the panel's text alignment
		NSString		*panel_alignment	= [TBXML valueOfAttributeNamed:kAttr_textalign	forElement:element];
		NSTextAlignment	panelAlign;
		if ([panel_alignment isEqual:kAlignment_left]) {
			panelAlign = NSTextAlignmentLeft;
		} else if ([panel_alignment isEqual:kAlignment_center]) {
			panelAlign = NSTextAlignmentCenter;
		} else if ([panel_alignment isEqual:kAlignment_right]) {
			panelAlign = NSTextAlignmentRight;
		} else {
			panelAlign = NSTextAlignmentLeft;
		}
		
		//init objects that will be used to add interpreted elements to the page
		UILabel			*labelTemp			= nil;
		UIImageView		*imageTemp			= nil;
		UISnuffleButton	*buttonTemp			= nil;
		
		//init variables for xml attributes
		CGFloat			maxWidth			= 0;
		CGFloat			maxHeight			= 0;
		
		UISnufflePanel	*tempPanel			=	[[UISnufflePanel alloc] init];
		UIView			*tempContainerView	=	[[UIView alloc] initWithFrame:CGRectMake(5, 5, 280, 5)];
		
		//init variables for button placment
		CGFloat				spaceBetweenObjects = 10.0;
		CGFloat				previousObjectYMax	= 0.0;
        NSInteger           object_ypos         = 0;
        NSInteger           object_xpos         = 0;
        
        //set object_el to the first object
		TBXMLElement		*object_el				= element->firstChild;
        
		////Loop through all objects in the panel
        while (object_el != nil) {
            
            //y position handling
            //object_yoffset = [[TBXML valueOfAttributeNamed:kAttr_yoff forElement:object_el] integerValue];
            object_ypos = [[TBXML valueOfAttributeNamed:kAttr_y forElement:object_el] integerValue];
            if (object_ypos == 0) {
                object_ypos = (previousObjectYMax + spaceBetweenObjects);
            }
			
			//x position handling
            //object_xoffset = [[TBXML valueOfAttributeNamed:kAttr_xoff forElement:object_el] integerValue];
            object_xpos = [[TBXML valueOfAttributeNamed:kAttr_x forElement:object_el] integerValue];
            if (object_xpos == 0) {
                object_xpos = (0);
            }
            
            ////BUTTON
			if ([[TBXML elementName:object_el] isEqual:kName_Button]) {
				
				//create image
				buttonTemp			= [self createButtonFromElement:object_el addTag:buttonTag yPos:object_ypos container:tempContainerView];
				
				//store the maximum dimensions
				maxWidth			= fmaxf(maxWidth, CGRectGetMaxX(buttonTemp.frame));
				maxHeight			= fmaxf(maxHeight, CGRectGetMaxY(buttonTemp.frame));
				
				previousObjectYMax	= CGRectGetMaxY(buttonTemp.frame);
				
				//add to container
				[tempContainerView addSubview:buttonTemp];
				
            }
            
            ////TEXT LABEL - note: some defaults are overridden here since existing text label defaults are for within panels, not page objects.
            if ([[TBXML elementName:object_el] isEqual:kName_Label]) {
                
                //create label
				labelTemp			= [self createLabelFromElement:object_el parentTextAlignment:panelAlign xPos:object_xpos yPos:object_ypos container:tempContainerView];
				
				//store the maximum dimensions
				maxWidth			= fmaxf(maxWidth, CGRectGetMaxX(labelTemp.frame));
				maxHeight			= fmaxf(maxHeight, CGRectGetMaxY(labelTemp.frame));
				
				previousObjectYMax	= CGRectGetMaxY(labelTemp.frame);
				
				//add to container
				[tempContainerView addSubview:labelTemp];
				
            }
            
            ////IMAGE
            if ([[TBXML elementName:object_el] isEqual:kName_Image]) {
                
				//create image
				imageTemp			= [self createImageFromElement:object_el xPos:object_xpos yPos:object_ypos container:tempContainerView];
				
				//store the maximum dimensions
				maxWidth			= fmaxf(maxWidth, CGRectGetMaxX(imageTemp.frame));
				maxHeight			= fmaxf(maxHeight, CGRectGetMaxY(imageTemp.frame));
				
				previousObjectYMax	= CGRectGetMaxY(imageTemp.frame);
				
				//add to container
				[tempContainerView addSubview:imageTemp];
				
            }
            
            //NSLog(@"previousObjectYMax = %f\n", previousObjectYMax);
            
            //iterate to the next object
            object_el = object_el->nextSibling;
			
			
        }
		
		//set up container view
		[tempContainerView setFrame:CGRectMake(5, 5, fmaxf(280, maxWidth), maxHeight+5)];
		[tempContainerView setBackgroundColor:[UIColor clearColor]];
		[tempContainerView setTag:(100 + buttonTag)];
		
		//set up panel
		[tempPanel setFrame:tempContainerView.frame];
		[tempPanel setBackgroundColor:self.backgroundColor];
		[tempPanel setTag:(1000 + buttonTag)];
		[tempPanel setHidden:YES];
		[tempPanel setAlpha:0.0];
		
		//add views
		[tempPanel addSubview:tempContainerView];
		
		return tempPanel;
		
	} else {
		return nil;
	}
}

- (id)createQuestionFromElement:(TBXMLElement *)element container:(UIView *)container {
	
	//set container to the page if not set
	if (container == nil) {
		container	= self.pageView;
	}
	
	if (element != nil) {
		
		UIView			*questionContainer	=	[[UIView alloc] init];
		UILabel			*tempLabel			=	nil;
		TBXMLElement	*label_el			=	[TBXML childElementNamed:kName_Label		parentElement:element];
		NSString		*mode				=	[TBXML valueOfAttributeNamed:kAttr_mode		forElement:element];
		NSInteger		numOfLabels			=	0;
		NSUInteger		tag					=	10;
		CGFloat			maxY				=	0;
		
		mode				=	(mode == nil ? @"" : mode);
		
		//if the question is made up of labels, put them in the container
		while (label_el) {
			//create label from element
			tempLabel = [self createQuestionLabelFromElement:label_el container:questionContainer];
			
			//record max y
			maxY = fmaxf(maxY, CGRectGetMaxY(tempLabel.frame));
			
			//add label to container
			[questionContainer addSubview:tempLabel];
			
			//increament
			label_el = [TBXML nextSiblingNamed:kName_Label searchFromElement:label_el];
			numOfLabels++;
		}
		
		//if there were labels finish configuring the container else set the container to be a straight question label
		if (numOfLabels > 0) {
			NSString	*x			=	[TBXML valueOfAttributeNamed:kAttr_x		forElement:element];
			NSString	*y			=	[TBXML valueOfAttributeNamed:kAttr_y		forElement:element];
			NSString	*w			=	[TBXML valueOfAttributeNamed:kAttr_width	forElement:element];
			NSString	*h			=	[TBXML valueOfAttributeNamed:kAttr_height	forElement:element];
			NSString	*align		=	[TBXML valueOfAttributeNamed:kAttr_align	forElement:element];
			CGRect		frame		=	CGRectZero;
			
			if		(x)				{frame.origin.x		=	round([x floatValue]);}	else	{frame.origin.x		= DEFAULT_QUESTION_OFFSET_X;}
			if		(y)				{frame.origin.y		=	round([y floatValue]);}	else	{frame.origin.y		= container.frame.size.height - maxY - DEFAULT_QUESTION_OFFSET_Y;}
			if		(w)				{frame.size.width	=	round([w floatValue]);}	else	{frame.size.width	= container.frame.size.width;}
			if		(h)				{frame.size.height	=	round([h floatValue]);}	else	{frame.size.height	= maxY + 5;}
			
			questionContainer.frame	=	frame;
			[questionContainer setBackgroundColor:[UIColor clearColor]];
			
			//add properties to space the question out better and to let the animation code know it needs to be faded in
			if ([mode isEqual:kTitleMode_straight]) {
				
				tag = 0;
				
			}
			
			//if the question can be aligned then align it
			if (![mode isEqual:kTitleMode_straight] && frame.size.width < container.frame.size.width) {
				
				//if alignment is found calculate position based on alignment
				if ([align isEqualToString:kAlignment_left]) {
					
					frame.origin.x		= DEFAULT_QUESTION_OFFSET_X;
					
				} else if ([align isEqualToString:kAlignment_center]) {
					
					frame.origin.x		= ( 0.5 * container.frame.size.width ) - ( 0.5 * frame.size.width );
					
				} else if ([align isEqualToString:kAlignment_right]) {
					
					frame.origin.x		= container.frame.size.width - frame.size.width - DEFAULT_QUESTION_OFFSET_X;
					
				}
				
			}
			
			[questionContainer setTag:tag];
			if (tag != 0) {[questionContainer setHidden:YES];}
			if (y == nil) {
				questionContainer.frame = CGRectMake(questionContainer.frame.origin.x,
													 container.frame.size.height - 20 - questionContainer.frame.size.height - 10,
													 questionContainer.frame.size.width,
													 questionContainer.frame.size.height + 10);
			}
			
		} else {
			
			questionContainer		=	[self createQuestionLabelFromElement:element container:container];
			
			//add properties to space the question out better and to let the animation code know it needs to be faded in
			if ([mode isEqual:kTitleMode_straight]) {tag = 0;}
			[questionContainer setTag:tag];
			if (tag != 0) {[questionContainer setHidden:YES];}
			questionContainer.frame = CGRectMake(questionContainer.frame.origin.x,
												 container.frame.size.height - 20 - questionContainer.frame.size.height - 10,
												 container.frame.size.width - (questionContainer.frame.origin.x * 2),
												 questionContainer.frame.size.height + 10);
		}
		
		return questionContainer;
		
	} else {
		return nil;
	}
	
}

- (id)createQuestionLabelFromElement:(TBXMLElement *)element container:(UIView *)container {
	
	//set container to the page if not set
	if (container == nil) {
		container	= self.pageView;
	}
	
	if (element != nil) {
		//read attributes for label
		NSString	*text		=						[TBXML textForElement:element];
		NSString	*mode		=						[TBXML valueOfAttributeNamed:kAttr_mode		forElement:element];
		UIColor		*color		=	[self colorForHex:	[TBXML valueOfAttributeNamed:kAttr_color	forElement:element]];
		NSString	*modifier	=						[TBXML valueOfAttributeNamed:kAttr_modifier	forElement:element];
		NSString	*alpha		=						[TBXML valueOfAttributeNamed:kAttr_alpha	forElement:element];
		NSString	*align		=						[TBXML valueOfAttributeNamed:kAttr_align	forElement:element];
		NSString	*textalign	=						[TBXML valueOfAttributeNamed:kAttr_textalign	forElement:element];
		NSString	*size		=						[TBXML valueOfAttributeNamed:kAttr_size		forElement:element];
		NSString	*x			=						[TBXML valueOfAttributeNamed:kAttr_x		forElement:element];
		NSString	*y			=						[TBXML valueOfAttributeNamed:kAttr_y		forElement:element];
		NSString	*w			=						[TBXML valueOfAttributeNamed:kAttr_width	forElement:element];
		NSString	*h			=						[TBXML valueOfAttributeNamed:kAttr_height	forElement:element];
		
		mode		=						(mode == nil ? @"" : mode);
		
		CGRect			frame			= CGRectZero;
		NSTextAlignment textAlignment	= NSTextAlignmentRight;
		BOOL			resize			= YES;
		UIColor			*bgColor		= nil;
		NSUInteger		textSize		= DEFAULT_TEXTSIZE_QUESTION_NORMAL;
		NSString		*font			=  GTPageInterpreterAmharicFont_question;
		CGFloat			labelAlpha		= 1.0;
		
		//overwrite defaults with user set values (xml attributes)
		if		(x)										{frame.origin.x		=	round([x floatValue]);}								else	{frame.origin.x		= 10;}
		if		(y)										{frame.origin.y		=	round([y floatValue]);}								else	{frame.origin.y		= 364;}
		if		(w)										{frame.size.width	=	round([w floatValue]);}								else	{frame.size.width	= 300;}
		if		(h)										{frame.size.height	=	round([h floatValue]);}								else	{frame.size.height	= 76;}
		if		((w != nil) && (h != nil))				{resize				= NO;}
		
		if		(!bgColor)																								{bgColor			= [UIColor clearColor];}
		if		(!color)																								{color				= [UIColor whiteColor];}
		if		(size)									{textSize			= round(textSize * [size floatValue] / 100);}
		
		if (alpha) {
			labelAlpha = [alpha floatValue];
		}
		
		if (textalign) {
			if		([textalign isEqual:kAlignment_right])	{textAlignment		= NSTextAlignmentRight;}
			else if ([textalign isEqual:kAlignment_center])	{textAlignment		= NSTextAlignmentCenter;}
			else if ([textalign isEqual:kAlignment_left])	{textAlignment		= NSTextAlignmentLeft;}
		}																										else	{textAlignment		= NSTextAlignmentRight;}
		
		if		([mode isEqual:kTitleMode_straight]) {
			bgColor = [UIColor whiteColor];
			color = self.backgroundColor;
			textSize = round(DEFAULT_TEXTSIZE_QUESTION_STRAIGHT * [size floatValue] / 100);
			font =  GTPageInterpreterAmharicFont_straightquestion;
			frame = CGRectMake(0, frame.origin.y, 320, frame.size.height);
			textAlignment = NSTextAlignmentCenter;
		}
		
		//if the question can be aligned then align it
		if (![mode isEqual:kTitleMode_straight] && frame.size.width < container.frame.size.width) {
			
			//if alignment is found calculate position based on alignment
			if ([align isEqualToString:kAlignment_left]) {
				
				frame.origin.x		= DEFAULT_QUESTION_OFFSET_X;
				
			} else if ([align isEqualToString:kAlignment_center]) {
				
				frame.origin.x		= ( 0.5 * container.frame.size.width ) - ( 0.5 * frame.size.width );
				
			} else if ([align isEqualToString:kAlignment_right]) {
				
				frame.origin.x		= container.frame.size.width - frame.size.width - DEFAULT_QUESTION_OFFSET_X;
				
			}
			
		}
		
		if (modifier) {
			if ([modifier isEqual:kLabelModifer_bold]) {
				font =  GTPageInterpreterAmharicFont_boldlabel;
			} else if ([modifier isEqual:kLabelModifer_italics]) {
				font =  GTPageInterpreterAmharicFont_italicslabel;
			} else if ([modifier isEqual:kLabelModifer_bolditalics]) {
				font =  GTPageInterpreterAmharicFont_bolditalicslabel;
			} else if ([modifier isEqual:kLabelModifer_normal]) {
				font =  GTPageInterpreterAmharicFont_label;
			}
		}
		
		return [self createLabelWithFrame:frame autoResize:resize text:text color:color bgColor:bgColor alpha:labelAlpha alignment:textAlignment font:font size:textSize];
		
	} else {
		return nil;
	}
}

- (id)createTitleFromElement:(TBXMLElement *)element {
	
	
	if (element) {
		UIRoundedView	*titleContainer		= nil;
		
		NSString		*mode				= [TBXML valueOfAttributeNamed:kAttr_mode			forElement:element];
		
		TBXMLElement	*title_number		= [TBXML childElementNamed:kName_TitleNumber		parentElement:element];
		TBXMLElement	*title_heading		= [TBXML childElementNamed:kName_TitleHeading		parentElement:element];
		TBXMLElement	*title_subheading	= [TBXML childElementNamed:kName_TitleSubHeading	parentElement:element];
		NSInteger		xmltitleheight		= [[TBXML valueOfAttributeNamed:kAttr_height		forElement:element] intValue];
		
		UILabel	*tempNumber			= nil;
		UILabel *tempHeading		= nil;
		UILabel	*tempSubHeading		= nil;
		
		if (title_number)		{tempNumber		= [self createTitleNumberFromElement:title_number			titleMode:mode];}
		if (title_heading)		{tempHeading	= [self createTitleHeadingFromElement:title_heading			titleMode:mode];}
		if (title_subheading)	{tempSubHeading	= [self createTitleSubheadingFromElement:title_subheading	titleMode:mode];}
		
		//Uses a loop to find the right size for the heading to fit on 3 lines
		if ([mode isEqual:kTitleMode_peek]) {
			NSArray *textArray = [tempHeading.text componentsSeparatedByString:@" "];
			NSInteger numberoflines = [textArray count];
			
			tempHeading.text = [textArray componentsJoinedByString:@"\n"];
			
			UIFont *tempFont = [UIFont fontWithName: GTPageInterpreterAmharicFont_peekheading size:DEFAULT_TEXTSIZE_TITLE_PEEKHEADING_MAX];
			int i;
			CGSize labelsize;
			for (i=DEFAULT_TEXTSIZE_TITLE_PEEKHEADING_MAX; i> DEFAULT_TEXTSIZE_TITLE_PEEKHEADING_MIN; i=i-1) {
				tempFont = [tempFont fontWithSize:i];
				CGSize constraintSize = CGSizeMake(tempHeading.frame.size.width, MAXFLOAT);
				//NSLog(@"Constraint Width: %f",constraintSize.width);
				labelsize = [tempHeading.text sizeWithFont:tempFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
				
				if (labelsize.height <= (numberoflines*tempFont.pointSize+10)){
					//NSLog(@"Final Width: %f",labelsize.width);
					break;
				}
			}
			if (numberoflines > 1) {
				tempHeading.frame = CGRectMake(tempHeading.frame.origin.x, tempHeading.frame.origin.y, labelsize.width, labelsize.height);
				tempHeading.font = tempFont;
			}
			
			
			//resize the heading to fit the text
			//[tempHeading sizeToFit];
			
			tempSubHeading.frame			= CGRectMake(CGRectGetMaxX(tempHeading.frame) + 11,
														 tempSubHeading.frame.origin.y,
														 self.pageView.frame.size.width - 20 - tempSubHeading.frame.origin.x - 11,
														 fmaxf(tempSubHeading.frame.size.height + 10,labelsize.height + 20));
			tempHeading.frame				= CGRectMake(tempHeading.frame.origin.x,
														 tempHeading.frame.origin.y - 10,
														 tempHeading.frame.size.width,
														 fmaxf(tempSubHeading.frame.size.height + 10,labelsize.height + 20));
			
		}
		
		//calc title height
		CGFloat titleheight = 0;
		if (xmltitleheight == 0) {
			titleheight = fmaxf(CGRectGetMaxY(tempHeading.frame) + ([mode isEqual:kTitleMode_peek] ? 0 : 5), CGRectGetMaxY(tempSubHeading.frame)+5);
		} else {
			if (!(xmltitleheight % 2) && [mode isEqual:kTitleMode_straight]) {
				//add 1 to even heights (even heights render blurry on straight-mode titles for some WEIRD reason)
				//xmltitleheight++;
			}
			titleheight = xmltitleheight;
		}
		
		if (tempSubHeading && [mode isEqual:kTitleMode_peek]) {titleheight += tempSubHeading.frame.size.height + CGRectGetMinY(tempSubHeading.frame) - CGRectGetMaxY(tempHeading.frame);}
		
		//create the title container
		if ([mode isEqual:kTitleMode_clear]) {
			//clear mode
			titleContainer = [[UIRoundedView alloc] initWithFrame:CGRectMake(0, 20, 300, titleheight)
														  bgColor:[UIColor clearColor]
														   radius:ROUNDRECT_RADIUS
														  topleft:NO
														 topright:NO
													  bottomright:NO
													   bottomleft:NO
													  tapDelegate:self.panelDelegate];
			
		} else if ([mode isEqual:kTitleMode_plain]) {
			//plain mode
			titleContainer = [[UIRoundedView alloc] initWithFrame:CGRectMake(0, 20, self.pageView.frame.size.width - 20, titleheight)
														  bgColor:[UIColor whiteColor]
														   radius:ROUNDRECT_RADIUS
														  topleft:NO
														 topright:YES
													  bottomright:YES
													   bottomleft:NO
													  tapDelegate:self.panelDelegate];
			
			tempSubHeading.frame = CGRectMake(10, 10, self.pageView.frame.size.width - 30, titleheight - 10);
			[tempSubHeading sizeToFit];
			titleContainer.frame = CGRectMake(0, 20, self.pageView.frame.size.width - 20, tempSubHeading.frame.size.height + 20);
			titleContainer.clipsToBounds = YES;
		} else if ([mode isEqual:kTitleMode_straight]) {
			//straight mode
			titleContainer = [[UIRoundedView alloc] initWithFrame:CGRectMake(0, 20, self.pageView.frame.size.width, titleheight)
														  bgColor:[UIColor whiteColor]
														   radius:ROUNDRECT_RADIUS
														  topleft:NO
														 topright:NO
													  bottomright:NO
													   bottomleft:NO
													  tapDelegate:self.panelDelegate];
			
		} else if ([mode isEqual:kTitleMode_singlecurve] || [mode isEqual:kTitleMode_peek]) {
			//single rounded corner mode or
			//peek mode
			titleContainer = [[UIRoundedView alloc] initWithFrame:CGRectMake(0, 0, self.pageView.frame.size.width - 20, titleheight)
														  bgColor:[UIColor whiteColor]
														   radius:ROUNDRECT_RADIUS * 2
														  topleft:NO
														 topright:NO
													  bottomright:YES
													   bottomleft:NO
													  tapDelegate:self.panelDelegate];
			
		} else {
			//no mode specified
			titleContainer = [[UIRoundedView alloc] initWithFrame:CGRectMake(0, 20, self.pageView.frame.size.width - 20, titleheight)
														  bgColor:[UIColor whiteColor]
														   radius:ROUNDRECT_RADIUS
														  topleft:NO
														 topright:YES
													  bottomright:YES
													   bottomleft:NO
													  tapDelegate:self.panelDelegate];
			
			titleContainer.clipsToBounds = YES;
		}
		
		//peek mode: create the vertical line
		if ([mode isEqual:kTitleMode_peek]) {
			UIImageView *tempVertLine = [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"vline.png"]];
			tempVertLine.frame = CGRectMake(CGRectGetMaxX(tempHeading.frame) + 4, tempSubHeading.frame.origin.y + 5, 2, tempSubHeading.frame.size.height - 10);
			if (tempVertLine) {[titleContainer addSubview:tempVertLine];}
		}
		
		//center heading vertically
		if (xmltitleheight) {
			[tempHeading setCenter:CGPointMake(tempHeading.center.x, round(titleContainer.center.y - titleContainer.frame.origin.y))];
		}
		
		if (tempNumber) {[titleContainer addSubview:tempNumber];}
		if (tempHeading) {[titleContainer addSubview:tempHeading];}
		if (tempSubHeading) {[titleContainer addSubview:tempSubHeading];}
		
		titleContainer.titleMode	= mode;
		titleContainer.tag			= 560;
		return titleContainer;
		
	} else {
		return nil;
	}
	
}

- (id)createSubTitleFromElement:(TBXMLElement *)element underTitle:(UIView *)titleUIView{
	UIRoundedView	*subTitleContainer = nil;
	
	if (element) {
		
		TBXMLElement	*subTitle_element			= [TBXML childElementNamed:kName_TitlePeek		parentElement:element];
		if (subTitle_element) {
			
			NSString	*text		=						[TBXML textForElement:subTitle_element];
			NSString	*modifier	=						[TBXML valueOfAttributeNamed:kAttr_modifier forElement:subTitle_element];
			UIColor		*color		=	[self colorForHex:	[TBXML valueOfAttributeNamed:kAttr_color	forElement:subTitle_element]];
			NSString	*alpha		=						[TBXML valueOfAttributeNamed:kAttr_alpha	forElement:subTitle_element];
			NSString	*align		=						[TBXML valueOfAttributeNamed:kAttr_textalign	forElement:subTitle_element];
			NSString	*size		=						[TBXML valueOfAttributeNamed:kAttr_size		forElement:subTitle_element];
			NSString	*x			=						[TBXML valueOfAttributeNamed:kAttr_x		forElement:subTitle_element];
			NSString	*y			=						[TBXML valueOfAttributeNamed:kAttr_y		forElement:subTitle_element];
			NSString	*w			=						[TBXML valueOfAttributeNamed:kAttr_width	forElement:subTitle_element];
			NSString	*h			=						[TBXML valueOfAttributeNamed:kAttr_height	forElement:subTitle_element];
			
			//init variables for object parameters
			CGRect			frame			= CGRectZero;
			NSTextAlignment textAlignment	= NSTextAlignmentLeft;
			BOOL			resize			= YES;
			UIColor			*bgColor		= nil;
			NSUInteger		textSize		= DEFAULT_TEXTSIZE_TITLE_SUBHEADING;
			NSString		*font			=  GTPageInterpreterAmharicFont_peekpanel;
			CGFloat			labelAlpha		= 1.0;
			
			//set parameters to attribute val or defaults	//attribute value															//default value
			if		(x)										{frame.origin.x		=	round([x floatValue]);}								else	{frame.origin.x		= 10;}
			if		(y)										{frame.origin.y		=	round([y floatValue]);}								else	{frame.origin.y		= 30;}
			if		(w)										{frame.size.width	=	round([w floatValue]);}								else	{frame.size.width	= self.pageView.frame.size.width - 40;}
			if		(h)										{frame.size.height	=	round([h floatValue]);}								else	{frame.size.height	= 80;}
			if		((w != nil) && (h != nil))				{resize				= NO;}
			
			if		(!bgColor)																											{bgColor			= [UIColor whiteColor];}
			if		(!color)																											{color				= self.backgroundColor;}
			if		(size)									{textSize			= round(textSize * [size floatValue] / 100);}
			
			if (alpha) {
				labelAlpha = [alpha floatValue];
			}
			
			if (modifier) {
				if		([modifier isEqual:kLabelModifer_bold])			{font		=  GTPageInterpreterAmharicFont_boldlabel;}
				else if	([modifier isEqual:kLabelModifer_italics])		{font		=  GTPageInterpreterAmharicFont_italicslabel;}
				else if	([modifier isEqual:kLabelModifer_bolditalics])	{font		=  GTPageInterpreterAmharicFont_bolditalicslabel;}
			}
			
			if (align) {
				if		([align isEqual:kAlignment_right])	{textAlignment		= NSTextAlignmentRight;}
				else if ([align isEqual:kAlignment_center])	{textAlignment		= NSTextAlignmentCenter;}
				else if ([align isEqual:kAlignment_left])	{textAlignment		= NSTextAlignmentLeft;}
			}
			
			UILabel			*tempSubTitleText		= nil;
			
			if (subTitle_element) {
				tempSubTitleText = [self createLabelWithFrame:frame autoResize:resize text:text color:color bgColor:[UIColor clearColor] alpha:labelAlpha alignment:textAlignment font:font size:textSize];
			}
			
			
			//set the initial frame of the subtitle
			CGRect subTitleFrame = CGRectMake(0,
                                              self.titleFrame.size.height - (tempSubTitleText.frame.size.height + tempSubTitleText.frame.origin.y + (ROUNDRECT_RADIUS)) + 10,
                                              self.pageView.frame.size.width - 30,
                                              tempSubTitleText.frame.size.height + tempSubTitleText.frame.origin.y + (ROUNDRECT_RADIUS)
                                              );
			
			subTitleContainer = [[UIRoundedView alloc] initWithFrame:subTitleFrame
															 bgColor:bgColor
															  radius:(ROUNDRECT_RADIUS * 2)
															 topleft:NO
															topright:NO
														 bottomright:YES
														  bottomleft:NO
														 tapDelegate:self.panelDelegate];
			
			CGRect peekPanelArrowFrame = CGRectMake((subTitleFrame.size.width / 2) - 5 ,subTitleFrame.size.height - 8 , 10, 10);
			UILabel	*peekPanelArrow = [self createLabelWithFrame:peekPanelArrowFrame autoResize:NO text:@"▼" color:[UIColor whiteColor] bgColor: [UIColor clearColor] alpha:1.0 alignment:NSTextAlignmentCenter font: GTPageInterpreterAmharicFont_label size:8];
			peekPanelArrow.shadowColor = [UIColor darkGrayColor];
			
			
			//[tempSubTitleText setTag:10];
			[subTitleContainer addSubview:tempSubTitleText];
            //CGRect subTitleMask = CGRectMake(0, 0, self.titleFrame.size.width, self.pageView.frame.size.height);
            
            //UIView *subTitleMask = [[UIView alloc] initWithFrame:CGRectMake(subTitleContainer.frame.origin.x, subTitleContainer.frame.origin.y, subTitleContainer.frame.size.width, self.pageView.frame.size.height)];
            //[subTitleMask addSubview:(UIView *)subTitleContainer];
            
			[subTitleContainer insertSubview:peekPanelArrow aboveSubview:tempSubTitleText];
			//UIView *gapfiller = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.titleFrame.size.width, self.titleFrame.origin.y)];
			//gapfiller.backgroundColor = self.backgroundColor;
            //[gapfiller setTag:99];
			//[subTitleContainer insertSubview:gapfiller atIndex:0];
			//[gapfiller release];
			
			subTitleContainer.titleMode = kTitleMode_peek;
			//[subTitleContainer setTag:550];
            //[subTitleMask setTag:550];
		}
	}
	return subTitleContainer;
}

- (id)createTitleNumberFromElement:(TBXMLElement *)element	titleMode:(NSString *)titleMode {
	
	if (element != nil) {
		
		//read attributes for title subheading
		NSString	*text	=						[TBXML textForElement:element];
		UIColor		*color	=	[self colorForHex:	[TBXML valueOfAttributeNamed:kAttr_color	forElement:element]];
		NSString	*alpha	=						[TBXML valueOfAttributeNamed:kAttr_alpha	forElement:element];
		NSString	*align	=						[TBXML valueOfAttributeNamed:kAttr_textalign	forElement:element];
		NSString	*size	=						[TBXML valueOfAttributeNamed:kAttr_size		forElement:element];
		NSString	*x		=						[TBXML valueOfAttributeNamed:kAttr_x		forElement:element];
		NSString	*y		=						[TBXML valueOfAttributeNamed:kAttr_y		forElement:element];
		NSString	*w		=						[TBXML valueOfAttributeNamed:kAttr_width	forElement:element];
		NSString	*h		=						[TBXML valueOfAttributeNamed:kAttr_height	forElement:element];
		
		CGRect			frame			= CGRectZero;
		NSTextAlignment textAlignment	= NSTextAlignmentRight;
		BOOL			resize			= YES;
		UIColor			*bgColor		= nil;
		NSUInteger		textSize		= DEFAULT_TEXTSIZE_TITLE_NUMBER;
		NSString		*font			=  GTPageInterpreterAmharicFont_number;
		CGFloat			labelAlpha		= 1.0;
		//overwrite defaults with user set values (xml attributes)
		if		(x)										{frame.origin.x		= [x floatValue];}								else	{frame.origin.x		= 10;}
		if		(y)										{frame.origin.y		= [y floatValue];}								else	{frame.origin.y		= 5;}
		if		(w)										{frame.size.width	= [w floatValue];}								else	{frame.size.width	= 40;}
		if		(h)										{frame.size.height	= [h floatValue];}								else	{frame.size.height	= 150;}
		if		((w != nil) && (h != nil))				{resize				= NO;}
		
		if		(!bgColor)																								{bgColor			= [UIColor clearColor];}
		if		(!color)																								{color				= self.backgroundColor;}
		if		(size)									{textSize			= round(textSize * [size floatValue] / 100);}
		
		if (alpha) {
			labelAlpha = [alpha floatValue];
		}
		
		if (align) {
			if		([align isEqual:kAlignment_right])	{textAlignment		= NSTextAlignmentRight;}
			else if ([align isEqual:kAlignment_center])	{textAlignment		= NSTextAlignmentCenter;}
			else if ([align isEqual:kAlignment_left])	{textAlignment		= NSTextAlignmentLeft;}
		}																										else	{textAlignment		= NSTextAlignmentRight;}
		
		if (titleMode) {
			if		([titleMode isEqual:kTitleMode_clear])	{bgColor			= [UIColor clearColor];}
		}
		
		return [self createLabelWithFrame:frame autoResize:resize text:text color:color bgColor:bgColor alpha:labelAlpha alignment:textAlignment font:font size:textSize];
		
	} else {
		return nil;
	}
	
}


- (id)createTitleHeadingFromElement:(TBXMLElement *)element	titleMode:(NSString *)titleMode {
	
	
	if (element != nil) {
		//read attributes for title subheading
		NSString	*text	=						[TBXML textForElement:element];
		UIColor		*color	=	[self colorForHex:	[TBXML valueOfAttributeNamed:kAttr_color	forElement:element]];
		NSString	*alpha	=						[TBXML valueOfAttributeNamed:kAttr_alpha	forElement:element];
		NSString	*align	=						[TBXML valueOfAttributeNamed:kAttr_textalign	forElement:element];
		NSString	*size	=						[TBXML valueOfAttributeNamed:kAttr_size		forElement:element];
		NSString	*x		=						[TBXML valueOfAttributeNamed:kAttr_x		forElement:element];
		NSString	*y		=						[TBXML valueOfAttributeNamed:kAttr_y		forElement:element];
		NSString	*w		=						[TBXML valueOfAttributeNamed:kAttr_width	forElement:element];
		NSString	*h		=						[TBXML valueOfAttributeNamed:kAttr_height	forElement:element];
		
		CGRect			frame			= CGRectZero;
		NSTextAlignment textAlignment	= ([titleMode isEqual:kTitleMode_peek] ? NSTextAlignmentRight : NSTextAlignmentLeft);
		BOOL			resize			= YES;
		UIColor			*bgColor		= nil;
		NSUInteger		textSize		= ([titleMode isEqual:kTitleMode_peek] ? DEFAULT_TEXTSIZE_TITLE_HEADING_PEEKMODE : DEFAULT_TEXTSIZE_TITLE_HEADING_NORMALMODE );
		NSString		*font			= ([titleMode isEqual:kTitleMode_peek] ?  GTPageInterpreterAmharicFont_peekheading :  GTPageInterpreterAmharicFont_heading);
		CGFloat			labelAlpha		= 1.0;
		
		//set values to attribute values or defaults
		if ([titleMode isEqual:kTitleMode_peek]) {
			//peek mode
			if		(x)										{frame.origin.x		= [x floatValue];}								else	{frame.origin.x		= 5;}
			if		(y)										{frame.origin.y		= [y floatValue];}								else	{frame.origin.y		= 10;}
			if		(w)										{frame.size.width	= [w floatValue];}								else	{frame.size.width	= 95;}
			if		(h)										{frame.size.height	= [h floatValue];}								else	{frame.size.height	= 100;}
			if		((w != nil) && (h != nil))				{resize				= NO;}
			
		} else {
			if		(x)										{frame.origin.x		= [x floatValue];}								else	{frame.origin.x		= 55;}
			if		(y)										{frame.origin.y		= [y floatValue];}								else	{frame.origin.y		= 5;}
			if		(w)										{frame.size.width	= [w floatValue];}								else	{frame.size.width	= 240;}
			if		(h)										{frame.size.height	= [h floatValue];}								else	{frame.size.height	= 150;}
			if		((w != nil) && (h != nil))				{resize				= NO;}
		}
		if		(!bgColor)																								{bgColor			= [UIColor clearColor];}
		if		(!color)																								{color				= self.backgroundColor;}
		if		(size)									{textSize			= round(textSize * [size floatValue] / 100);}
		
		if (alpha) {
			labelAlpha = [alpha floatValue];
		}
		
		if (align) {
			if		([align isEqual:kAlignment_right])	{textAlignment		= NSTextAlignmentRight;}
			else if ([align isEqual:kAlignment_center])	{textAlignment		= NSTextAlignmentCenter;}
			else if ([align isEqual:kAlignment_left])	{textAlignment		= NSTextAlignmentLeft;}
		}
		
		if (titleMode) {
			if		([titleMode isEqual:kTitleMode_clear])		{bgColor			= [UIColor clearColor];}
			else if ([titleMode isEqual:kTitleMode_straight])	{
				textAlignment=NSTextAlignmentCenter;
				UILabel *temp = [self createLabelWithFrame:frame autoResize:resize text:text color:color bgColor:bgColor alpha:labelAlpha alignment:textAlignment font:font size:textSize];
				frame = temp.frame;
				frame.origin.x		= 0;
				frame.size.width = self.pageView.frame.size.width;
				temp.frame = frame;
				
				return temp;
			}
		}
		
		return [self createLabelWithFrame:frame autoResize:resize text:text color:color bgColor:bgColor alpha:labelAlpha alignment:textAlignment font:font size:textSize];
	} else {
		return nil;
	}
}

/**
 *	Description:	Creates a subheading view for the title
 *	Parameters:		Element:	The TBXMLElement for the subheading
 *					titleMode:	A NSString containing the specified title mode (straight, single, etc.)
 *	Returns:		A UIView object from the attributes specified in the passed TBXML element.
 */
- (id)createTitleSubheadingFromElement:(TBXMLElement *)element titleMode:(NSString *)titleMode {
	//read attributes for title subheading
	NSString	*text	=						[TBXML textForElement:element];
	UIColor		*color	=	[self colorForHex:	[TBXML valueOfAttributeNamed:kAttr_color	forElement:element]];
	NSString	*alpha	=						[TBXML valueOfAttributeNamed:kAttr_alpha	forElement:element];
	NSString	*align	=						[TBXML valueOfAttributeNamed:kAttr_textalign	forElement:element];
	NSString	*size	=						[TBXML valueOfAttributeNamed:kAttr_size		forElement:element];
	NSString	*x		=						[TBXML valueOfAttributeNamed:kAttr_x		forElement:element];
	NSString	*y		=						[TBXML valueOfAttributeNamed:kAttr_y		forElement:element];
	NSString	*w		=						[TBXML valueOfAttributeNamed:kAttr_width	forElement:element];
	NSString	*h		=						[TBXML valueOfAttributeNamed:kAttr_height	forElement:element];
	
	//init title parameters with defaults
	CGRect			frame			= CGRectZero;
	NSTextAlignment textAlignment	= ([titleMode isEqual:kTitleMode_peek] ? NSTextAlignmentLeft : NSTextAlignmentCenter);
	BOOL			resize			= YES;
	UIColor			*bgColor		= nil;
	NSUInteger		textSize		= DEFAULT_TEXTSIZE_TITLE_SUBHEADING;
	NSString		*font			= ([titleMode isEqual:kTitleMode_peek] ?  GTPageInterpreterAmharicFont_peeksubheading :  GTPageInterpreterAmharicFont_subheading);
	CGFloat			labelAlpha		= 1.0;
	
	//check if xml attributes are specified,		if so,				use them.										if not,	use defaults
	if ([titleMode isEqual:kTitleMode_peek]) {
		//peek mode
		if		(x)										{frame.origin.x		= [x floatValue];}								else	{frame.origin.x		= 116;}
		if		(y)										{frame.origin.y		= [y floatValue];}								else	{frame.origin.y		= 0;}
		if		(w)										{frame.size.width	= [w floatValue];}								else	{frame.size.width	= 175;}
		if		(h)										{frame.size.height	= [h floatValue];}								else	{frame.size.height	= 120;}
		if		((w != nil) && (h != nil))				{resize				= NO;}
	} else {
		if		(x)										{frame.origin.x		= [x floatValue];}								else	{frame.origin.x		= 0;}
		if		(y)										{frame.origin.y		= [y floatValue];}								else	{frame.origin.y		= 82;}
		if		(w)										{frame.size.width	= [w floatValue];}								else	{frame.size.width	= 320;}
		if		(h)										{frame.size.height	= [h floatValue];}								else	{frame.size.height	= 23;}
		if		((w != nil) && (h != nil))				{resize				= NO;}
	}
	
	
	//Background Colour (clear)
	if		(!bgColor)								{bgColor			= [UIColor clearColor];}
	
	//Text Colour (page's background colour)
	if		(!color)								{color				= self.backgroundColor;}
	
	//Text Size (percentage modifier)
	if		(size)									{textSize			= round(textSize * [size floatValue] / 100);}
	
	if (alpha) {
		labelAlpha = [alpha floatValue];
	}
	
	if (align) {
		if		([align isEqual:kAlignment_right])	{textAlignment		= NSTextAlignmentRight;}
		else if ([align isEqual:kAlignment_center])	{textAlignment		= NSTextAlignmentCenter;}
		else if ([align isEqual:kAlignment_left])	{textAlignment		= NSTextAlignmentLeft;}
	}
	
	//**added to remove multiple return points**
	//Sets up the return data, the mode handling modifies this.
	UILabel *tempLabel = [self createLabelWithFrame:frame autoResize:resize text:text color:color bgColor:bgColor alpha:labelAlpha alignment:textAlignment font:font size:textSize];
	
	//mode handling
	if (titleMode) {
		//clear
		if		([titleMode isEqual:kTitleMode_clear])	{
			bgColor			= [UIColor clearColor];
			tempLabel.backgroundColor = [UIColor clearColor];
		}
		//straight
		else if ([titleMode isEqual:kTitleMode_straight]) {
			textAlignment=NSTextAlignmentCenter;
			tempLabel.textAlignment = NSTextAlignmentCenter;
			//**CONFIRM REDUNDANCY**	UILabel *temp = [self createLabelWithFrame:frame autoResize:resize text:text color:color bgColor:bgColor alpha:labelAlpha alignment:textAlignment font:font size:textSize];
			frame = tempLabel.frame;
			frame.origin.x		= 0;
			frame.size.width = self.pageView.frame.size.width;
			tempLabel.frame = frame;
			
			//**CONFIRM REDUNDANCY**	return temp;
		}
	}
	
	//**CONFIRM REDUNDANCY**	return [self createLabelWithFrame:frame autoResize:resize text:text color:color bgColor:bgColor alpha:labelAlpha alignment:textAlignment font:font size:textSize];
	return tempLabel;
}

//Returns a label given label attributes
- (UILabel *)createLabelWithFrame:(CGRect)frame autoResize:(BOOL)resize text:(NSString *)text color:(UIColor *)color bgColor:(UIColor *)bgColor alpha:(CGFloat)alpha alignment:(NSTextAlignment)textAlignment font:(NSString *)font size:(NSUInteger)size {
	UILabel *tempLabel = [[UILabel alloc] initWithFrame:frame];
	
	//Colors
	[tempLabel setBackgroundColor:bgColor];
	[tempLabel setTextColor:color];
	
	//Set Alpha
	if (alpha < 1) {
		[tempLabel setOpaque:NO];
		[tempLabel setAlpha:alpha];
	}
	
	//Text & Formatting
	[tempLabel setText:text];
	[tempLabel setFont:[UIFont fontWithName:font size:size]];
	[tempLabel setTextAlignment:textAlignment];
	[tempLabel setLineBreakMode:NSLineBreakByWordWrapping];
	
	//Size
	[tempLabel setNumberOfLines:0];
	if (resize) {
		[tempLabel sizeToFit];
	}
	
	//Reset width to fill the width available
	[tempLabel setFrame:CGRectMake(tempLabel.frame.origin.x, tempLabel.frame.origin.y, frame.size.width, tempLabel.frame.size.height)];
	
	return tempLabel;
}

#pragma mark -
#pragma mark Attribute Parsing Functions

/**
 *	Description:	Takes a hex string and returns a UIColor object that represents that hex color
 *	Parameters:		hexColor - NSString that is the hex representation of that desired color
 *	Returns:		A UIColor with those r, g, b and alpha values in hexColor
 */
- (UIColor *) colorForHex:(NSString *)hexColor {
	if (hexColor) {
		unsigned long long rgbValue;
		hexColor = [[hexColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
		
		// strip # if it appears
		if ([hexColor hasPrefix:@"#"]) {
			hexColor = [hexColor substringFromIndex:1];
		}
		
		// String should be 6 characters or 8 characters with an alpha component
		if (!([hexColor length] == 6 || [hexColor length] == 8)) {
			return nil;
		}
		
		//parse the string WITHOUT an alpha component and return the coresponding UIColor
		if ([hexColor length] == 6) {
			[[NSScanner scannerWithString:hexColor] scanHexLongLong:&rgbValue];
			
			return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0
								   green:((float)((rgbValue & 0xFF00) >> 8))/255.0
									blue:((float)(rgbValue & 0xFF))/255.0
								   alpha:1.0];
			
			//parse the string WITH an alpha component and return the coresponding UIColor
		} else if ([hexColor length] == 8) {
			[[NSScanner scannerWithString:hexColor] scanHexLongLong:&rgbValue];
			
			return [UIColor colorWithRed:((float)((rgbValue & 0xFF000000) >> 32))/255.0
								   green:((float)((rgbValue & 0xFF0000) >> 16))/255.0
									blue:((float)((rgbValue & 0xFF00) >> 8))/255.0
								   alpha:((float)(rgbValue & 0xFF))/255.0];
		} else {
			return nil;
		}
		
		
	} else {
		return nil;
	}
	
}

@end
