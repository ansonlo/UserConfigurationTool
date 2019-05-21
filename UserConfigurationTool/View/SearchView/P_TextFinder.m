//
//  P_TextFinder.m
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/5/20.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#import "P_TextFinder.h"
#import "P_Data.h"

struct P_TF_RANGE {
    /** 起始 */
    NSUInteger firstIndex;
    /** 结束 */
    NSUInteger lastIndex;
};
typedef struct P_TF_RANGE P_TF_RANGE;

NS_INLINE P_TF_RANGE P_TF_MakeRange(NSUInteger firstIndex, NSUInteger lastIndex) {
    P_TF_RANGE r;
    r.firstIndex = firstIndex;
    r.lastIndex = lastIndex;
    return r;
}
NS_INLINE BOOL P_TF_LocationInRange(NSUInteger loc, P_TF_RANGE range) {
    return ((loc >= range.firstIndex) && (loc < range.lastIndex)) ? YES : NO;
}

NS_INLINE NSRange P_TF_Range2NSRange(P_TF_RANGE range) {
    return NSMakeRange(range.firstIndex, range.lastIndex-range.firstIndex);
}

@interface P_TF_COLUMN : NSObject
/** 第几列 */
@property (nonatomic, assign) NSUInteger idx;
/** 文字在全文的范围 */
@property (nonatomic, assign) P_TF_RANGE range;
/** 文字 */
@property (nonatomic, copy) NSString *text;

@end

@implementation P_TF_COLUMN

@end

@interface P_TF_ROW : NSObject
/** 第几行 */
@property (nonatomic, assign) NSUInteger idx;
/** 文字在全文的范围 */
@property (nonatomic, readonly) P_TF_RANGE range;
/** 列 */
@property (nonatomic, strong) NSArray <P_TF_COLUMN *> *columns;
/** 对象 */
@property (nonatomic, strong) P_Data *p;

@end

@implementation P_TF_ROW

- (P_TF_RANGE)range
{
    return P_TF_MakeRange(self.columns.firstObject.range.firstIndex, self.columns.lastObject.range.lastIndex);
}

@end


@interface P_TextFinder ()

@property (nonatomic, strong) NSArray <P_TF_ROW *> *finderIndex;

@property (nonatomic, weak) NSOutlineView *outlineView;

@end

@implementation P_TextFinder

