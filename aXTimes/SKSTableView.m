//
//  SKSTableView.m
//  SKSTableView
//
//  Created by Sakkaras on 26/12/13.
//  Copyright (c) 2013 Sakkaras. All rights reserved.
//

#import "SKSTableView.h"
#import "SKSTableViewCell.h"
#import "SKSTableViewCellMulti.h"
#import "SKSTableViewCellIndicator.h"
#import <objc/runtime.h>

static NSString * const kIsExpandedKey = @"isExpanded";
static NSString * const kSubrowsKey = @"subrowsCount";
static NSString * const kSubSubrowsKey = @"subSubrowsCount";

CGFloat const kDefaultCellHeight = 44.0f;

#pragma mark - SKSTableView

@interface SKSTableView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSMutableDictionary *expandableCells;
@property (nonatomic, copy) NSMutableDictionary *expandableSubCells;

@end

@implementation SKSTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _shouldExpandOnlyOneCell = NO;
        _multiSelectPossible = NO;
        _expandableSubCells = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        _shouldExpandOnlyOneCell = NO;
        _multiSelectPossible = NO;
        _expandableSubCells = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setSKSTableViewDelegate:(id<SKSTableViewDelegate>)SKSTableViewDelegate
{
    self.dataSource = self;
    self.delegate = self;
    
//    [self setSeparatorColor:[UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0]];
    
    if (SKSTableViewDelegate)
        _SKSTableViewDelegate = SKSTableViewDelegate;
}

//- (void)setSeparatorColor:(UIColor *)separatorColor
//{
//    [super setSeparatorColor:separatorColor];
//    [SKSTableViewCellIndicator setIndicatorColor:separatorColor];
//}

- (NSMutableDictionary *)expandableSubCells
{
    if (!_expandableSubCells)
    {
        
        _expandableSubCells = [NSMutableDictionary dictionary];
    }
    return _expandableSubCells;
}

- (NSMutableDictionary *)expandableCells
{
    if (!_expandableCells)
    {
        _expandableCells = [NSMutableDictionary dictionary];
        [self.expandableSubCells removeAllObjects];
        
        NSInteger numberOfSections = [self.SKSTableViewDelegate numberOfSectionsInTableView:self];
        for (NSInteger section = 0; section < numberOfSections; section++)
        {
            NSInteger numberOfRowsInSection = [self.SKSTableViewDelegate tableView:self
                                                             numberOfRowsInSection:section];
            
            NSMutableArray *rows = [NSMutableArray array];
            for (NSInteger row = 0; row < numberOfRowsInSection; row++)
            {
                NSMutableArray *subRows = [NSMutableArray array];

                NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
                NSInteger numberOfSubrows = [self.SKSTableViewDelegate tableView:self
                                                        numberOfSubRowsAtSection:rowIndexPath.section
                                                                           atRow:rowIndexPath.row];
                BOOL isExpandedInitially = NO;
                if ([self.SKSTableViewDelegate respondsToSelector:@selector(tableView:shouldExpandSubRowsOfCellAtIndexPath:)])
                {
                    isExpandedInitially = [self.SKSTableViewDelegate tableView:self shouldExpandSubRowsOfCellAtIndexPath:rowIndexPath];
                }
                
                NSMutableDictionary *rowInfo = [NSMutableDictionary dictionaryWithObjects:@[@(isExpandedInitially), @(numberOfSubrows)]
                                                                                  forKeys:@[kIsExpandedKey, kSubrowsKey]];
                
                [rows addObject:rowInfo];
                
                for (NSInteger subRow = 0; subRow < numberOfSubrows; subRow++)
                {
                    NSInteger numberOfSubSubrows = [self.SKSTableViewDelegate tableView:self
                                                            numberOfSubSubRowsAtSection:section
                                                                                  atRow:row
                                                                               atSubRow:subRow + 1];
                    BOOL isExpandedInitially = NO;
                    if ([self.SKSTableViewDelegate respondsToSelector:@selector(tableView:shouldExpandSubSubRowsOfCellAtSection:atRow:atSubRow:)])
                    {
                        isExpandedInitially = [self.SKSTableViewDelegate tableView:self
                                             shouldExpandSubSubRowsOfCellAtSection:section
                                                                             atRow:row
                                                                          atSubRow:subRow];
                    }
                    
                    NSMutableDictionary *subRowInfo = [NSMutableDictionary dictionaryWithObjects:@[@(isExpandedInitially), @(numberOfSubSubrows)]
                                                                                         forKeys:@[kIsExpandedKey, kSubSubrowsKey]];
                    
                    [subRows addObject:subRowInfo];
                }
                
                [_expandableSubCells setObject:subRows forKey:@[@(section), @(row)]];
            }
            
            [_expandableCells setObject:rows forKey:@(section)];
        }
    }
    
    return _expandableCells;
}

