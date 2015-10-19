//
//  GTInterpreter+init.h
//  Snuffy
//
//  Created by Michael Harrison on 4/16/14.
//
//

#import "GTInterpreter.h"
#import "GTPageStyle.h"

@interface GTInterpreter (init)

- (instancetype)initWithXMLPath:(NSString *)xmlPath fileLoader:(GTFileLoader *)fileLoader pageStyle:(GTPageStyle *)pageStyle pageView:(UIView *)view panelTapDelegate:(id<UIRoundedViewTapDelegate>)panelDelegate buttonTapDelegate:(id<UISnuffleButtonTapDelegate>)buttonDelegate;

@end
