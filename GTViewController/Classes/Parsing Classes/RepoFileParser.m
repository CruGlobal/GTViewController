//
//  RepoFileParser.m
//  Snuffy
//
//  Created by Tom Flynn on 26/10/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//

#import "RepoFileParser.h"

@implementation RepoFileParser

@synthesize xmlRepresentation;
@synthesize packages;

-(id)initWithURL:(NSURL *)repourl {
	
    self.xmlRepresentation	= [[TBXML alloc] initWithURL:repourl];
    
    return [self initWithTBXML:self.xmlRepresentation];
    
}

-(id)initWithXMLPath:(NSString *)xmlpath {
    
    return [self initWithXMLString:[NSString stringWithContentsOfFile:xmlpath encoding:NSUTF8StringEncoding error:NULL]];
}

-(id)initWithXMLString:(NSString *)xmlstring {
    
	//parse and store xml
	TBXML	*tempTBXML		= [[TBXML alloc] initWithXMLString:xmlstring];
	self.xmlRepresentation	= tempTBXML;
    
    return [self initWithTBXML:self.xmlRepresentation];
}

-(id)initWithTBXML:(TBXML *)tempXml {
	
    self.xmlRepresentation = tempXml;
    
    if ([self.xmlRepresentation rootXMLElement] == nil) {
        [NSException raise:@"Initialization Failed" format:@"The specified XML was empty."];
    }
    
    self.packages = [RepoFileParser createSNPackageMetaFromTBXML:self.xmlRepresentation];
    
    return [self init];
}