- (void)refreshData
{
    self.expandableCells = nil;
    
    [super reloadData];
}

- (void)refreshDataWithScrollingToIndexPath:(NSIndexPath *)indexPath
{
    [self refreshData];
    
    if (indexPath.section < [self numberOfSections] &&
        indexPath.row < [self numberOfRowsInSection:indexPath.section])
    {
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - UITableViewDataSource

#pragma mark - Required

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = [_SKSTableViewDelegate tableView:tableView numberOfRowsInSection:section] + [self numberOfExpandedSubrowsInSection:section] + [self numberOfExpandedSubSubrowsInSection:section];
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SKSIndexPath *correspondingIndexPath = [self correspondingIndexPathForRowAtIndexPath:indexPath];
    DebugLog(@"section(%ld) row(%ld) subRow(%ld) subSubRow(%ld)",
             (long)correspondingIndexPath.section,
             (long)correspondingIndexPath.row,
             (long)correspondingIndexPath.subRow,
             (long)correspondingIndexPath.subSubRow);

    // fueseschi: somehow identifies via indexPath if it is parent cell
    if ([correspondingIndexPath subRow] == 0)
    {
        UITableViewCell<SKSTableViewCellProtocol> *expandableCell;
        if (!self.multiSelectPossible) {
            expandableCell = (SKSTableViewCell *)[_SKSTableViewDelegate tableView:tableView cellForRowAtIndexPath:correspondingIndexPath];
        } else {
            expandableCell = (SKSTableViewCellMulti *)[_SKSTableViewDelegate tableView:tableView cellForRowAtIndexPath:correspondingIndexPath];
        }
        
        if ([expandableCell respondsToSelector:@selector(setSeparatorInset:)])
        {
            expandableCell.separatorInset = UIEdgeInsetsZero;
        }
        
        BOOL isExpanded = [self.expandableCells[@(correspondingIndexPath.section)][correspondingIndexPath.row][kIsExpandedKey] boolValue];
        
        if ([expandableCell respondsToSelector:@selector(isExpandable)] &&
            [expandableCell isExpandable])
        {
            [expandableCell setExpanded:isExpanded];
            
            if ([expandableCell respondsToSelector:@selector(expandButtonAnimation)]) {
                [expandableCell expandButtonAnimation];
            }
            
            UIButton *expandableButton = [expandableCell getExpandButton];
            if (!self.multiSelectPossible)
            {
                [expandableButton addTarget:tableView
                                     action:@selector(expandableButtonTouched:event:)
                           forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                [expandableButton addTarget:self
                                     action:@selector(expandButtonPressed:)
                           forControlEvents:UIControlEventTouchUpInside];

            }

//            if (isExpanded)
//            {
//                [expandableCell expandButtonAnimation];
//            }
//            else
                if ([expandableCell containsIndicatorView])
            {
                [expandableCell removeIndicatorView];
            }
        }
        else
        {
            if ([expandableCell respondsToSelector:@selector(setExpanded:)] &&
                [expandableCell respondsToSelector:@selector(removeIndicatorView)]) {
                [expandableCell setExpanded:NO];
//                expandableCell.accessoryView = nil;
                [expandableCell removeIndicatorView];
            }
        }
        
        expandableCell.indentationLevel = 0;
       return expandableCell;
    }
    else if ([correspondingIndexPath subRow] != 0 &&
             [correspondingIndexPath subSubRow] == 0)
    {
        UITableViewCell<SKSTableViewCellProtocol> *cell = (UITableViewCell<SKSTableViewCellProtocol> *)[_SKSTableViewDelegate tableView:(SKSTableView *)tableView cellForSubRowAtIndexPath:correspondingIndexPath];
//        cell.backgroundColor = [self separatorColor];
        cell.backgroundView = nil;
        if (!self.multiSelectPossible)
        {
            cell.indentationLevel = 5;
        }
        else
        {
            cell.indentationLevel = 8;
        }
        
        if ([cell respondsToSelector:@selector(setSeparatorInset:)])
        {
            cell.separatorInset = UIEdgeInsetsZero;
        }
        
        DebugLog(@"section(%ld) row(%ld) subRow(%ld) subSubRow(%ld)",
                 (long)correspondingIndexPath.section,
                 (long)correspondingIndexPath.row,
                 (long)correspondingIndexPath.subRow,
                 (long)correspondingIndexPath.subSubRow);
        NSArray *subRows = self.expandableSubCells[@[@(correspondingIndexPath.section), @(correspondingIndexPath.row)]];
        NSInteger digit = correspondingIndexPath.subRow - 1;
        NSDictionary *subRowInformation = subRows[digit];
        BOOL isExpanded = [subRowInformation[kIsExpandedKey] boolValue];
        
        if ([cell respondsToSelector:@selector(isExpandable)] &&
            [cell isExpandable])
        {
            [cell setExpanded:isExpanded];
            
            UIButton *expandableButton = [cell getExpandButton];
            if (!self.multiSelectPossible)
            {
                [expandableButton addTarget:tableView
                                     action:@selector(expandableButtonTouched:event:)
                           forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                [expandableButton addTarget:self
                                     action:@selector(expandButtonPressed:)
                           forControlEvents:UIControlEventTouchUpInside];
                
            }
            
            if (isExpanded)
            {
                [cell expandButtonAnimation];
            }
            else if ([cell containsIndicatorView])
            {
                [cell removeIndicatorView];
            }
        }
        else
        {
            if ([cell respondsToSelector:@selector(setExpanded:)] &&
                [cell respondsToSelector:@selector(removeIndicatorView)]) {
                [cell setExpanded:NO];
//                cell.accessoryView = nil;
                [cell removeIndicatorView];
            }
        }
        
        return cell;
    } else {
        UITableViewCell *cell = [_SKSTableViewDelegate tableView:(SKSTableView *)tableView cellForSubSubRowAtIndexPath:correspondingIndexPath];
//        cell.backgroundColor = [self separatorColor];
        cell.backgroundView = nil;
        cell.indentationWidth = 1;
        cell.indentationLevel = 30;
        return cell;
    }
}

#pragma mark - Optional

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([_SKSTableViewDelegate respondsToSelector:@selector(numberOfSectionsInTableView:)])
    {
        return [_SKSTableViewDelegate numberOfSectionsInTableView:tableView];
    }
    
    return 1;
}

/*
 *  Uncomment the implementations of the required methods.
 */

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:titleForHeaderInSection:)])
        return [_SKSTableViewDelegate tableView:tableView titleForHeaderInSection:section];
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:titleForFooterInSection:)])
        return [_SKSTableViewDelegate tableView:tableView titleForFooterInSection:section];
    
    return nil;
}
//
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)])
//        [_SKSTableViewDelegate tableView:tableView canEditRowAtIndexPath:indexPath];
//    
//    return NO;
//}
//
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)])
//        [_SKSTableViewDelegate tableView:tableView canMoveRowAtIndexPath:indexPath];
//    
//    return NO;
//}
//
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(sectionIndexTitlesForTableView:)])
//        [_SKSTableViewDelegate sectionIndexTitlesForTableView:tableView];
//    
//    return nil;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:sectionForSectionIndexTitle:atIndex:)])
//        [_SKSTableViewDelegate tableView:tableView sectionForSectionIndexTitle:title atIndex:index];
//    
//    return 0;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)])
//        [_SKSTableViewDelegate tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
//}
//
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)])
//        [_SKSTableViewDelegate tableView:tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
//}

