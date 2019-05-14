//
//  ViewController.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/19.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_OperationViewController.h"
#import "P_TypeHeader.h"
#import "P_Data.h"
#import "P_Data+P_Exten.h"

@interface P_OperationViewController ()

@property (nonatomic, strong) NSURL *savePlistUrl;

@property (weak) IBOutlet NSButton *plusButton;
@property (weak) IBOutlet NSButton *minusButton;

@end

@implementation P_OperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURL *propertyListURL = [[NSBundle mainBundle].bundleURL URLByAppendingPathComponent:@"Contents/Info.plist"];
//    NSURL *propertyListURL = [[NSBundle mainBundle] URLForResource:@"Config" withExtension:@"plist"];
    [self __loadPlistData:propertyListURL];
    
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - action
- (IBAction)openPlistFileAction:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setDirectoryURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"]]];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:[PlistGlobalConfig.allowedFileTypes componentsSeparatedByString:@","]];
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
    if (_plistUrl) {
        [self __loadPlistData:_plistUrl];
    }
}
- (IBAction)addAction:(id)sender {
    P_Data *p = [[P_Data alloc] init];
    [self.outlineView insertItem:p ofItem:[self.outlineView itemAtRow:self.outlineView.selectedRow]];
}
- (IBAction)removeAction:(id)sender {
    [self.outlineView deleteItem:[self.outlineView itemAtRow:self.outlineView.selectedRow]];
}
- (IBAction)createPlistAction:(id)sender {
    if (_savePlistUrl) {
        [self __savePlistData:_savePlistUrl];
    } else {
        NSSavePanel *panel = [NSSavePanel savePanel];
        [panel setDirectoryURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"]]];
        [panel setNameFieldStringValue:[@"Untitle" stringByAppendingPathExtension:PlistGlobalConfig.encryptFileExtension]];
        [panel setMessage:@"Choose the path to save the mrlPlist"];
        [panel setAllowsOtherFileTypes:YES];
        [panel setAllowedFileTypes:@[@"mrlPlist"]];
        [panel setExtensionHidden:YES];
        [panel setCanCreateDirectories:YES];
        [panel setAllowsOtherFileTypes:NO];
        [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result){
            if (result == NSModalResponseOK)
            {
                self.savePlistUrl = [panel URL];
                [self createPlistAction:sender];
            }
        }];
    }
}

- (void)newDocument:(id)sender
{
    NSURL *propertyListURL = [[NSBundle mainBundle] URLForResource:@"Config" withExtension:@"plist"];
    if (propertyListURL) {
        [self __loadPlistData:propertyListURL];
    }
}

- (void)openDocument:(id)sender
{
    [self openPlistFileAction:sender];
}

- (void)saveDocument:(id)sender
{
    [self createPlistAction:sender];
}

- (void)saveDocumentAs:(id)sender
{
    NSLog(@"Save File As");
}

#pragma mark - public

-(void)p_showAlertViewWith:(NSString *)InformativeText
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"提 示"];
    [alert setInformativeText:InformativeText];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"")];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
}

-(void)p_showAlertViewWith:(NSString *)InformativeText completionHandler:(void (^ __nullable)(void))handler
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"提 示"];
    [alert setInformativeText:InformativeText];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"")];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if (handler) {
            handler();
        }
    }];
}

#pragma mark - private

- (void)__listPlistFile:(NSString *)appPath
{
    NSURL *plistUrl = nil;
    if (appPath.length) {
        plistUrl = [NSURL fileURLWithPath:appPath];
    }
    
    [self __loadPlistData:plistUrl];
}

- (void)__loadPlistData:(NSURL *)plistUrl
{
    _plistUrl = nil;
    _savePlistUrl = nil;
    P_Data *p = [P_Data rootWithPlistUrl:plistUrl];
    if (p) {
        _plistUrl = plistUrl;
        if ([plistUrl.lastPathComponent.pathExtension isEqualToString:PlistGlobalConfig.encryptFileExtension]) {
            _savePlistUrl = plistUrl;
        }
        _root = p;
        
        [self.outlineView setIndentationMarkerFollowsCell:YES];
        //        [self.outlineView setIgnoresMultiClick:YES];
        [self.outlineView reloadData];
        //设置子项的展开
        [self.outlineView expandItem:_root expandChildren:NO];
    } else {
        [self p_showAlertViewWith:@"This is not a plist file url."];
        [self newDocument:nil];
    }
}

- (void)__savePlistData:(NSURL *)plistUrl
{
    P_Data *root = self.root;
    
    NSData *data = root.data;
    
    BOOL success = [data writeToURL:plistUrl atomically:YES];
    
    if (success) {
        _plistUrl = plistUrl;
        [self p_showAlertViewWith:NSLocalizedString(@"save plist success!", @"")];
    } else {
        [self p_showAlertViewWith:NSLocalizedString(@"save plist fail!", @"")];
    }
}

#pragma mark - NSOutlineViewDataSource
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item
{
    return 0;
}

#pragma mark - NSOutlineViewDelegate
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    P_Data *p = item;
    self.plusButton.enabled = p.operation & P_Data_Operation_Insert;
    self.minusButton.enabled = p.operation & P_Data_Operation_Delete;
    return YES;
}

@end
