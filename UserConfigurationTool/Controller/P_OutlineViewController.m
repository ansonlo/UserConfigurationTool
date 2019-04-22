//
//  P_OutlineViewController.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/22.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_OutlineViewController.h"
#import "P_TypeHeader.h"
#import "P_Data.h"

@interface P_OutlineViewController ()

@property (nonatomic, strong) NSTreeNode *rootTreeNode;

@end

@implementation P_OutlineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

#pragma mark - overwrite
- (void)__loadPlistData:(NSURL *)plistUrl
{
    P_Data *p = [P_Data rootWithPlistUrl:plistUrl];
    if (p) {
        _rootTreeNode = [NSTreeNode treeNodeWithRepresentedObject:nil];
        [[_rootTreeNode mutableChildNodes] addObject:[self doTreeNodeFromData:p]];
        
        [self.outlineView setIndentationMarkerFollowsCell:YES];
//        [self.outlineView setIgnoresMultiClick:YES];
        [self.outlineView expandItem:_rootTreeNode expandChildren:YES];
        [self.outlineView reloadData];
        if (_rootTreeNode.mutableChildNodes.count) {
            //设置子项的展开
            [self.outlineView isExpandable:[_rootTreeNode.mutableChildNodes objectAtIndex:0]];
            [self.outlineView expandItem:[_rootTreeNode.mutableChildNodes objectAtIndex:0] expandChildren:NO];
        }
    }
}

- (void)__savePlistData:(NSURL *)plistUrl
{
    P_Data *root = _rootTreeNode.childNodes.firstObject.representedObject;
    
    id plist = root.plist;
    if ([plist isKindOfClass:[NSDictionary class]]) {
        BOOL success = [(NSDictionary *)plist writeToURL:plistUrl atomically:YES];
        if (success) {
            NSLog(@"save plist success!");
        } else {
            NSLog(@"save plist fail!");
        }
    } else if ([plist isKindOfClass:[NSArray class]]) {
        BOOL success = [(NSArray *)plist writeToURL:plistUrl atomically:YES];
        if (success) {
            NSLog(@"save plist success!");
        } else {
            NSLog(@"save plist fail!");
        }
    } else {
        NSLog(@"data convert to plist fail!");
    }
}

#pragma mark - create tree data source
- (NSTreeNode *)doTreeNodeFromData:(P_Data *) data
{
    NSArray <P_Data *>*children = data.childDatas;
    // The image for the nodeData is lazily filled in, for performance.
    // Create a NSTreeNode to wrap our model object. It will hold a cache of things such as the children.
    NSTreeNode *result = [NSTreeNode treeNodeWithRepresentedObject:data];
    // Walk the dictionary and create NSTreeNodes for each child.
    for (P_Data * item in children) {
        // A particular item can be another dictionary (ie: a container for more children), or a simple string
        NSTreeNode *childTreeNode;
        //if ([item isKindOfClass:[OutlineViewData class]])
        if (item.hasChild)
        {
            // Recursively create the child tree node and add it as a child of this tree node
            childTreeNode = [self doTreeNodeFromData:item];
        } else {
            // It is a regular leaf item with just the name
            childTreeNode = [NSTreeNode treeNodeWithRepresentedObject:item];
            // [childNodeData release];
        }
        // Now add the child to this parent tree node
        [[result mutableChildNodes] addObject:childTreeNode];
    }
    return result;
}

// The NSOutlineView uses 'nil' to indicate the root item. We return our root tree node for that case.
- (NSArray *)childrenForItem:(id)item {
    if (item == nil) {
        return [_rootTreeNode childNodes];
    } else {
        return [item childNodes];
    }
}

#pragma mark - NSOutlineViewDataSource
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item
{
    // 'item' may potentially be nil for the root item.
    NSArray *children = [self childrenForItem:item];
    return [children count];
}
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item
{
    // 'item' may potentially be nil for the root item.
    NSArray *children = [self childrenForItem:item];
    // This will return an NSTreeNode with our model object as the representedObject
    return [children objectAtIndex:index];
}
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    // 'item' will always be non-nil. It is an NSTreeNode, since those are always the objects we give NSOutlineView. We access our model object from it.
    P_Data *p = [item representedObject];
    // We can expand items if the model tells us it is a container
    return p.isExpandable;
}

/* NOTE: this method is optional for the View Based OutlineView.
 */
- (nullable id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn byItem:(nullable id)item
{
    return nil;
}

// To get the "group row" look, we implement this method.
- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item {
    // Query our model for the answer to this question
    return YES;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    P_Data *p = [item representedObject];
    // For all the other columns, we don't do anything.
    NSString *identifier =[tableColumn identifier];
    if ([identifier isEqualToString:PlistColumnIdentifier.Key])
    {
        NSTextFieldCell *textCell =(NSTextFieldCell *)cell;
        [textCell setStringValue:p.name];
    }
    if ([identifier isEqualToString:PlistColumnIdentifier.Type])
    {
        NSTextFieldCell *textCell =(NSTextFieldCell *)cell;
        [textCell setStringValue:p.type];
    }
    else if ([identifier isEqualToString:PlistColumnIdentifier.Value])
    {
        NSTextFieldCell *textCell =(NSTextFieldCell *)cell;
        [textCell setStringValue:p.valueDesc];
    }
}

@end