#pragma mark - UITableViewDelegate

#pragma mark - Optional

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[SKSTableViewCellMulti class]]) {
        SKSIndexPath *correspondingIndexPath = [self correspondingIndexPathForRowAtIndexPath:indexPath];
        if (correspondingIndexPath.subRow == 0) {
            if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:didSelectRowAtRealIndexPath:)]) {
                [_SKSTableViewDelegate tableView:self didSelectRowAtRealIndexPath:indexPath];
            }
            if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
                [_SKSTableViewDelegate tableView:self didSelectRowAtIndexPath:correspondingIndexPath];
            }
        } else {
            if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:didSelectSubRowAtRealIndexPath:)]) {
                [_SKSTableViewDelegate tableView:self didSelectSubRowAtRealIndexPath:indexPath];
            }
            if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:didSelectSubRowAtIndexPath:)]) {
                [_SKSTableViewDelegate tableView:self didSelectSubRowAtIndexPath:correspondingIndexPath];
            }
        }
        return;
    }
    
    SKSTableViewCell *cell = (SKSTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell respondsToSelector:@selector(isExpandable)]) {
        [self expandActionForTableViewCell:cell atIndexPath:indexPath];
        SKSIndexPath *correspondingIndexPath = [self correspondingIndexPathForRowAtIndexPath:indexPath];
        if (correspondingIndexPath.subRow == 0) {
            if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:didSelectRowAtRealIndexPath:)]) {
                [_SKSTableViewDelegate tableView:self didSelectRowAtRealIndexPath:indexPath];
            }
            if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
                [_SKSTableViewDelegate tableView:self didSelectRowAtIndexPath:correspondingIndexPath];
            }
        } else {
            if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:didSelectSubRowAtRealIndexPath:)]) {
                [_SKSTableViewDelegate tableView:self didSelectSubRowAtRealIndexPath:indexPath];
            }
            if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:didSelectSubRowAtIndexPath:)]) {
                [_SKSTableViewDelegate tableView:self didSelectSubRowAtIndexPath:correspondingIndexPath];
            }
        }
    } else {
        SKSIndexPath *correspondingIndexPath = [self correspondingIndexPathForRowAtIndexPath:indexPath];
        
        if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:didSelectSubRowAtRealIndexPath:)]) {
            [_SKSTableViewDelegate tableView:self didSelectSubRowAtRealIndexPath:indexPath];
        }
        if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:didSelectSubRowAtIndexPath:)]) {
            [_SKSTableViewDelegate tableView:self didSelectSubRowAtIndexPath:correspondingIndexPath];
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)])
        [_SKSTableViewDelegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    
    [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
}

/*
 *  Uncomment the implementations of the required methods.
 */

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)])
//        [_SKSTableViewDelegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
//}
//
//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:willDisplayHeaderView:forSection:)])
//        [_SKSTableViewDelegate tableView:tableView willDisplayHeaderView:view forSection:section];
//}
//
//- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:willDisplayFooterView:forSection:)])
//        [_SKSTableViewDelegate tableView:tableView willDisplayFooterView:view forSection:section];
//}
//
//- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)])
//        [_SKSTableViewDelegate tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
//}
//
//- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:didEndDisplayingHeaderView:forSection:)])
//        [_SKSTableViewDelegate tableView:tableView didEndDisplayingHeaderView:view forSection:section];
//}
//
//- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:didEndDisplayingFooterView:forSection:)])
//        [_SKSTableViewDelegate tableView:tableView didEndDisplayingFooterView:view forSection:section];
//}
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return kDefaultCellHeight;

    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
    {
        return [_SKSTableViewDelegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    return UITableViewAutomaticDimension;
//    
//    NSIndexPath *correspondingIndexPath = [self correspondingIndexPathForRowAtIndexPath:indexPath];
//    if ([correspondingIndexPath subRow] == 0)
//    {
//        if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
//        {
//            return [_SKSTableViewDelegate tableView:tableView heightForRowAtIndexPath:correspondingIndexPath];
//        }
//        
//        return UITableViewAutomaticDimension;
//    }
//    else
//    {
//        if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:heightForSubRowAtIndexPath:)])
//        {
//            return [_SKSTableViewDelegate tableView:self heightForSubRowAtIndexPath:correspondingIndexPath];
//        }
//        
//        return UITableViewAutomaticDimension;
//    }
}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)])
//        [_SKSTableViewDelegate tableView:tableView heightForHeaderInSection:section];
//    
//    return 0;
//}
//
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
        return [_SKSTableViewDelegate tableView:tableView heightForFooterInSection:section];
    }
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)]) {
        return [_SKSTableViewDelegate tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
    }
    
    return UITableViewAutomaticDimension;
}
//
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:estimatedHeightForHeaderInSection:)])
//        [_SKSTableViewDelegate tableView:tableView estimatedHeightForHeaderInSection:section];
//    
//    return 0;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:estimatedHeightForFooterInSection:)])
//        [_SKSTableViewDelegate tableView:tableView estimatedHeightForFooterInSection:section];
//    
//    return 0;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)])
//        [_SKSTableViewDelegate tableView:tableView viewForHeaderInSection:section];
//    
//    return nil;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:viewForFooterInSection:)])
//        [_SKSTableViewDelegate tableView:tableView viewForFooterInSection:section];
//    
//    return nil;
//}
//
//- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:shouldHighlightRowAtIndexPath:)])
//        [_SKSTableViewDelegate tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
//    
//    return NO;
//}
//
//- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:didHighlightRowAtIndexPath:)])
//        [_SKSTableViewDelegate tableView:tableView didHighlightRowAtIndexPath:indexPath];
//}
//
//- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:didUnhighlightRowAtIndexPath:)])
//        [_SKSTableViewDelegate tableView:tableView didUnhighlightRowAtIndexPath:indexPath];
//}
//
//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)])
//        [_SKSTableViewDelegate tableView:tableView willSelectRowAtIndexPath:indexPath];
//    
//    return nil;
//}
//
//- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)])
//        [_SKSTableViewDelegate tableView:tableView willDeselectRowAtIndexPath:indexPath];
//    
//    return nil;
//}
//
//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)])
//        [_SKSTableViewDelegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
//}
//
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:editingStyleForRowAtIndexPath:)])
//        [_SKSTableViewDelegate tableView:tableView editingStyleForRowAtIndexPath:indexPath];
//    
//    return UITableViewCellEditingStyleNone;
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)])
//        [_SKSTableViewDelegate tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
//    
//    return nil;
//}
//
//- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:shouldIndentWhileEditingRowAtIndexPath:)])
//        [_SKSTableViewDelegate tableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPath];
//    
//    return NO;
//}
//
//- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:willBeginEditingRowAtIndexPath:)])
//        [_SKSTableViewDelegate tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
//}
//
//- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:didEndEditingRowAtIndexPath:)])
//        [_SKSTableViewDelegate tableView:tableView didEndEditingRowAtIndexPath:indexPath];
//}
//
//- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)])
//        [_SKSTableViewDelegate tableView:tableView targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
//    
//    return nil;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:indentationLevelForRowAtIndexPath:)])
//        [_SKSTableViewDelegate tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
//    
//    return 0;
//}
//
//- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:shouldShowMenuForRowAtIndexPath:)])
//        [_SKSTableViewDelegate tableView:tableView shouldShowMenuForRowAtIndexPath:indexPath];
//    
//    return NO;
//}
//
//- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:canPerformAction:forRowAtIndexPath:withSender:)])
//        [_SKSTableViewDelegate tableView:tableView canPerformAction:action forRowAtIndexPath:indexPath withSender:sender];
//    
//    return NO;
//}
//
//- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
//{
//    if ([_SKSTableViewDelegate respondsToSelector:@selector(tableView:performAction:forRowAtIndexPath:withSender:)])
//        [_SKSTableViewDelegate tableView:tableView performAction:action forRowAtIndexPath:indexPath withSender:sender];
//}

