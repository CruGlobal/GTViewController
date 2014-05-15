//
//  GTInterpreter.h
//  Snuffy
//
//  Created by Michael Harrison on 4/16/14.
//
//

#import <Foundation/Foundation.h>
#import "GTFileLoader.h"
#import "UISnuffleButton.h"
#import "UIRoundedView.h"

@interface GTInterpreter : NSObject

@property (nonatomic, strong) id<UIRoundedViewTapDelegate> panelDelegate;
@property (nonatomic, strong) id<UISnuffleButtonTapDelegate> buttonDelegate;

+ (instancetype)interpreterWithXMLPath:(NSString *)xmlPath fileLoader:(GTFileLoader *)fileLoader pageView:(UIView *)view panelTapDelegate:(id<UIRoundedViewTapDelegate>)panelDelegate buttonTapDelegate:(id<UISnuffleButtonTapDelegate>)buttonDelegate;

//render elements on page from xml representation
- (void)renderPage;
- (void)renderButtonsOnPage;
- (void)renderPanelOnPageForButtonTag:(NSInteger)tag;

//get object from xml
- (NSMutableArray *)arrayWithUrls;
- (UIImageView *)watermark;

//cache functions
- (void)cacheImages;

@end