+(NSMutableDictionary*)createSNPackageMetaFromTBXML:(TBXML *)repoxml {
    
    if ([repoxml rootXMLElement] == nil) {
        [NSException raise:@"Initialization Failed" format:@"The specified XML was empty."];
    }

    TBXMLElement *rootElement = [repoxml rootXMLElement];
    //NSLog([TBXML elementName:rootElement]);

    TBXMLElement *object_el      = rootElement->firstChild;
    
    NSMutableDictionary *tempPackageDictionary = [NSMutableDictionary dictionary];
    
    //NSLog(@"Parsing repoFile XML:");
    
    while (TRUE) {
        
        NSString *package_status                        = @"";
        NSString *package_id                            = @"";
        NSString *package_name                          = @"";
        NSString *package_path                          = @"";
        NSString *package_base_language                 = @"";
		NSString *temp_package_status                   = @"";
        NSString *temp_package_id                            = @"";
        NSString *temp_package_name                          = @"";
        NSString *temp_package_path                          = @"";
        NSString *temp_package_base_language                 = @"";
        
        if ([[TBXML elementName:object_el] isEqualToString:@"package"]) {
			temp_package_status                        = [TBXML valueOfAttributeNamed:@"status" forElement:object_el];
			temp_package_id                            = [TBXML valueOfAttributeNamed:@"id" forElement:object_el];
			temp_package_name                          = [TBXML valueOfAttributeNamed:@"name" forElement:object_el];
			temp_package_path                          = [TBXML valueOfAttributeNamed:@"path" forElement:object_el];
			temp_package_base_language						= [TBXML valueOfAttributeNamed:@"base_language" forElement:object_el];
			
            package_status                                  = [temp_package_status copy];
            package_id                                      = [temp_package_id copy];
            package_name                                    = [temp_package_name copy];
            package_path                                    = [temp_package_path copy];
            package_base_language                           = [temp_package_base_language copy];
            
            //NSLog(@"Found Package: %@", package_name);
            
            //create the SNPackageMeta for this package
            NSDictionary *package_properties = [[NSDictionary alloc]
												 initWithObjects:[[NSArray alloc] initWithObjects:
																   package_status,
																   package_id,
																   package_name,
																   package_path,
																   package_base_language,
																   nil]
												 forKeys:[[NSArray alloc] initWithObjects:
														   @"status",
														   @"id",
														   @"name",
														   @"path",
														   @"base_language",
														   nil]
												 ];
            SNPackageMeta *tempPackageMeta = [[SNPackageMeta alloc] initWithProperties:package_properties];
            
            NSString *language_status                       = @"";
			NSString *language_type                         = @"";
            NSString *language_code                         = @"";
            NSString *language_name                         = @""; //the name of the package in the specific language
            NSString *language_path                         = @"";
            NSString *language_icon                         = @"";
            NSString *language_version                      = @"";
            NSString *language_minimum_interpreter_version  = @"";
			NSString *temp_language_status                       = @"";
			NSString *temp_language_type                         = @"";
            NSString *temp_language_code                         = @"";
            NSString *temp_language_name                         = @""; //the name of the package in the specific language
            NSString *temp_language_path                         = @"";
            NSString *temp_language_icon                         = @"";
            NSString *temp_language_version                      = @"";
            NSString *temp_language_minimum_interpreter_version  = @"";
            
            
            //drill down to languages
            object_el = object_el->firstChild;
            
            
            while (TRUE) {
                if ([[TBXML elementName:object_el] isEqualToString:@"language"]) {
                    temp_language_status                             = [TBXML valueOfAttributeNamed:@"status" forElement:object_el];
					temp_language_type                               = [TBXML valueOfAttributeNamed:@"type" forElement:object_el];
                    temp_language_code                               = [TBXML valueOfAttributeNamed:@"language_code" forElement:object_el];
                    temp_language_name                               = [TBXML valueOfAttributeNamed:@"name" forElement:object_el];
                    temp_language_path                               = [TBXML valueOfAttributeNamed:@"path" forElement:object_el];
                    temp_language_icon                               = [TBXML valueOfAttributeNamed:@"icon" forElement:object_el];
                    temp_language_version                            = [TBXML valueOfAttributeNamed:@"version" forElement:object_el];
                    temp_language_minimum_interpreter_version        = [TBXML valueOfAttributeNamed:@"minimum_interpreter_version" forElement:object_el];
					
					language_status                             = [temp_language_status copy];
					language_type                               = [temp_language_type copy];
                    language_code                               = [temp_language_code copy];
                    language_name                               = [temp_language_name copy];
                    language_path                               = [temp_language_path copy];
                    language_icon                               = [temp_language_icon copy];
                    language_version                            = [temp_language_version copy];
                    language_minimum_interpreter_version        = [temp_language_minimum_interpreter_version copy];

                    //NSLog(@"    Found Language: %@", language_code);
                    
                    //create the SNLanguageMeta for this language
                    NSDictionary *language_properties = [[NSDictionary alloc] initWithObjects:
														  [[NSArray alloc] initWithObjects:
															language_status,
															language_type,
															language_code,
															language_name,
															language_path,
															language_icon,
															language_version,
															language_minimum_interpreter_version,
															nil]
																					   forKeys:
														  [[NSArray alloc] initWithObjects:
															@"status",
															@"type",
															@"language_code",
															@"name",
															@"path",
															@"icon",
															@"version",
															@"minimum_interpreter_version",
															nil]];
                    SNLanguageMeta *tempLanguageMeta = [[SNLanguageMeta alloc] initWithProperties:language_properties];
                    
                    //store the package language combo as a readable string in the packages array
                    //[self.packages addObject:[NSString stringWithFormat:@"%@ - %@", package_id, language_code]];
                    
                    //TODO: Create and store a packagemeta object, containing all of the metadata
                    
                    [tempLanguageMeta addPackage:[tempPackageMeta get:@"id"]];
                    [tempPackageMeta addLanguage:tempLanguageMeta];
                }
                
                
                //next language
                if (object_el->nextSibling == nil) {
                    break;
                } else {
                    object_el = object_el->nextSibling;
                }
            }
            //add the packagemeta object to the array
            [tempPackageDictionary setObject:tempPackageMeta forKey:[tempPackageMeta get:@"id"]];
            
            //return to package level
            object_el = object_el->parentElement;
        }
        
        
        //next package
        if (object_el->nextSibling == nil) {
            break;
        } else {
            object_el = object_el->nextSibling;
        }
    }
    
    //[repoxml release];
    
    return tempPackageDictionary;
}


@end