#pragma mark - SKSTableViewUtils

- (NSInteger)numberOfExpandedSubrowsInSection:(NSInteger)section
{
    NSInteger totalExpandedSubrows = 0;
    
    NSArray *rows = self.expandableCells[@(section)];
    for (id row in rows)
    {
        if ([row[kIsExpandedKey] boolValue] == YES)
        {
            totalExpandedSubrows += [row[kSubrowsKey] integerValue];
        }
    }
    
    return totalExpandedSubrows;
}

- (NSInteger)numberOfExpandedSubSubrowsInSection:(NSInteger)section
{
    __block NSInteger totalExpandedSubSubrows = 0;

    [self.expandableSubCells enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        if ([key isKindOfClass:[NSArray class]]) {
            NSArray *keyArray = key;
            if ([keyArray[0] isEqual:@(section)]) {
                NSArray *subRows = obj;
                for (id subRow in subRows)
                {
                    if ([subRow[kIsExpandedKey] boolValue] == YES)
                    {
                        totalExpandedSubSubrows += [subRow[kSubSubrowsKey] integerValue];
                    }
                }
            }
        }
    }];
    
    
    return totalExpandedSubSubrows;
}

- (IBAction)expandableButtonTouched:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self];
    
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:currentTouchPosition];
    
    if (indexPath)
    {
        [self tableView:self accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}

- (void)expandButtonPressed:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self];
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        NSLog(@"row %ld", (long)indexPath.row);
        UITableViewCell *selectedCell = [self cellForRowAtIndexPath:indexPath];
        if ([selectedCell isKindOfClass:[SKSTableViewCellMulti class]])
        {
            SKSTableViewCellMulti *multiCell = (SKSTableViewCellMulti *)selectedCell;
            [self expandActionForTableViewCell:multiCell atIndexPath:indexPath];
        }
    }
}

