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

#import "AppDelegate.h"
#import "CommandHelper.h"
#import "LaunchAtLoginController.h"

@interface AppDelegate ()

@property (strong, nonatomic)   NSStatusItem  *statusItem;
@property (weak) IBOutlet       NSMenu        *clickMenu;
@property (weak) IBOutlet       NSMenuItem    *startOnLaunchItem;
@property (assign, nonatomic)   BOOL          isHidingEnabled;
@property(assign, nonatomic)    BOOL          launchOnLogin;
@end

@implementation AppDelegate

LaunchAtLoginController *launchController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // On first load, check to see if the Desktop icons are already hidden
    self.isHidingEnabled = ![CommandHelper areIconsShowing];
    
    // Init the status bar item
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    // On load, check to see if the app is already a login item
    launchController = [[LaunchAtLoginController alloc]init];
    if([launchController launchAtLogin]) {
        self.startOnLaunchItem.state = NSOnState;
    } else {
        self.startOnLaunchItem.state = NSOffState;
    }
    
    // On first load, determine if the icon should be active or not
    [self determineIconState];
}

- (void) determineIconState{
    
    NSImage *menuBarImage = [NSImage imageNamed:@"icon"];
    [self.statusItem.button setImage:menuBarImage];
    
    // Check if system is running anything less than 10.10
    BOOL preYosemite = (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_9);
    if(!preYosemite) {
        [menuBarImage setTemplate:YES];
    }
    
    if(self.isHidingEnabled) {
        self.statusItem.button.appearsDisabled = NO;
        self.isHidingEnabled = false;
    } else {
        self.statusItem.button.appearsDisabled = YES;
        self.isHidingEnabled = true;
    }
    
    NSStatusBarButton *button = self.statusItem.button;
    [button setTarget:self];
    [button setAction:@selector(iconClicked:)];
    [button sendActionOn:NSLeftMouseUpMask|NSRightMouseUpMask];
}

#pragma mark Handlers for menu icon and menu items clicks

- (void)iconClicked:(id)sender {
    NSEvent *clickEvent = [[NSApplication sharedApplication] currentEvent];
    if((clickEvent.modifierFlags & NSControlKeyMask) || clickEvent.type ==NSRightMouseUp){
        [self showMenu:self];
    } else{
        [self determineIconState];
        [CommandHelper toggleIcons:self.isHidingEnabled];
    }
}

- (void)showMenu:(id)sender {
    [self.statusItem popUpStatusItemMenu:self.clickMenu];
}

- (IBAction)startOnLoginToggleItem:(id)sender {
    BOOL startOnLogin = ![launchController launchAtLogin];
    [launchController setLaunchAtLogin:startOnLogin];
    
    if(startOnLogin) {
        self.startOnLaunchItem.state = NSOnState;
    } else {
        self.startOnLaunchItem.state = NSOffState;
    }
}

- (IBAction)launchAbout:(id)sender {
    NSString *githubURL = @"https://github.com/awaterhouse/CleanSlate#cleanslate";
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:githubURL]];
}

- (IBAction)quitApp:(id)sender {
    [NSApp terminate:sender];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
