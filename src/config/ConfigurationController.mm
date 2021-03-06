//
//  ConfigurationSheet.m
//  FraSaver
//
//  Created by franck on 17/09/2015.
//  Copyright (c) 2015 Frachop. All rights reserved.
//

#import "ConfigurationController.h"

static NSString* const kConfigNibName = @"Configuration";

//- /////////////////////////////////////////////////////////////////////////////////////////////////////////
//- return cookie header string

static std::string getPassword( const std::string & userName )
{
	const std::string serviceName = "frachop.wallhaven-ssaver";
	void * readedPassword = nullptr;
	UInt32 passwordLength = 0;

	OSStatus res = SecKeychainFindGenericPassword(
		nullptr,
		static_cast<UInt32>(serviceName.length()),
		serviceName.c_str(),
		static_cast<UInt32>(userName.length()),
		userName.c_str(),
		
		&passwordLength,
		&readedPassword,
		
		nullptr );

	if (res) {
		CFStringRef err = SecCopyErrorMessageString (res, nullptr);
		CFShow(err);
	}

	std::string password;
	if ((res == 0) && (passwordLength > 0))
		password = (const char*) readedPassword;

	SecKeychainItemFreeContent( nullptr, readedPassword );
	
	return password;
}




//- /////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface ConfigurationController()

@property IBOutlet NSTextField* searchString;
@property IBOutlet NSTextField* labelVersion;


@end

//- /////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation ConfigurationController

- (instancetype)init:(Configuration*)config
{
	self = [super init];
	if (self) {
		_config = config;
	}
	return self;
}

-(void)awakeFromNib {
	[super awakeFromNib];
}

- (IBAction)login:(id)sender {
}


- (IBAction)dismissConfigSheet:(id)sender
{
	_config.randomRequest.set( [_searchString.stringValue UTF8String] );

	[_config synchronize];
	[_delegate configController:self dismissConfigSheet:_sheet];
}

- (NSWindow *)configureSheet
{
	if (!_sheet)
	{
		NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
		if (![thisBundle loadNibNamed:kConfigNibName owner:self topLevelObjects:nil])
		{
			NSLog(@"Unable to load configuration sheet");
		}
		
		NSString * name   = [thisBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
		NSString * version= [thisBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
		
		
		//NSLog(@"%@", [thisBundle infoDictionary]);
		
		_labelVersion.stringValue = [NSString stringWithFormat:@"%@ v%@", name, version];
	}
	
	[_config synchronize];
	_searchString.stringValue = [NSString stringWithUTF8String:	_config.randomRequest.search().c_str()];
	
	return self.sheet;
}

@end