- (void)expandActionForTableViewCell:(UITableViewCell<SKSTableViewCellProtocol> *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(isExpandable)])
    {
        if ([cell isExpandable])
        {
            BOOL isCurrentCellExpanded = cell.isExpanded;
            [cell setExpanded:!cell.isExpanded];
            
            NSIndexPath *_indexPath = indexPath;
            SKSIndexPath *correspondingIndexPath = [self correspondingIndexPathForRowAtIndexPath:indexPath];
            DebugLog(@"section(%ld) row(%ld) subRow(%ld) subSubRow(%ld)",
                     (long)correspondingIndexPath.section,
                     (long)correspondingIndexPath.row,
                     (long)correspondingIndexPath.subRow,
                     (long)correspondingIndexPath.subSubRow);
            
//            if ([cell isExpanded] &&
//                _shouldExpandOnlyOneCell)
//            {
//                _indexPath = correspondingIndexPath;
//                [self collapseCurrentlyExpandedIndexPaths];
//            }
            
            if (_indexPath)
            {
                NSInteger numberOfRows = 0;
                if (correspondingIndexPath.subRow == 0) {
                    numberOfRows = [self numberOfSubRowsAtSection:correspondingIndexPath.section
                                                            atRow:correspondingIndexPath.row];
                } else if (correspondingIndexPath.subRow != 0) {
                    numberOfRows = [self numberOfSubSubRowsAtSection:correspondingIndexPath.section
                                                               atRow:correspondingIndexPath.row
                                                            atSubRow:correspondingIndexPath.subRow];
                }
                
                NSMutableArray *expandedIndexPaths = [NSMutableArray array];
                NSInteger row = _indexPath.row;
                NSInteger section = _indexPath.section;
                
                NSInteger extraCounter = 0;
                for (NSInteger index = 1; index <= numberOfRows; index++)
                {
                    NSIndexPath *expIndexPath = [NSIndexPath indexPathForRow:row + index + extraCounter inSection:section];
                    UITableViewCell<SKSTableViewCellProtocol> *tempCell = (UITableViewCell<SKSTableViewCellProtocol> *)[self cellForRowAtIndexPath:expIndexPath];
                    if ([tempCell respondsToSelector:@selector(isExpandable)] &&
                        isCurrentCellExpanded &&
                        [tempCell respondsToSelector:@selector(isExpanded)] &&
                        tempCell.isExpanded)
                    {
//                        [self expandActionForTableViewCell:tempCell atIndexPath:expIndexPath];
                        [tempCell setExpanded:!tempCell.isExpanded];

                        NSArray *indexPaths = [self expandedIndexPathsForIndexPath:expIndexPath
                                                         andCorrespondingIndexPath:[self correspondingIndexPathForRowAtIndexPath:expIndexPath]];
                        extraCounter = extraCounter + [indexPaths count];
                        [expandedIndexPaths addObjectsFromArray:indexPaths];

                        if ([tempCell isExpanded])
                        {
                            [self setExpanded:YES forCellAtIndexPath:[self correspondingIndexPathForRowAtIndexPath:expIndexPath]];
                        }
                        else
                        {
                            [self setExpanded:NO forCellAtIndexPath:[self correspondingIndexPathForRowAtIndexPath:expIndexPath]];
                        }
                    }
                    

                    [expandedIndexPaths addObject:expIndexPath];
                }
                
                if ([cell isExpanded])
                {
                    [self setExpanded:YES forCellAtIndexPath:correspondingIndexPath];
                    [self insertRowsAtIndexPaths:expandedIndexPaths withRowAnimation:UITableViewRowAnimationTop];
                }
                else
                {
                    [self setExpanded:NO forCellAtIndexPath:correspondingIndexPath];
                    [self deleteRowsAtIndexPaths:expandedIndexPaths withRowAnimation:UITableViewRowAnimationTop];
                }
                
                [cell expandButtonAnimation];
            }
        }
    }
}

