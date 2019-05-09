//
//  P_PropertyListDatePicker.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/23.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_PropertyListDatePicker.h"
#import <objc/runtime.h>

static NSPopover* __P_PropertyListDatePickerPopover;
static NSDatePicker* __P_PropertyListPopoverDatePicker;
/** ThreadLocal的实例代表了一个线程局部的变量，每条线程都只能看到自己的值，并不会意识到其它的线程中也存在该变量。
 它采用采用空间来换取时间的方式，解决多线程中相同变量的访问冲突问题。 */
static thread_local BOOL __drawingDatePicker;

@interface NSBezierPath (P_PropertyListEditorDatePickerCustomization)

@end

@implementation NSBezierPath (P_PropertyListEditorDatePickerCustomization)

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method m1 = class_getClassMethod(NSBezierPath.class, @selector(__p_bezierPathWithRoundedRect:xRadius:yRadius:));
        Method m2 = class_getClassMethod(NSBezierPath.class, @selector(bezierPathWithRoundedRect:xRadius:yRadius:));
        method_exchangeImplementations(m1, m2);
    });
}

+ (NSBezierPath *)__p_bezierPathWithRoundedRect:(NSRect)rect xRadius:(CGFloat)xRadius yRadius:(CGFloat)yRadius
{
    if(__drawingDatePicker == YES)
    {
        [[NSColor.alternateSelectedControlColor highlightWithLevel:0.35] set];
    }
    
    NSBezierPath* rv = [self __p_bezierPathWithRoundedRect:rect xRadius:xRadius yRadius:yRadius];
    
    return rv;
}

@end

@interface P_PropertyListDatePickerCell : NSDatePickerCell

@end

@implementation P_PropertyListDatePickerCell

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        
    }
    
    return self;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    __drawingDatePicker = YES;
    [super drawWithFrame:cellFrame inView:controlView];
    __drawingDatePicker = NO;
}

//This is faster than setting the text color when the background color changes.
- (NSColor*)_textColorBasedOnEnabledState
{
    return self.isEnabled ? self.backgroundStyle == NSBackgroundStyleEmphasized ? NSColor.labelColor : NSColor.controlTextColor : self.backgroundStyle == NSBackgroundStyleEmphasized ? [NSColor valueForKey:@"_alternateDisabledSelectedControlTextColor"] : NSColor.disabledControlTextColor;
    
}

@end


@interface _P_PropertyListDatePickerInnerCell : NSCell

@property (nonatomic, copy) NSArray<NSCell*>* childCells;

@end

@implementation _P_PropertyListDatePickerInnerCell

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle
{
    [self.childCells enumerateObjectsUsingBlock:^(NSCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setBackgroundStyle:backgroundStyle];
    }];
}

- (void)setHighlighted:(BOOL)highlighted
{
    
}

@end

@interface _P_PropertyListDatePicker : NSDatePicker

@end

@implementation _P_PropertyListDatePicker

- (BOOL)becomeFirstResponder
{
    BOOL rv = [super becomeFirstResponder];
    
    if(rv)
    {
        __P_PropertyListPopoverDatePicker.dateValue = self.dateValue;
        __P_PropertyListPopoverDatePicker.target = self.target;
        __P_PropertyListPopoverDatePicker.action = self.action;
        
        [__P_PropertyListDatePickerPopover showRelativeToRect:self.bounds ofView:self preferredEdge:NSRectEdgeMinY];
        
    }
    
    return rv;
}

- (BOOL)resignFirstResponder
{
    BOOL rv = [super resignFirstResponder];
    
    if(rv)
    {
        [self unbind:NSValueBinding];
        __P_PropertyListPopoverDatePicker.target = nil;
        __P_PropertyListPopoverDatePicker.action = nil;
        
        [__P_PropertyListDatePickerPopover close];
    }
    
    return rv;
}

@end

@interface P_PropertyListDatePicker ()
{
    NSDatePicker* _datePicker;
    NSDatePicker* _timePicker;
}
@end