- (instancetype)initWithOutLineView:(NSOutlineView *)outlineView
{
    self = [self init];
    if (self) {
        self.findBarContainer = outlineView.enclosingScrollView;
        _outlineView = outlineView;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    self.client = self;
    
    self.findIndicatorNeedsUpdate = true;
    self.incrementalSearchingEnabled = true;
    self.incrementalSearchingShouldDimContentView = false;
    
    [self addObserver:self forKeyPath:@"incrementalMatchRanges" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"incrementalMatchRanges"];
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"incrementalMatchRanges"]) {
        
        NSArray<NSValue *> *matches = self.incrementalMatchRanges;
    
        for (NSValue *v in matches) {
            NSRange range = v.rangeValue;
            P_TF_ROW *r = [self indexTupleFrom:range.location];
            [self.outlineView expandItem:r.p.parentData];
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setRoot:(P_Data *)root
{
    _root = root;
    [self setNeedUpdateFinderIndex];
}

#pragma mark - NSTextFinderClient 实现协议的准备工作
#pragma mark 创建协议数据源
- (NSArray <P_TF_ROW *> *)finderIndex
{
    if (_finderIndex == nil) {
        _finderIndex = [self calculateFinderIndex];
    }
    return _finderIndex;
}

- (NSArray <P_TF_ROW *> *)calculateFinderIndex
{
    NSMutableArray *arrays = [NSMutableArray array];
    
    __block NSInteger theAccumulatedIndex = 0;
    
    [self recursionP_Data:self.root usingBlock:^(P_Data *p, NSUInteger idx) {
        
        P_TF_COLUMN *c1 = [P_TF_COLUMN new];
        c1.idx = 0;
        c1.range = P_TF_MakeRange(theAccumulatedIndex, theAccumulatedIndex+p.key.length);
        c1.text = p.key;
        theAccumulatedIndex += p.key.length;
        
        /** Dictionary 与 Array 不参与搜索 */
        P_TF_COLUMN *c2 = nil;
        if (!([p.type isEqualToString: Plist.Dictionary] || [p.type isEqualToString: Plist.Array])) {
            c2 = [P_TF_COLUMN new];
            c2.idx = 2;
            c2.range = P_TF_MakeRange(theAccumulatedIndex, theAccumulatedIndex+p.valueDesc.length);
            c2.text = p.valueDesc;
            theAccumulatedIndex += p.valueDesc.length;
        }
        
        P_TF_ROW *r = [P_TF_ROW new];
        r.idx = idx;
        if (c2) {
            r.columns = @[c1, c2];
        } else {
            r.columns = @[c1];
        }
        r.p = p;
        
        [arrays addObject:r];
    }];
    
    return arrays.count > 0 ? arrays : nil;
}

- (void)recursionP_Data:(P_Data *)p usingBlock:(void (^)(P_Data *p, NSUInteger idx))block
{
    NSUInteger index = 0;
    [self recursionP_Data:p index:&index usingBlock:block];
}

- (void)recursionP_Data:(P_Data *)p index:(NSUInteger *)index usingBlock:(void (^)(P_Data *p, NSUInteger idx))block
{
    if (block) {
        if (p) {
            block(p, *index);
            *index += 1;
            for (P_Data *s_p in p.childDatas) {
                [self recursionP_Data:s_p index:index usingBlock:block];
            }
        }
    }
}

#pragma mark 当前匹配的位置在第几行
- (P_TF_ROW *)indexTupleFrom:(NSUInteger)location
{
    P_TF_ROW *row = nil;
    
    NSInteger theRow = [self binarySearch:location range:P_TF_MakeRange(0, _finderIndex.count)];
    
    if (theRow != NSNotFound) {
        row = _finderIndex[theRow];
    }
    
    return row;
}

/** 二叉树查找 */
- (NSInteger)binarySearch:(NSUInteger)location range:(P_TF_RANGE)range
{
    if (range.firstIndex >= range.lastIndex)
    {
        return NSNotFound;
    }
    else
    {
        NSUInteger theMiddleIndex = range.firstIndex + (range.lastIndex - range.firstIndex) / 2;
        P_TF_ROW *theMiddleRow = _finderIndex[theMiddleIndex];
        
        if (P_TF_LocationInRange(location, theMiddleRow.range)) {
            return theMiddleIndex;
        } else if (theMiddleRow.range.firstIndex < location) {
            return [self binarySearch:location range:P_TF_MakeRange(theMiddleIndex+1, range.lastIndex)];
        } else if (theMiddleRow.range.lastIndex > location) {
            return [self binarySearch:location range:P_TF_MakeRange(range.firstIndex, theMiddleIndex)];
        }
        
        return NSNotFound;
    }
}

#pragma mark 刷新数据源
- (void)setNeedUpdateFinderIndex
{
    [self noteClientStringWillChange];
    
    _finderIndex = nil;
}


#pragma mark - NSTextFinderClient 正式实现协议
- (BOOL)isSelectable
{
    return YES;
}

- (BOOL)allowsMultipleSelection
{
    return NO;
}

- (BOOL)isEditable
{
    return NO;
}

/** 所有搜索内容的长度 */
- (NSUInteger)stringLength
{
    /** 所有需要搜索的文字的长度 */
    P_TF_ROW *r = self.finderIndex.lastObject;
    if (r) {
        return r.range.lastIndex;
    }
    return 0;
}

/** 搜索内容的集合，将会通过索引返回对应的搜索内容 */
- (NSString *)stringAtIndex:(NSUInteger)characterIndex effectiveRange:(NSRangePointer)outRange endsWithSearchBoundary:(BOOL *)outFlag
{
    NSString *text = @"";
    /** 获取搜索匹配的行文字 */
    P_TF_ROW *r = [self indexTupleFrom:characterIndex];
    if (r) {
        for (P_TF_COLUMN *c in r.columns) {
            if (P_TF_LocationInRange(characterIndex, c.range)) {
                *outRange = P_TF_Range2NSRange(c.range);
                *outFlag = true;
                text = c.text;
                break;
            }
        }
    }
    
    return text;
}

/** 首个选中的范围，适配下一个搜索结果的标记 */
- (NSRange)firstSelectedRange
{
    /** 首个选中的位置 */
    if (self.outlineView.selectedRow != -1) {
        /** 搜索数据源只有2列 */
        NSInteger column = MIN(self.outlineView.selectedColumn, 1);
        NSInteger row = self.outlineView.selectedRow;
        NSInteger offset = [self __recursionSelectedRowOffet:self.outlineView.selectedRow];
        row += offset;
        
        if (_finderIndex.count > row) {
            P_TF_ROW *r = _finderIndex[row];
            
            if (r.columns.count > column) {
                return P_TF_Range2NSRange(r.columns[column].range);
            }
            return P_TF_Range2NSRange(r.range);
        }
    }
    return NSMakeRange(0, 0);
}

/** 没有触发过 */
- (NSArray<NSValue *> *)selectedRanges
{
    return @[[NSValue valueWithRange:self.firstSelectedRange]];
}

/** 光标不在输入框时，每一个搜索结果都会触发 */
- (void)setSelectedRanges:(NSArray<NSValue *> *)selectedRanges
{
    if (selectedRanges.count) {
        NSRange range = selectedRanges.firstObject.rangeValue;
        
        P_TF_ROW *r = [self indexTupleFrom:range.location];
        if (r) {
            NSInteger selectionRow = [self.outlineView rowForItem:r.p];
            if (selectionRow != -1) {
                [self.outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectionRow] byExtendingSelection:NO];
            }
        }
    } else {
        [self.outlineView deselectAll:nil];
    }
}

/** 滚动到搜索范围，每一次搜索结果都会触发 */
- (void)scrollRangeToVisible:(NSRange)range
{
    P_TF_ROW *r = [self indexTupleFrom:range.location];
    if (r) {
        NSInteger selectionRow = [self.outlineView rowForItem:r.p];
        if (selectionRow != -1) {
            [self.outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectionRow] byExtendingSelection:NO];
            [self.outlineView scrollRowToVisible:selectionRow];
        }
    }
}