- (NSMutableArray *)expandedIndexPathsForIndexPath:(NSIndexPath *)_indexPath
                         andCorrespondingIndexPath:(SKSIndexPath *)correspondingIndexPath
{
    NSInteger numberOfRows = 0;
    if (correspondingIndexPath.subRow == 0) {
        numberOfRows = [self numberOfSubRowsAtSection:correspondingIndexPath.section
                                                atRow:correspondingIndexPath.row];
    } else if (correspondingIndexPath.subRow != 0) {
        numberOfRows = [self numberOfSubSubRowsAtSection:correspondingIndexPath.section
                                                   atRow:correspondingIndexPath.row
                                                atSubRow:correspondingIndexPath.subRow];
    }
    
    NSMutableArray *expandedIndexPaths = [NSMutableArray array];
    NSInteger row = _indexPath.row;
    NSInteger section = _indexPath.section;
    
    for (NSInteger index = 1; index <= numberOfRows; index++)
    {
        NSIndexPath *expIndexPath = [NSIndexPath indexPathForRow:row+index inSection:section];
//        UITableViewCell<SKSTableViewCellProtocol> *tempCell = (UITableViewCell<SKSTableViewCellProtocol> *)[self cellForRowAtIndexPath:expIndexPath];
//        if ([tempCell respondsToSelector:@selector(isExpandable)])
//        {
//            [self expandActionForTableViewCell:tempCell atIndexPath:expIndexPath];
//        }
        
        [expandedIndexPaths addObject:expIndexPath];
    }
    return expandedIndexPaths;
}

- (NSInteger)numberOfSubRowsAtSection:(NSInteger)section atRow:(NSInteger)row
{
    return [_SKSTableViewDelegate tableView:self
                   numberOfSubRowsAtSection:section
                                      atRow:row];
}

- (NSInteger)numberOfSubSubRowsAtSection:(NSInteger)section atRow:(NSInteger)row atSubRow:(NSInteger)subRow
{
    return [self.SKSTableViewDelegate tableView:self
                    numberOfSubSubRowsAtSection:section
                                          atRow:row
                                       atSubRow:subRow];;
}


