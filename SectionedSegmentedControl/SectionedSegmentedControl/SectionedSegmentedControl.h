//
//  SectionedSegmentedControl.h
//  SectionedSegmentedControl
//
//  Created by Mike Keller on 1/19/16.
//  Copyright © 2016 Meek Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - SectionedSegmentedControlSelection

static NSInteger const kSectionedSegmentedControlSelectionNone = -1;

@interface SectionedSegmentedControlSelection : NSObject
@property (nonatomic) NSInteger section, segment;

/// Designated initializer.
- (instancetype) initWithSection:(NSInteger)section
                           segment:(NSInteger)segment;

/// Convenience initializer.
+ (SectionedSegmentedControlSelection*) selectionWithSection:(NSInteger)section
                                                     segment:(NSInteger)segment;
@end

#pragma mark - SectionedSegmentedControl

@interface SectionedSegmentedControl : UIControl

@property (readonly, nonatomic) NSUInteger numberOfSections;
@property (strong, nonatomic) SectionedSegmentedControlSelection *currentSelection;

/// Initialize a SectionedSegmentControl with the number of var_args sections with sectionTitles per section.
- (instancetype) initWithFrame:(CGRect)frame
              titlesForSection:(NSArray*)sectionTitles, ... NS_REQUIRES_NIL_TERMINATION;

/// Clears current selection.
- (void) clearSelection;

/// Returns the number of segments at section.
- (NSUInteger) numberOfSegmentsAtSection:(NSUInteger)section;

/// Returns the NSString title at this sections's index.
- (NSString*) titleAtSection:(NSUInteger)section
                     segment:(NSUInteger)segment;

/// Returns an array of titles for section.
- (NSArray*) titlesForSection:(NSUInteger)section;

@end
