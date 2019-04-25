//
//  P_PropertyList2ButtonCellView.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/23.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_PropertyList2ButtonCellView.h"
#import "P_Data+P_Exten.h"

@interface P_PropertyList2ButtonCellView ()

@property (weak) IBOutlet NSButton *minusButton;
@property (weak) IBOutlet NSButton *plusButton;

@end

@implementation P_PropertyList2ButtonCellView

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.plusButton.hidden = self.minusButton.hidden = YES;
}

- (void)p_setShowsControlButtons:(BOOL)showsControlButtons addButtonEnabled:(BOOL)addButtonEnabled deleteButtonEnabled:(BOOL)deleteButtonEnabled
{
    self.plusButton.hidden = self.minusButton.hidden = !showsControlButtons;
    
    self.plusButton.enabled = addButtonEnabled;
    self.minusButton.enabled = deleteButtonEnabled;
}

- (IBAction)p_plusAction:(id)sender {
    
}

- (IBAction)p_minusAction:(id)sender {
    
}


@end