- (SKSIndexPath *)correspondingIndexPathForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DebugLog(@"REAL %ld %ld", (long)indexPath.section, (long)indexPath.row);
    
    SKSIndexPath *correspondingIndexPath = nil;
    __block NSInteger finalSection = 0;
    __block NSInteger finalRow = 0;
    __block NSInteger finalSubRow = 0;
    __block NSInteger finalSubSubRow = 0;
    __block NSInteger countRows = 0;
    
    NSArray *rows = self.expandableCells[@(indexPath.section)];
    [rows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        __block NSInteger rowIndexCounter = idx;
        
        countRows++;
        
        if (countRows == (indexPath.row + 1)) {
            finalSection = indexPath.section;
            finalRow = rowIndexCounter;
            *stop = YES;
            return;
        }
        
        BOOL isExpanded = [obj[kIsExpandedKey] boolValue];
        NSInteger numberOfSubrows = 0;
        if (isExpanded) {
            numberOfSubrows = [obj[kSubrowsKey] integerValue];
        }
        
        if (!isExpanded) {
            return;
        }
        NSArray *subRows = self.expandableSubCells[@[@(indexPath.section), @(rowIndexCounter)]];
        if ([subRows count] > 0) {
            __block BOOL innerStop = NO;
            
            [subRows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                __block NSInteger subRowIndexCounter = idx + 1;
                
                countRows++;
                
                if (countRows == (indexPath.row + 1)) {
                    finalSection = indexPath.section;
                    finalRow = rowIndexCounter;
                    finalSubRow = subRowIndexCounter;
                    *stop = YES;
                    innerStop= YES;
                    return;
                }
                
                BOOL isExpanded = [obj[kIsExpandedKey] boolValue];
                NSInteger numberOfSubSubrows = 0;
                if (isExpanded) {
                    numberOfSubSubrows = [obj[kSubSubrowsKey] integerValue];
                }
                if (!isExpanded) {
                    return;
                }
                for (int i = 0; i < numberOfSubSubrows; i++) {
                    NSInteger subSubRowIndexCounter = i + 1;
                    countRows++;
                    if (countRows == (indexPath.row + 1)) {
                        finalSection = indexPath.section;
                        finalRow = rowIndexCounter;
                        finalSubRow = subRowIndexCounter;
                        finalSubSubRow = subSubRowIndexCounter;
                        *stop = YES;
                        innerStop= YES;
                        return;
                    }
                }
            }];
            if (innerStop) {
                *stop = YES;
            }
        }
    }];
    
    correspondingIndexPath = [NSIndexPath indexPathForSubSubRow:finalSubSubRow
                                                       atSubRow:finalSubRow
                                                          inRow:finalRow
                                                      inSection:finalSection];
    if (correspondingIndexPath == nil) {
        DebugLog(@"SEVERE");
    } else {
        DebugLog(@"section(%ld) row(%ld) subRow(%ld) subSubRow(%ld)",
                 (long)correspondingIndexPath.section,
                 (long)correspondingIndexPath.row,
                 (long)correspondingIndexPath.subRow,
                 (long)correspondingIndexPath.subSubRow);
    }
    return correspondingIndexPath;
}

- (NSIndexPath *)indexPathFromFetchedResultsIndexPath:(NSIndexPath *)indexPath {
    __block NSIndexPath *correspondingIndexPath = nil;
    __block NSInteger expandedSubrows = 0;
    
    NSArray *rows = self.expandableCells[@(indexPath.section)];
    [rows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        BOOL isExpanded = [obj[kIsExpandedKey] boolValue];
        NSInteger numberOfSubrows = 0;
        NSInteger currentRow = idx + expandedSubrows;

        if (isExpanded)
        {
            numberOfSubrows = [obj[kSubrowsKey] integerValue];
        }
        
//        NSInteger subrow = indexPath.row - expandedSubrows - idx;
        
        if (idx == indexPath.row) {
            correspondingIndexPath = [NSIndexPath indexPathForRow:currentRow inSection:indexPath.section];
            *stop = YES;
        }
        
        expandedSubrows += numberOfSubrows;

        
//        if (subrow > numberOfSubrows)
//        {
//            expandedSubrows += numberOfSubrows;
//        }
//        else
//        {
//            correspondingIndexPath = [NSIndexPath indexPathForSubRow:subrow
//                                                               inRow:idx
//                                                           inSection:indexPath.section];
//            
//            *stop = YES;
//        }
    }];
    
    return correspondingIndexPath;
}

- (void)setExpanded:(BOOL)isExpanded forCellAtIndexPath:(SKSIndexPath *)indexPath
{
    DebugLog(@"section(%ld) row(%ld) subRow(%ld) subSubRow(%ld)",
             (long)indexPath.section,
             (long)indexPath.row,
             (long)indexPath.subRow,
             (long)indexPath.subSubRow);
    
    if (indexPath.subRow == 0) {
        NSMutableDictionary *cellInfo = self.expandableCells[@(indexPath.section)][indexPath.row];
        [cellInfo setObject:@(isExpanded) forKey:kIsExpandedKey];
    } else if (indexPath.subRow != 0) {
        NSArray *subRows = self.expandableSubCells[@[@(indexPath.section), @(indexPath.row)]];
        NSInteger digit = indexPath.subRow - 1;
        NSMutableDictionary *cellInfo = subRows[digit];
        [cellInfo setObject:@(isExpanded) forKey:kIsExpandedKey];
    }
    

}

