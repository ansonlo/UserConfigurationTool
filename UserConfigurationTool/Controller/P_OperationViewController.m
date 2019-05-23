//
//  ViewController.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/19.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_OperationViewController.h"
#import "AppDelegate.h"

#import "P_TypeHeader.h"
#import "P_Data.h"
#import "P_Data+P_Exten.h"

@interface P_OperationViewController ()

@property (nonatomic, strong) NSURL *savePlistUrl;

@property (nonatomic, strong) P_TextFinder *textFinder;


@end

@implementation P_OperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationOpenURLs:) name:NSApplicationOpenUrls object:nil];
    
    /** search */
    self.textFinder = [[P_TextFinder alloc] initWithOutLineView:self.outlineView];
    // 新建空白
    [self newDocument:nil];
    
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    if (self.view.window.toolbar == nil) {
        self.view.window.toolbar = self.toolbar;
        self.toolbar.window = self.view.window;
    }
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - NSApplicationOpenUrls
- (void)applicationOpenURLs:(NSNotification *)notification
{
    NSArray<NSURL *> *urls = notification.userInfo[NSApplicationOpenUrlsKey];
    NSURL *url = urls.firstObject;
    if ([[PlistGlobalConfig.allowedFileTypes componentsSeparatedByString:@","] containsObject:url.pathExtension]) {
        [self __loadPlistData:url];
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:[NSString stringWithFormat:NSLocalizedString(@"Failed to open file '%@'. ",@""), url.lastPathComponent]];
        [alert setInformativeText:NSLocalizedString(@"The file may have been stored with a different encoding, or it may not be a mrlPlist file. ",@"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"")];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
    }
}

#pragma mark - P_PropertyListToolbarViewDelegate
- (void)P_PropertyListToolbarView:(P_PropertyListToolbarView *)toolbar didClickButton:(P_PropertyListToolbarButton)buttonType
{
    switch (buttonType) {
        case P_PropertyListToolbarButtonOpen:
        {
            [self openPlistFileAction:nil];
        }
            break;
        case P_PropertyListToolbarButtonReset:
        {
            [self resetAction:nil];
        }
            break;
        case P_PropertyListToolbarButtonAdd:
        {
            [self addAction:nil];
        }
            break;
        case P_PropertyListToolbarButtonRemove:
        {
            [self removeAction:nil];
        }
            break;
        case P_PropertyListToolbarButtonSave:
        {
            [self savePlistAction:nil];
        }
        default:
            break;
    }
}

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
    NSInteger selectedRow = self.outlineView.selectedRow;
    if (selectedRow == -1) {
        selectedRow = 0;
    }
    id item = [self.outlineView itemAtRow:selectedRow];
    
    if ([self.outlineView canAddItem:item]) {
        [self.outlineView addItem:[[P_Data alloc] init]];
    } else {
        [self p_showAlertViewWith:@"This row/parentRow is not allowed to add child rows."];
    }
}
- (IBAction)removeAction:(id)sender {
    if (self.outlineView.selectedRow != -1) {
        [self.outlineView deleteItem:[self.outlineView itemAtRow:self.outlineView.selectedRow]];
    } else {
        [self p_showAlertViewWith:@"Please select a row."];
    }
}
- (IBAction)savePlistAction:(id)sender {
    [self __autoSaveTips:YES complete:nil];
}

#pragma mark - MENU
- (void)newDocument:(id)sender
{
    NSURL *propertyListURL = [[NSBundle mainBundle] URLForResource:@"Config" withExtension:@"plist"];
    if (propertyListURL) {
        [self __loadPlistData:propertyListURL];
    }
}
- (void)newMrlPlist:(id)sender
{
    NSURL *propertyListURL = [[NSBundle mainBundle] URLForResource:@"MRL" withExtension:@"plist"];
    if (propertyListURL) {
        [self __loadPlistData:propertyListURL];
    }
}
- (void)newVpnPlist:(id)sender
{
    NSURL *propertyListURL = [[NSBundle mainBundle] URLForResource:@"VPN" withExtension:@"plist"];
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
    [self savePlistAction:sender];
}

- (void)saveDocumentAs:(id)sender
{
    [self __autoSaveAsTips:YES complete:nil];
}

#pragma mark - 搜索Action
- (void)performFindPanelAction:(id)sender
{
    [self.textFinder performAction:NSTextFinderActionShowFindInterface];
}

- (void)performFindNextAction:(id)sender
{
    [self.textFinder performAction:NSTextFinderActionNextMatch];
}