/** 绘制黄色框在那个view上 */
- (NSView *)contentViewAtIndex:(NSUInteger)index effectiveCharacterRange:(NSRangePointer)outRange
{
    P_TF_ROW *r = [self indexTupleFrom:index];
    if (r) {
        
        NSInteger row = [self.outlineView rowForItem:r.p];
        NSInteger column = -1;
        for (P_TF_COLUMN *c in r.columns) {
            if (P_TF_LocationInRange(index, c.range)) {
                *outRange = P_TF_Range2NSRange(c.range);
                column = c.idx;
                break;
            }
        }
        
        if (row != -1 && column != -1) {
            NSTableCellView *cellView = [self.outlineView viewAtColumn:column row:row makeIfNecessary:NO];
            
            return cellView.textField;
        }
        
    }
    
    return nil;
}

/** 匹配range的文字位置，系统会绘制一块黄色框 */
- (nullable NSArray<NSValue *> *)rectsForCharacterRange:(NSRange)range
{
    P_TF_ROW *r = [self indexTupleFrom:range.location];
    if (r) {
        
        NSInteger row = [self.outlineView rowForItem:r.p];
        NSInteger column = -1;
        NSInteger offset = 0;
        for (P_TF_COLUMN *c in r.columns) {
            if (P_TF_LocationInRange(range.location, c.range)) {
                column = c.idx;
                offset = c.range.firstIndex;
                break;
            }
        }
        
        if (row != -1 && column != -1) {
            NSTableCellView *cellView = [self.outlineView viewAtColumn:column row:row makeIfNecessary:NO];
            
            if (cellView) {
                
                NSRange localRange = NSMakeRange(range.location-offset, range.length);
                
                NSSize textFieldSize = cellView.textField.bounds.size;
                NSAttributedString *atrString = cellView.textField.attributedStringValue;
                
                /** 计算匹配文字范围 */
                NSAttributedString *a_str = [atrString attributedSubstringFromRange:NSMakeRange(0, NSMaxRange(localRange))];
                NSAttributedString *b_str = [atrString attributedSubstringFromRange:NSMakeRange(0, localRange.location)];
                
                CGRect a_rect = [a_str boundingRectWithSize:textFieldSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
                CGRect b_rect = [b_str boundingRectWithSize:textFieldSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
                
                CGRect rect = CGRectZero;
                rect.origin.x = ceil(CGRectGetMaxX(b_rect))+1.f;
                rect.origin.y = ceil(a_rect.origin.y);
                rect.size.width = ceil(CGRectGetMaxX(a_rect)) - ceil(CGRectGetMaxX(b_rect));
                rect.size.height = ceil(a_rect.size.height);
                
                return @[[NSValue valueWithRect:rect]];
            }
        }
    }
    return @[];
}

/** 匹配范围，可以限制只能搜索某个范围的特性 */
- (NSArray<NSValue *> *)visibleCharacterRanges
{
    NSArray<NSValue *> *matches = self.incrementalMatchRanges;
    
    if (matches.count == 0) {
        return @[];
    }

    
    CGRect theVisibleRect = self.outlineView.visibleRect;
    NSRange theVisibleRowRange = [self.outlineView rowsInRect:theVisibleRect];
    
    NSInteger theFirstVisibleRow = theVisibleRowRange.location;
    NSInteger theLastVisibleRow  = NSMaxRange(theVisibleRowRange) - 1;
    
    P_TF_ROW *theFirstRow = _finderIndex[theFirstVisibleRow];
    NSInteger theFirstIndex = theFirstRow.range.firstIndex;
    
    P_TF_ROW *theLastRow  = _finderIndex[theLastVisibleRow];
    NSInteger theLastIndex = theLastRow.range.lastIndex;
    
    return @[[NSValue valueWithRange:NSMakeRange(theFirstIndex, theLastIndex-theFirstIndex)]];
}

/** 具体的文字位置 */
- (void)drawCharactersInRange:(NSRange)range forContentView:(NSView *)view
{
    NSArray<NSValue *> *theRectArray = [self rectsForCharacterRange:range];

    for (NSValue *theRectValue in theRectArray) {
        [view drawRect:theRectValue.rectValue];
    }
}

#pragma mark - private

#pragma mark 递归查询收起的行数（选中行以上的收起行数）
- (NSInteger)__recursionSelectedRowOffet:(NSInteger)selectedRow
{
    NSInteger offset = 0;
    if (selectedRow == -1) {
        return offset;
    }
    id item = [self.outlineView itemAtRow:selectedRow];
    if ([self.outlineView isExpandable:item] && ![self.outlineView isItemExpanded:item]) {
        offset += [self __recursionItemChildrenCount:item];
    }
    offset += [self __recursionSelectedRowOffet:selectedRow-1];
    
    return offset;
}

#pragma mark 递归查询对象的子树数量
- (NSInteger)__recursionItemChildrenCount:(P_Data *)item
{
    NSArray *childDatas = item.childDatas;
    NSInteger count = childDatas.count;
    for (P_Data *p in childDatas) {
        count += [self __recursionItemChildrenCount:p];
    }
    return count;
}

@end
