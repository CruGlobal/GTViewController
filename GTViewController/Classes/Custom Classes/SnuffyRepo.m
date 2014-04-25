//
//  SnuffyRepo.m
//  Snuffy
//
//  Created by Tom Flynn on 26/10/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//

#import "SnuffyRepo.h"

@implementation SnuffyRepo

-(id)initWithURL:(NSURL *)repofile_url {
    //url wrapper
    TBXML *tempXml = [[TBXML alloc] initWithURL:repofile_url];
	self = [self initWithTBXML:tempXml];
    if (self) {
        
    }
    return self;
}

/*
 -(id)initWithPath:(NSString *)path {
 //file wrapper
 TBXML *tempXml = [[TBXML alloc] initWithXMLFile:path];
 self = [self initWithTBXML:tempXml];
 [tempXml release];
 return self;
 }
 */

- (id)initWithPath:(NSString *)path {
	
	NSString *tempString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	//NSLog(tempString);
	TBXML *tempXml = [[TBXML alloc] initWithXMLString:tempString];// autorelease];
	self = [self initWithTBXML:tempXml];
	
    if (self) {
        //file wrapper
    }
    return self;
}

-(id)initWithXmlString:(NSString *)xml_string {
    //string wrapper
    TBXML *tempXml = [[TBXML alloc] initWithXMLString:xml_string];// autorelease];
	self = [self initWithTBXML:tempXml];
    if (self) {
        
    }
    return self;
}

-(id)initWithMetaOptions:(SNMetaOptions *)meta_options {
    //meta options url wrapper
    NSURL *meta_url = [NSURL URLWithString:[meta_options produceUrl]];
    return [self initWithURL:meta_url];
}

-(id)initWithTBXML:(TBXML *)xml_representation {
    //base initialiser - creates dictionary of packages from the xml it was passed
    @try {
        self.packages = [RepoFileParser createSNPackageMetaFromTBXML:xml_representation];
    }
    @catch (NSException *exception) {
        //notify the user of the failed connection
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GodTools cannot connect to the resource server."
														message:@"Don't worry! You can still use any resources that have already been downloaded."
													   delegate:nil
                                              cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
        //log
        NSLog(@"%@", exception);
        //fail
        return nil;
    }
    
    return [self init];
}

-(void)writeXmlToFile:(NSString *)path {
    //takes the object's packages and outputs snuffy XML to a file at the path specified
    
    //get XML for whatever is currently in the self.packages property
    NSString* xml_string = [self getXmlStringForPackageDictionary:self.packages];
    
    //DEBUG: log the xml
    NSLog(@"Created XML from PackageMeta:\n%@", xml_string);
    
    //write the xml string to the file specified
    //TODO: error handling
    [xml_string writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    //[xml_string release];
}



-(NSString*)getXmlStringForPackageDictionary:(NSDictionary *)package_dictionary {
    //string to contain the document XML
    NSMutableString*   xml_string;
    
    if ([self.packages count] == 0 || self.packages == NULL) {
        [NSException raise:@"Cannot create XML for no packagemeta objects" format:@""];
    } else {
        //start the xml
        xml_string = [[NSMutableString alloc] initWithString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<snuffy>\n"];
        
        //loop through packages in dictionary
        for (NSInteger i = 0; i < [package_dictionary count]; i++) {
            //get the current package and its languages
            SNPackageMeta           *currentpackage             = [[package_dictionary allValues] objectAtIndex:i];
            NSMutableDictionary     *currentpackage_languages   = [currentpackage languages];
            
            //string to contain the XML element
            NSMutableString         *element_string             = [[NSMutableString alloc] initWithString:@"\t<package "];
            
            //append the xml attributes
            [element_string appendFormat:@"status=\"%@\" ",             [currentpackage get:@"status"]];
            [element_string appendFormat:@"id=\"%@\" ",                 [currentpackage get:@"id"]];
            [element_string appendFormat:@"name=\"%@\" ",               [currentpackage get:@"name"]];
            [element_string appendFormat:@"path=\"%@\" ",               [currentpackage get:@"path"]];
            [element_string appendFormat:@"base_language=\"%@\" >\n",   [currentpackage get:@"base_language"]];
            
            //append the element to the document XML string
            [xml_string appendString:element_string];
            
            
            
            //loop through all the languages in the package
            for (NSInteger il = 0; il < [currentpackage_languages count]; il++) {
                //get the current language
                SNLanguageMeta          *currentlanguage            = [[[currentpackage languages] allValues] objectAtIndex:il];
                
                //string to contain the XML element
                NSMutableString*        element_string              = [[NSMutableString alloc] initWithFormat:@"\t\t<language "];
                
                //append the xml attributes
                [element_string appendFormat:@"status=\"%@\" ",                      [currentlanguage get:@"status"]];
                [element_string appendFormat:@"language_code=\"%@\" ",               [currentlanguage get:@"language_code"]];
                [element_string appendFormat:@"name=\"%@\" ",                        [currentlanguage get:@"name"]];
                [element_string appendFormat:@"path=\"%@\" ",                        [currentlanguage get:@"path"]];
                [element_string appendFormat:@"icon=\"%@\" ",                        [currentlanguage get:@"icon"]];
                [element_string appendFormat:@"version=\"%@\" ",                     [currentlanguage get:@"version"]];
                [element_string appendFormat:@"minimum_interpreter_version=\"%@\" ", [currentlanguage get:@"minimum_interpreter_version"]];
                
                //append the element to the document XML string
                [xml_string appendString:element_string];
                
            }
            
            //close the package element
            [xml_string appendString:@"\t</package>\n"];
        }
        
        //close the snuffy document element
        [xml_string appendString:@"</snuffy>"];
        
     
    }
    
    //return the xml document string
    return xml_string;
}


/*
-(void)updateRepoFile {
    NSLog(@"<updateRepoFile>");
    NSURL *contenturl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self.repo_server_URL absoluteString], @"meta.php"]];
    //NSLog(@"XMLURL: %@", [contenturl absoluteString]);
    self.local_XML = [NSString stringWithContentsOfURL:contenturl encoding:NSUTF8StringEncoding error:NULL];
    //NSLog(@"XMLFromURL: \n %@", self.local_XML);
    
    [self.local_XML writeToFile:self.local_XML_file atomically:NO encoding:NSUTF8StringEncoding error:NULL];
    //NSLog(@"XMLFromFile: %@\n%@", self.local_XML_file, [NSString stringWithContentsOfFile:self.local_XML_file encoding:NSUTF8StringEncoding error:NULL]);
}

-(void)parseLocalFile {
    NSLog(@"<parseLocalFile>");
    if (self.local_XML == nil || self.local_XML == @"") {
        self.local_XML = [NSString stringWithContentsOfFile:self.local_XML_file encoding:NSUTF8StringEncoding error:NULL];
    }
    
    self.repo_parser = [[RepoFileParser alloc] initWithXMLString:self.local_XML];
}
 */


@end
