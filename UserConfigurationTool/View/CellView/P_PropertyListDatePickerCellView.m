//
//  P_PropertyListDatePickerCellView.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/23.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_PropertyListDatePickerCellView.h"
#import "P_PropertyListDatePicker.h"

@interface P_PropertyListDatePickerCellView ()

@property (weak) IBOutlet P_PropertyListDatePicker *datePicker;


@end

@implementation P_PropertyListDatePickerCellView

- (void)p_setControlWithDate:(NSDate *)date
{
    _datePicker.dateValue = date;
}

- (void)p_setControlEditable:(BOOL)editable
{
    [super p_setControlEditable:editable];
    _datePicker.enabled = editable;
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle
{
    [super setBackgroundStyle:backgroundStyle];
    
    [_datePicker.cell setBackgroundStyle:backgroundStyle];
}

- (IBAction)p_dateChanged:(P_PropertyListDatePicker *)sender {
    if ([self.delegate respondsToSelector:@selector(p_propertyListCellDidEndEditing:value:)]) {
        id realValue = [self.delegate p_propertyListCellDidEndEditing:self value:sender.dateValue];
        if ([realValue isKindOfClass:[NSDate class]]) {
            [self p_setControlWithDate:realValue];
        }
    }
}

@end
