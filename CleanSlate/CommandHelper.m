//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the ‘Software’),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "CommandHelper.h"

NSString *const DEFAULTS_PATH = @"/usr/bin/defaults";

@implementation CommandHelper

+ (void) toggleIcons:(BOOL)hideIcons {
    
    NSTask *toggleTask = [[NSTask alloc]init];
    [toggleTask setLaunchPath:DEFAULTS_PATH];
    
    NSString *hideOrShow = hideIcons ? @"true" : @"false";
    NSArray *args = [NSArray arrayWithObjects:@"write", @"com.apple.finder", @"CreateDesktop", @"-bool", hideOrShow, nil];
    
    [toggleTask setArguments:args];
    [toggleTask launch];
    
    NSTask *killTask = [[NSTask alloc]init];
    [killTask setLaunchPath:@"/usr/bin/killall"];
    [killTask setArguments:[NSArray arrayWithObjects:@"Finder", nil]];
    [killTask launch];
    
}

+ (BOOL) areIconsShowing {
    NSTask *checkDefaultsTask = [[NSTask alloc]init];
    [checkDefaultsTask setLaunchPath:DEFAULTS_PATH];
    
    NSArray *args = [NSArray arrayWithObjects:@"read", @"com.apple.finder", @"CreateDesktop", nil];
    [checkDefaultsTask setArguments:args];
    
    NSPipe *output = [NSPipe pipe];
    [checkDefaultsTask setStandardOutput:output];
    
    [checkDefaultsTask launch];
    
    NSFileHandle *read = [output fileHandleForReading];
    NSData *dataRead = [read readDataToEndOfFile];
    NSString *stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
    BOOL isHidden = [stringRead boolValue];
                     
    return isHidden;
}

@end


