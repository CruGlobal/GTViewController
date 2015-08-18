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

@property (weak, nonatomic) NSString *packageCode;
@property (weak, nonatomic) NSString *languageCode;

@end

@implementation GTShareViewController

- (instancetype)init{
	
	NSString *campaignLink				= [self produceLinkForCampaign: GTShareViewControllerCampaignLinkCampaignName source:GTShareViewControllerCampaignLinkCampaignSource medium:GTShareViewControllerCampaignLinkCampaignMedium];
	
	SSCWhatsAppActivity *whatsAppActivity	= [[SSCWhatsAppActivity alloc] init];
	
	self = [super initWithActivityItems:@[[NSURL URLWithString:campaignLink]] applicationActivities:@[whatsAppActivity]];
    self.excludedActivityTypes = [[NSArray alloc]init];
	if (self) {

		self.excludedActivityTypes	= @[//UIActivityTypePostToFacebook,
										//UIActivityTypePostToTwitter,
										//UIActivityTypePostToWeibo,
										//UIActivityTypeMessage,
										//UIActivityTypeMail,
										UIActivityTypePrint,
										//UIActivityTypeCopyToPasteboard,
										//UIActivityTypeAssignToContact,
										//UIActivityTypeSaveToCameraRoll,
										/////////UIActivityTypeAddToReadingList,    //iOS7
										/////////UIActivityTypePostToFlickr,        //iOS7
										////////UIActivityTypePostToVimeo,          //iOS7
										//UIActivityTypePostToTencentWeibo,         //iOS7
										/////////UIActivityTypeAirDrop              //iOS7
										];
        if(([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)){//if version is greater than or equal to 7.0
            
             NSMutableArray* excludedActivityForEqualOrGreaterThaniOS7 = [[NSMutableArray alloc]initWithArray:@[
                                                                                                                UIActivityTypeAddToReadingList,
                                                                                                                UIActivityTypePostToFlickr,UIActivityTypePostToVimeo,
                                                                                                                //UIActivityTypePostToTencentWeibo,
                                                                                                                UIActivityTypeAirDrop]];

            
            [excludedActivityForEqualOrGreaterThaniOS7 addObjectsFromArray:self.excludedActivityTypes];
            self.excludedActivityTypes = [NSArray arrayWithArray:excludedActivityForEqualOrGreaterThaniOS7];
        }
		
	}
	
	return self;
}

- (id)initWithPackageCode:(NSString *)packageCode languageCode:(NSString *)languageCode{
    self.packageCode = packageCode;
    self.languageCode = languageCode;
    
    return [self init];
}

- (NSString *)produceShareLink {
	
	return [NSString stringWithFormat:@"http://www.godtoolsapp.com"];
}

- (NSString *)produceLinkForCampaign:(NSString *)campaign source:(NSString *)source medium:(NSString *)medium {
	
	NSString *appVersionNumber	= [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
    if(self.packageCode && self.languageCode) {
        return [self.produceShareLink stringByAppendingFormat:@"?utm_source=%@&utm_medium=%@&utm_content=%@&utm_campaign=%@&package=%@&language=%@", source, medium, appVersionNumber, campaign, self.packageCode, self.languageCode];
    } else {
        return [self.produceShareLink stringByAppendingFormat:@"?utm_source=%@&utm_medium=%@&utm_content=%@&utm_campaign=%@", source, medium, appVersionNumber, campaign];
    }
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
@end