- (void)collapseCurrentlyExpandedIndexPaths
{
    NSMutableArray *totalExpandedIndexPaths = [NSMutableArray array];
    NSMutableArray *totalExpandableIndexPaths = [NSMutableArray array];

    [self.expandableCells enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        [_expandableCells setObject:rows forKey:@(section)];

        __block NSInteger totalExpandedSubrows = 0;
        
        [obj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            NSMutableDictionary *rowInfo = [NSMutableDictionary dictionaryWithObjects:@[@(isExpandedInitially), @(numberOfSubrows)]
//                                                                              forKeys:@[kIsExpandedKey, kSubrowsKey]];
//            [rows addObject:rowInfo];

            NSInteger currentRow = idx + totalExpandedSubrows;
            
            BOOL isExpanded = [obj[kIsExpandedKey] boolValue];
            if (isExpanded)
            {
                NSInteger expandedSubrows = [obj[kSubrowsKey] integerValue];
                for (NSInteger index = 1; index <= expandedSubrows; index++)
                {
                    NSIndexPath *expandedIndexPath = [NSIndexPath indexPathForRow:currentRow + index
                                                                        inSection:[key integerValue]];
                    [totalExpandedIndexPaths addObject:expandedIndexPath];
                }
                
                [obj setObject:@(NO) forKey:kIsExpandedKey];
                totalExpandedSubrows += expandedSubrows;
                
                [totalExpandableIndexPaths addObject:[NSIndexPath indexPathForRow:currentRow inSection:[key integerValue]]];
            }
        }];
    }];
    
    for (NSIndexPath *indexPath in totalExpandableIndexPaths)
    {
        SKSTableViewCell *cell = (SKSTableViewCell *)[self cellForRowAtIndexPath:indexPath];
        cell.expanded = NO;
        [cell expandButtonAnimation];
    }
    
    [self deleteRowsAtIndexPaths:totalExpandedIndexPaths withRowAnimation:UITableViewRowAnimationTop];
}

- (NSArray<NSIndexPath *> *)subRowIndexPathsForParentIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *totalExpandedIndexPaths = [NSMutableArray array];
//    NSMutableArray *totalExpandableIndexPaths = [NSMutableArray array];
    
    [self.expandableCells enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        __block NSInteger totalExpandedSubrows = 0;
        
        [obj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSInteger currentRow = idx + totalExpandedSubrows;
            
            BOOL isExpanded = [obj[kIsExpandedKey] boolValue];
            if (isExpanded)
            {
                
                NSInteger expandedSubrows = [obj[kSubrowsKey] integerValue];
                if (currentRow == indexPath.row) {
                    for (NSInteger index = 1; index <= expandedSubrows; index++)
                    {
                        NSIndexPath *expandedIndexPath = [NSIndexPath indexPathForRow:currentRow + index
                                                                            inSection:[key integerValue]];
                        [totalExpandedIndexPaths addObject:expandedIndexPath];
                    }
                    *stop = YES;
                }
                

                
//                [obj setObject:@(NO) forKey:kIsExpandedKey];
                totalExpandedSubrows += expandedSubrows;
                
//                [totalExpandableIndexPaths addObject:[NSIndexPath indexPathForRow:currentRow inSection:[key integerValue]]];
            }
        }];
    }];
    
//    for (NSIndexPath *indexPath in totalExpandableIndexPaths)
//    {
//        SKSTableViewCell *cell = (SKSTableViewCell *)[self cellForRowAtIndexPath:indexPath];
//        cell.expanded = NO;
//        [cell expandButtonAnimation];
//    }
    
//    [self deleteRowsAtIndexPaths:totalExpandedIndexPaths withRowAnimation:UITableViewRowAnimationTop];
    return totalExpandedIndexPaths;
}


@end

#pragma mark - NSIndexPath (SKSTableView)

@implementation NSIndexPath (SKSTableView)

+ (SKSIndexPath *)indexPathForSubSubRow:(NSInteger)subSubrow atSubRow:(NSInteger)subrow inRow:(NSInteger)row inSection:(NSInteger)section
{
    SKSIndexPath *indexPath = [SKSIndexPath new];
    indexPath.section = section;
    indexPath.row = row;
    indexPath.subRow = subrow;
    indexPath.subSubRow = subSubrow;
    indexPath.indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    return indexPath;
}

@end

