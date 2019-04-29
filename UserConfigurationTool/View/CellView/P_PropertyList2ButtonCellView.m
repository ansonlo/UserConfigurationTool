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
@property (weak) IBOutlet NSComboBox *comboBox;

@property (weak) IBOutlet NSLayoutConstraint *comboBoxTrailing;
@end

@implementation P_PropertyList2ButtonCellView

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.plusButton.hidden = self.minusButton.hidden = YES;
}

- (void)p_setShowsControlButtons:(BOOL)showsControlButtons addButtonEnabled:(BOOL)addButtonEnabled deleteButtonEnabled:(BOOL)deleteButtonEnabled
{
    self.comboBoxTrailing.constant = showsControlButtons ? self.frame.size.width-self.plusButton.frame.origin.x+2 : 2;
    
    self.plusButton.hidden = self.minusButton.hidden = !showsControlButtons;
    
    self.plusButton.enabled = addButtonEnabled;
    self.minusButton.enabled = deleteButtonEnabled;
}

- (IBAction)p_plusAction:(id)sender {
    
}

- (IBAction)p_minusAction:(id)sender {
    
}


@end
