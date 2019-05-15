//
//  P_SearchView.m
//  UserConfigurationTool
//
//  Created by 丁嘉睿 on 2019/5/15.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_SearchView.h"

@interface P_SearchView () <NSSearchFieldDelegate>

@property (weak) IBOutlet NSSearchField *searchField;

@end

@implementation P_SearchView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
//    NSLog(@"drawRect");
}

- (void)awakeFromNib
{
    [super awakeFromNib];
//    NSLog(@"awakeFromNib");
    _searchField.delegate = self;
    _searchField.enabled = NO;
}

- (void)startSearch
{
    _searchField.enabled = YES;
    [_searchField becomeFirstResponder];
}

- (NSString *)searchString
{
    return _searchField.stringValue;
}

#pragma mark - NSSearchFieldDelegate
- (void)searchFieldDidEndSearching:(NSSearchField *)sender
{
//    NSLog(@"searchFieldDidEndSearching");
}

- (void)searchFieldDidStartSearching:(NSSearchField *)sender
{
//    NSLog(@"searchFieldDidStartSearching");
}

#pragma mark - NSControlTextEditingDelegate
- (void)controlTextDidChange:(NSNotification *)notification
{
    id obj = notification.object;
    if ([obj isKindOfClass:[NSSearchField class]]) {
        if ([self.delegate respondsToSelector:@selector(searchView:didChangeSearchString:)]) {
            [self.delegate searchView:self didChangeSearchString:self.searchString];
        }
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    if ([control isEqual:_searchField]) {
        if ([self.delegate respondsToSelector:@selector(searchView:doCommandBySelector:)]) {
            return [self.delegate searchView:self doCommandBySelector:commandSelector];
        }
    }
    return NO;
}

@end
