//
//  ViewController.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/19.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_OperationViewController.h"

@interface P_OperationViewController ()

@property (nonatomic, strong) NSURL *plistUrl;
@property (nonatomic, assign) BOOL hasSaveUrl;

@end

@implementation P_OperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURL *propertyListURL = [[NSBundle mainBundle].bundleURL URLByAppendingPathComponent:@"Contents/Info.plist"];
    [self __loadPlistData:propertyListURL];
    
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - action
- (IBAction)openPlistFileAction:(id)sender {
    _hasSaveUrl = NO;
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setDirectoryURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"]]];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:@[@"plist", @"mrlPlist"]];
    [panel setAllowsOtherFileTypes:NO];
    if ([panel runModal] == NSModalResponseOK)
    {
        NSString *path = [panel.URLs.firstObject path];
        if ([path length] > 0)
        {
            [self __listPlistFile:path];
        }
    }
}

- (IBAction)resetAction:(id)sender {
    
}
- (IBAction)addAction:(id)sender {
    
}
- (IBAction)removeAction:(id)sender {
    
}
- (IBAction)createPlistAction:(id)sender {
    if (_hasSaveUrl) {
        [self __savePlistData:_plistUrl];
    } else {
        NSSavePanel *panel = [NSSavePanel savePanel];
        [panel setDirectoryURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"]]];
        [panel setNameFieldStringValue:@"Untitle.mrlPlist"];
        [panel setMessage:@"Choose the path to save the mrlPlist"];
        [panel setAllowsOtherFileTypes:YES];
        [panel setAllowedFileTypes:@[@"mrlPlist"]];
        [panel setExtensionHidden:YES];
        [panel setCanCreateDirectories:YES];
        [panel setAllowsOtherFileTypes:NO];
        [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result){
            if (result == NSModalResponseOK)
            {
                self.hasSaveUrl = YES;
                self.plistUrl = [panel URL];
                [self createPlistAction:sender];
            }
        }];
    }
}

#pragma mark - public

-(void)p_showAlertViewWith:(NSString *)InformativeText
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"提 示"];
    [alert setInformativeText:InformativeText];
    [alert addButtonWithTitle:@"OK"];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert runModal];
}

#pragma mark - private

- (void)__listPlistFile:(NSString *)appPath
{
    _plistUrl = nil;
    if (appPath.length) {
        NSURL *plistUrl = [NSURL fileURLWithPath:appPath];
        _plistUrl = plistUrl;
    }
    if (_plistUrl == nil) {
        [self p_showAlertViewWith:@"Plist Url Error!!!"];
    } else {
        [self __loadPlistData:_plistUrl];
    }
}

- (void)__loadPlistData:(NSURL *)plistUrl
{
    NSLog(@"subClass to overwrite the method.");
}

- (void)__savePlistData:(NSURL *)plistUrl
{
    NSLog(@"subClass to overwrite the method.");
}

@end