@implementation P_PropertyListDatePicker

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __P_PropertyListPopoverDatePicker = [NSDatePicker new];
        __P_PropertyListPopoverDatePicker.datePickerStyle = NSClockAndCalendarDatePickerStyle;
        __P_PropertyListPopoverDatePicker.datePickerElements = NSTimeZoneDatePickerElementFlag | NSYearMonthDayDatePickerElementFlag | NSEraDatePickerElementFlag;
        __P_PropertyListPopoverDatePicker.bordered = NO;
        __P_PropertyListPopoverDatePicker.drawsBackground = NO;
        [__P_PropertyListPopoverDatePicker sizeToFit];
        
        NSViewController* vc = [NSViewController new];
        vc.view = __P_PropertyListPopoverDatePicker;
        
        __P_PropertyListDatePickerPopover = [NSPopover new];
        __P_PropertyListDatePickerPopover.contentViewController = vc;
    });
}

- (void)prepareForInterfaceBuilder
{
    _timePicker.dateValue = _datePicker.dateValue = [NSDate date];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    [_datePicker setEnabled:enabled];
    [_timePicker setEnabled:enabled];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSFont* font = [NSFont monospacedDigitSystemFontOfSize:NSFont.smallSystemFontSize weight:NSFontWeightRegular];
    
    _datePicker = [_P_PropertyListDatePicker new];
    _datePicker.cell = [P_PropertyListDatePickerCell new];
    _datePicker.font = font;
    _datePicker.datePickerStyle = NSTextFieldDatePickerStyle;
    _datePicker.datePickerElements = NSYearMonthDayDatePickerElementFlag | NSEraDatePickerElementFlag;
    _datePicker.bordered = NO;
    _datePicker.drawsBackground = NO;
    _datePicker.translatesAutoresizingMaskIntoConstraints = NO;
    _datePicker.target = self;
    _datePicker.action = @selector(_internalDatePickerValueChanged:);
    
    _timePicker = [NSDatePicker new];
    _timePicker.cell = [P_PropertyListDatePickerCell new];
    _timePicker.font = font;
    _timePicker.datePickerStyle = NSTextFieldDatePickerStyle;
    _timePicker.datePickerElements = NSHourMinuteSecondDatePickerElementFlag | NSTimeZoneDatePickerElementFlag;
    _timePicker.bordered = NO;
    _timePicker.drawsBackground = NO;
    _timePicker.translatesAutoresizingMaskIntoConstraints = NO;
    _timePicker.target = self;
    _timePicker.action = @selector(_internalDatePickerValueChanged:);
    
    _P_PropertyListDatePickerInnerCell* cell = [_P_PropertyListDatePickerInnerCell new];
    cell.childCells = @[_datePicker.cell, _timePicker.cell];
    cell.bordered = NO;
    self.cell = cell;
    
    [self addSubview:_datePicker];
    [self addSubview:_timePicker];
    
    [_datePicker setContentHuggingPriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationHorizontal];
    [_datePicker setContentCompressionResistancePriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationHorizontal];
    [_timePicker setContentHuggingPriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationHorizontal];
    [_timePicker setContentCompressionResistancePriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationHorizontal];
    [NSLayoutConstraint activateConstraints:@[
                                              [self.heightAnchor constraintEqualToAnchor:_datePicker.heightAnchor],
                                              [self.leadingAnchor constraintEqualToAnchor:_datePicker.leadingAnchor],
                                              [self.centerYAnchor constraintEqualToAnchor:_datePicker.centerYAnchor],
                                              [_timePicker.leadingAnchor constraintEqualToAnchor:_datePicker.trailingAnchor constant:2],
                                              [self.centerYAnchor constraintEqualToAnchor:_timePicker.centerYAnchor],
                                              [self.trailingAnchor constraintEqualToAnchor:_timePicker.trailingAnchor],
                                              ]];
    
    [self setContentHuggingPriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationHorizontal];
    [self setContentCompressionResistancePriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationHorizontal];
}

- (void)_setDateValue:(NSDate *)dateValue sendAction:(BOOL)sendAction
{
    self.objectValue = dateValue;
    
    _datePicker.dateValue = self.dateValue;
    _timePicker.dateValue = self.dateValue;
    if(__P_PropertyListPopoverDatePicker.target == self)
    {
        __P_PropertyListPopoverDatePicker.dateValue = self.dateValue;
    }
    
    if(sendAction)
    {
        [self sendAction:self.action to:self.target];
    }
}

- (NSDate *)dateValue
{
    return self.objectValue;
}

- (void)setDateValue:(NSDate *)dateValue
{
    [self _setDateValue:dateValue sendAction:NO];
}

- (IBAction)_internalDatePickerValueChanged:(id)sender
{
    [self _setDateValue:[sender dateValue] sendAction:YES];
}

@end
