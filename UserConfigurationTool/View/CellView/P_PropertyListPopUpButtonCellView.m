//
//  P_PropertyListPopUpButtonCellView.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/23.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_PropertyListPopUpButtonCellView.h"

@interface P_PropertyListPopUpButtonCellView ()

@property (weak) IBOutlet NSPopUpButton *typeButton;

@end

@implementation P_PropertyListPopUpButtonCellView

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self p_setShowsControlButtons:NO];
}

- (void)p_setControlWithBoolean:(BOOL)boolean
{
    [self.typeButton selectItemAtIndex:(NSInteger)boolean];
}

- (void)p_setControlWithString:(P_PlistTypeName)str
{
    [self.typeButton selectItemWithTitle:str];
}

- (void)p_setControlEditable:(BOOL)editable
{
    [super p_setControlEditable:editable];
    _typeButton.enabled = editable;
}

- (void)p_setShowsControlButtons:(BOOL)showsControlButtons
{
    [self.typeButton.cell setArrowPosition:(showsControlButtons ? NSPopUpArrowAtBottom : NSPopUpNoArrow)];
}

- (void)p_callDelegate:(id)value
{
    if ([self.delegate respondsToSelector:@selector(p_propertyListCellDidEndEditing:value:)]) {
        id realValue = [self.delegate p_propertyListCellDidEndEditing:self value:value];
        if ([realValue isKindOfClass:[NSString class]]) {
            [self p_setControlWithString:realValue];
        } else if ([realValue isKindOfClass:[NSNumber class]]) {
            [self p_setControlWithBoolean:[realValue boolValue]];
        }
    }
}

- (IBAction)p_menuDidSelecter:(NSMenuItem *)sender {
    [self p_callDelegate:sender.title];
}


@end
