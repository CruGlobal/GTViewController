//
//  GTInterpreter.m
//  Snuffy
//
//  Created by Michael Harrison on 4/16/14.
//
//

#import "GTInterpreter.h"

#import "GTPageInterpreter.h"
#import "GTPageInterpreterAmharic.h"

@implementation GTInterpreter

+ (instancetype)interpreterWithXMLPath:(NSString *)xmlPath fileLoader:(GTFileLoader *)fileLoader pageView:(UIView *)view panelTapDelegate:(id<UIRoundedViewTapDelegate>)panelDelegate buttonTapDelegate:(id<UISnuffleButtonTapDelegate>)buttonDelegate{
	
	if ([fileLoader.language isEqualToString:@"am-ET"]) {
		
		return [[GTPageInterpreterAmharic alloc] initWithXMLPath:xmlPath fileLoader:fileLoader pageView:view panelTapDelegate:panelDelegate buttonTapDelegate:buttonDelegate];
		
	} else {
		
		return [[GTPageInterpreter alloc] initWithXMLPath:xmlPath fileLoader:fileLoader pageView:view panelTapDelegate:panelDelegate buttonTapDelegate:buttonDelegate];
		
	}
	
}

//render elements on page from xml representation
- (void)renderPage {}
- (void)renderButtonsOnPage {}
- (void)renderPanelOnPageForButtonTag:(NSInteger)tag {}

//get object from xml
- (NSMutableArray *)arrayWithUrls { return nil; }
- (UIImageView *)watermark { return nil; }

//cache functions
- (void)cacheImages {}

@end
