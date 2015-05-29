#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>
#import <substrate.h>

static NSString *effectiveString1 = @"لُلُصّبُلُلصّبُررً";
static NSString *effectiveString2 = @"ॣ ॣh ॣ ॣ";

@interface SBApplication : NSObject
- (id)displayName;
@end

@interface UIApplication (AntiEffective)
- (id)_accessibilityFrontMostApplication;
@end

@interface NSString ( containsCategory )
- (BOOL) containsString: (NSString*) substring;
@end

// - - - - 

@implementation NSString ( containsCategory )

- (BOOL) containsString: (NSString*) substring
{    
    NSRange range = [self rangeOfString : substring];
    BOOL found = ( range.location != NSNotFound );
    return found;
}

@end

%group HookFoundation
id cfText;
%hook NSCFAttributedString
- (id)string {
	CFAttributedStringRef stringAttr = NULL;
	NSCFAttributedString *attString = self;
	stringAttr = (CFAttributedStringRef )CFBridgingRetain(attString);
	NSString *stringIT = (NSString*)CFAttributedStringGetString(stringAttr);
	if ([stringIT containsString:effectiveString1] || [stringIT containsString:effectiveString2]) {
		// stringIT = @"don't support this text"; // setting it to nothing better than an existe text
		stringIT = @"";
		cfText = stringIT;
		return cfText;
	} else {
		return %orig;
	}
}
%end
%end

extern "C" CTLineRef CTLineCreateWithAttributedString(
    CFAttributedStringRef string );
static CTLineRef (*original_CTLineCreateWithAttributedString)(
    CFAttributedStringRef string );
static CTLineRef replaced_CTLineCreateWithAttributedString(
    CFAttributedStringRef string ) {
	NSString *stringIT = (NSString*)CFAttributedStringGetString(string);
	SBApplication *frontMostApplication = [[UIApplication sharedApplication] _accessibilityFrontMostApplication];
	NSString *displayName = [frontMostApplication displayName];
	if (([stringIT containsString:effectiveString1] || [stringIT containsString:effectiveString2]) && ![displayName isEqualToString:@"Facebook"]) {
		// stringIT = @"don't support this text"; // setting it to nothing better than an existe text
		stringIT = @"";
		CFStringRef cfText = (__bridge CFStringRef)stringIT;
		CFAttributedStringRef attribString = CFAttributedStringCreate (NULL, cfText, NULL);
		CTLineRef line = CTLineCreateWithAttributedString(attribString);
		return line;
	}
	return original_CTLineCreateWithAttributedString(string);
}


%ctor {

	NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	if ([bundleIdentifier isEqualToString:@"com.apple.CoreText"]) {
		MSHookFunction(CTLineCreateWithAttributedString, replaced_CTLineCreateWithAttributedString, &original_CTLineCreateWithAttributedString);
	} else {
		%init(HookFoundation);
	}
}
