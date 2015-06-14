//
//  GTShareViewController.m
//  GTViewController
//
//  Created by Michael Harrison on 5/20/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTShareViewController.h"

#import "SSCWhatsAppActivity.h"

NSString *const GTShareViewControllerCampaignLinkCampaignSource        = @"godtools-ios";
NSString *const GTShareViewControllerCampaignLinkCampaignMedium        = @"email";
NSString *const GTShareViewControllerCampaignLinkCampaignName          = @"app-sharing";

@interface GTShareViewController ()

@end

@implementation GTShareViewController

+ (instancetype)shareController {
	
	NSString *campaignLink				= [self produceLinkForCampaign:GTShareViewControllerCampaignLinkCampaignName
													  source:GTShareViewControllerCampaignLinkCampaignSource
													  medium:GTShareViewControllerCampaignLinkCampaignMedium];
	
	SSCWhatsAppActivity *whatsAppActivity	= [[SSCWhatsAppActivity alloc] init];
	
	GTShareViewController *shareController = [[self alloc] initWithActivityItems:@[[NSURL URLWithString:campaignLink]] applicationActivities:@[whatsAppActivity]];
	if (shareController) {
		
		shareController.excludedActivityTypes	= @[
										//UIActivityTypePostToFacebook,
										//UIActivityTypePostToTwitter,
										//UIActivityTypePostToWeibo,
										//UIActivityTypeMessage,
										//UIActivityTypeMail,
										UIActivityTypePrint,
										//UIActivityTypeCopyToPasteboard,
										//UIActivityTypeAssignToContact,
										//UIActivityTypeSaveToCameraRoll,
										UIActivityTypeAddToReadingList,
										UIActivityTypePostToFlickr,
										UIActivityTypePostToVimeo,
										//UIActivityTypePostToTencentWeibo,
										UIActivityTypeAirDrop
										];
		
	}
	
	return shareController;
}

+ (NSString *)produceShareLink {
	
	return [NSString stringWithFormat:@"http://www.godtoolsapp.com"];
}

+ (NSString *)produceLinkForCampaign:(NSString *)campaign source:(NSString *)source medium:(NSString *)medium {
	
	NSString *appVersionNumber	= [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	return [self.produceShareLink stringByAppendingFormat:@"?utm_source=%@&utm_medium=%@&utm_content=%@&utm_campaign=%@", source, medium, appVersionNumber, campaign];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