- (void)performFindPreviousAction:(id)sender
{
    [self.textFinder performAction:NSTextFinderActionPreviousMatch];
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

-(void)autosavesInPlace:(void (^)(P_AutosavesCode code))completionHandler
{
    
    NSString *fileName = [NSLocalizedString(@"Untitle", @"") stringByAppendingPathExtension:PlistGlobalConfig.encryptFileExtension];
    if ([self.plistUrl.lastPathComponent isEqualToString:PlistGlobalConfig.encryptFileExtension]) {
        fileName = self.plistUrl.lastPathComponent;
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:[NSString stringWithFormat:NSLocalizedString(@"Do you want to save the changes made to the document “%@”?", @""), fileName]];
    [alert setInformativeText:NSLocalizedString(@"You can revert to undo the changes since you last saved the document.", @"")];
    [alert addButtonWithTitle:NSLocalizedString(@"Save", @"")];
    [alert addButtonWithTitle:NSLocalizedString(@"Revert Changes", @"")];
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) { /** save */
            [self __autoSaveTips:NO complete:^(BOOL isCancel) {
                if (completionHandler) {
                    completionHandler(isCancel ? P_AutosavesCodeCancel : P_AutosavesCodeSave);
                }
            }];
        } else if (returnCode == NSAlertSecondButtonReturn) {/** Revert Changes */
            if (completionHandler) {
                completionHandler(P_AutosavesCodeRevertChanges);
            }
        } else if (returnCode == NSAlertThirdButtonReturn) {/** Cancel */
            if (completionHandler) {
                completionHandler(P_AutosavesCodeCancel);
            }
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
    _isEdited = NO;
    P_Data *p = [P_Data rootWithPlistUrl:plistUrl];
    if (p) {
        _plistUrl = plistUrl;
        if ([plistUrl.lastPathComponent.pathExtension isEqualToString:PlistGlobalConfig.encryptFileExtension]) {
            _savePlistUrl = plistUrl;
        }
        _root = p;
        /** 设置搜索数据源 */
        self.textFinder.root = p;
        
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

- (void)__savePlistData:(NSURL *)plistUrl tips:(BOOL)tips
{
    P_Data *root = self.root;
    
    NSData *data = root.data;
    
    BOOL success = [data writeToURL:plistUrl atomically:YES];
    
    if (success) {
        _plistUrl = plistUrl;
        _isEdited = NO;
        if (tips) {
            [self p_showAlertViewWith:NSLocalizedString(@"save plist success!", @"")];
        }
    } else {
        if (tips) {
            [self p_showAlertViewWith:NSLocalizedString(@"save plist fail!", @"")];
        }
    }
}

- (void)__autoSaveTips:(BOOL)tips complete:(void (^ __nullable)(BOOL isCancel))complete
{
    if (_savePlistUrl) {
        [self __savePlistData:_savePlistUrl tips:tips];
        if (complete) {
            complete(NO);
        }
    } else {
        [self __autoSaveAsTips:tips complete:complete];
    }
}

- (void)__autoSaveAsTips:(BOOL)tips complete:(void (^ __nullable)(BOOL isCancel))complete
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setDirectoryURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"]]];
    [panel setNameFieldStringValue:[@"Untitle" stringByAppendingPathExtension:PlistGlobalConfig.encryptFileExtension]];
    [panel setMessage:@"Choose the path to save the mrlPlist"];
    [panel setAllowedFileTypes:@[@"mrlPlist"]];
    [panel setExtensionHidden:NO];
    [panel setCanCreateDirectories:YES];
    [panel setAllowsOtherFileTypes:NO];
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result){
        if (result == NSModalResponseOK)
        {
            self.savePlistUrl = [panel URL];
            [self __savePlistData:self.savePlistUrl tips:tips];
        }
        if (complete) {
            complete(result == NSModalResponseCancel);
        }
    }];
}

#pragma mark - NSOutlineViewDataSource
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item
{
    return 0;
}

#pragma mark - P_PropertyListOutlineViewDelegate
- (void)p_propertyListOutlineView:(P_PropertyListOutlineView *)outlineView didEditable:(id)item
{
    /** 重置搜索数据源 */
    self.textFinder.root = self.root;
    _isEdited = YES;
}

/** 允许拖拽文件加载的后缀 */
- (NSArray <NSString *>*)p_propertyListOutlineViewSupportFileExtension:(P_PropertyListOutlineView *)outlineView
{
    return @[@"plist", @"mrlPlist"];
}

/** 拖拽成功的文件路径 */
- (void)p_propertyListOutlineView:(P_PropertyListOutlineView *)outlineView didDragFiles:(NSArray <NSString *>*)files
{
    if (files.count > 0) {
        NSString *filePath = [files firstObject];
        [self __listPlistFile:filePath];
    }
}


@end
