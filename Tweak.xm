#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <substrate.h>

static NSString *effectiveString1 = @"لُلُصّبُلُلصّبُررً";
static NSString *effectiveString2 = @"ॣ ॣh ॣ ॣ";

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


extern "C" CTLineRef CTLineCreateWithAttributedString(
    CFAttributedStringRef string );
static CTLineRef (*original_CTLineCreateWithAttributedString)(
    CFAttributedStringRef string );
static CTLineRef replaced_CTLineCreateWithAttributedString(
    CFAttributedStringRef string ) {
	NSString *stringIT = (NSString*)CFAttributedStringGetString(string);
	if ([stringIT containsString:effectiveString1] || [stringIT containsString:effectiveString2]) {
		stringIT = @"don't support this text";
		CFStringRef cfText = (__bridge CFStringRef)stringIT;
		CFAttributedStringRef attribString = CFAttributedStringCreate (NULL, cfText, NULL);
		CTLineRef line = CTLineCreateWithAttributedString(attribString);
		return line;
	}
	return original_CTLineCreateWithAttributedString(string);
}


%ctor {
    MSHookFunction(CTLineCreateWithAttributedString, replaced_CTLineCreateWithAttributedString, &original_CTLineCreateWithAttributedString);
}

/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.

%hook ClassName

// Hooking a class method
+ (id)sharedInstance {
	return %orig;
}

// Hooking an instance method with an argument.
- (void)messageName:(int)argument {
	%log; // Write a message about this call, including its class, name and arguments, to the system log.

	%orig; // Call through to the original function with its original arguments.
	%orig(nil); // Call through to the original function with a custom argument.

	// If you use %orig(), you MUST supply all arguments (except for self and _cmd, the automatically generated ones.)
}

// Hooking an instance method with no arguments.
- (id)noArguments {
	%log;
	id awesome = %orig;
	[awesome doSomethingElse];

	return awesome;
}

// Always make sure you clean up after yourself; Not doing so could have grave consequences!
%end
*/
