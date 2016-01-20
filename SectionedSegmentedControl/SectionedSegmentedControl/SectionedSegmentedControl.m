//
//  SectionedSegmentedControl.m
//  SectionedSegmentedControl
//
//  Created by Mike Keller on 1/19/16.
//  Copyright © 2016 Meek Apps. All rights reserved.
//

#import "SectionedSegmentedControl.h"

#pragma mark - SectionedSegmentedControlSelection

@implementation SectionedSegmentedControlSelection

- (instancetype) initWithSection:(NSInteger)section
                           segment:(NSInteger)segment {
  self = [super init];
  if (self) {
    self.section = section;
    self.segment = segment;
  }
  return self;
}

+ (SectionedSegmentedControlSelection*) selectionWithSection:(NSInteger)section
                                                       segment:(NSInteger)segment {
  SectionedSegmentedControlSelection *instance = [[SectionedSegmentedControlSelection alloc] initWithSection:section
                                                                                                     segment:segment];
  return instance;
}

//"<SectionedSegmentedControlSelection: 0x7f9dc2e9a450> (0, 0)"
- (NSString*) description {
  id section = self.section == kSectionedSegmentedControlSelectionNone ? @"kSectionedSegmentedControlSelectionNone" : @(self.section);
  id segment = self.segment == kSectionedSegmentedControlSelectionNone ? @"kSectionedSegmentedControlSelectionNone" : @(self.segment);
  
  return [NSString stringWithFormat:@"<%@: %p>: (%@, %@)",
          NSStringFromClass([self class]),
          self,
          section,
          segment];
}

@end

#pragma mark - SectionedSegmentedControl

static CGFloat kDefaultSectionPadding = 10.0F;

@interface SectionedSegmentedControl()
@property (readwrite, nonatomic) NSUInteger numberOfSections;
@property (copy, nonatomic) NSArray *allSectionTitles; //Array of arrays of sectionTitles.
@property (strong, nonatomic) NSArray *segmentedControls; //Array of underlying UISegmentedControl subviews.
@end

@implementation SectionedSegmentedControl

@synthesize currentSelection = _currentSelection;

- (instancetype) initWithFrame:(CGRect)frame
              titlesForSection:(NSArray*)sectionTitles, ... {
  self = [super initWithFrame:frame];
  if (self) {
    //Setup data from var_args
    NSMutableArray *allSectionTitlesMutable = [NSMutableArray array];
    va_list args;
    va_start(args, sectionTitles);
    [allSectionTitlesMutable addObject:sectionTitles];
    id obj;
    while ((obj = va_arg(args, id)) != nil) {
      [allSectionTitlesMutable addObject:obj];
    }
    va_end(args);
    
    self.allSectionTitles = [allSectionTitlesMutable copy];
    self.numberOfSections = [self.allSectionTitles count];
    
    [self createSubviews];
    [self clearSelection];
  }
  return self;
}

- (NSUInteger) numberOfSegmentsAtSection:(NSUInteger)section {
  if (self.allSectionTitles.count <= section) return 0;
  
  NSArray *titles = self.allSectionTitles[section];
  return titles.count;
}

- (NSString*) titleAtSection:(NSUInteger)section
                     segment:(NSUInteger)segment {
  if (self.allSectionTitles.count <= section) return nil;
  
  NSArray *titles = self.allSectionTitles[section];
  
  if (titles.count <= segment) return nil;
  
  return titles[segment];
}

- (NSArray*) titlesForSection:(NSUInteger)section {
  if (self.allSectionTitles.count <= section) return nil;
  
  return self.allSectionTitles[section];
}

//Instantiates all necessary UISegmentedControl subviews with correct Autolayout constraints.
- (void) createSubviews {
  NSMutableArray *mutableSegmentedControls = [NSMutableArray arrayWithCapacity:self.numberOfSections];
  UISegmentedControl *previousSegmentedControl = nil;
  
  //Enumerate the sections, inititalize the UISegmentedControls, add to array, and add subviews
  for (NSUInteger section = 0; section < self.numberOfSections; section++) {
    NSArray *titlesAtSection = [self titlesForSection:section];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:titlesAtSection];
    segmentedControl.tag = section; //tag this segmented control with its section for convenient lookup.
    [segmentedControl addTarget:self action:@selector(selectedSegment:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    [mutableSegmentedControls addObject:segmentedControl];
    
    [self addSubview:segmentedControl];
    
    //Contrain segmented control to top and bottom of superview.
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[segmentedControl]-0-|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:@{@"segmentedControl" : segmentedControl}];
    [self addConstraints:verticalConstraints];
    
    //First segmented control, add leading constraint to superview.
    if (section == 0) {
      NSArray *leadingContraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[segmentedControl]"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:@{@"segmentedControl" : segmentedControl}];
      [self addConstraints:leadingContraints];
    }
    
    //Segmented control is somewhere in the middle, add leading constraint to previously added segmented control.
    if (section > 0 && self.numberOfSections > 0) {
      
      NSString *format = [NSString stringWithFormat:@"H:[previousSegmentedControl]-%@-[segmentedControl]", @(kDefaultSectionPadding)];
      NSArray *segmentToSegmentConstraints = [NSLayoutConstraint constraintsWithVisualFormat:format
                                                                                     options:0
                                                                                     metrics:nil
                                                                                       views:@{@"previousSegmentedControl" : previousSegmentedControl,
                                                                                               @"segmentedControl" : segmentedControl}];
      [self addConstraints:segmentToSegmentConstraints];
    }
    
    //Last segmented control, add trailing constraint to superview.
    if (section == self.numberOfSections - 1) {
      
      NSArray *trailingConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[segmentedControl]-0-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"segmentedControl" : segmentedControl}];
      [self addConstraints:trailingConstraints];
    }
    
    previousSegmentedControl = segmentedControl;
  }
  
  self.segmentedControls = [mutableSegmentedControls copy];
}

//Clear all segmented control subviews of their selection.
- (void) clearSelection {
  self.currentSelection.section = kSectionedSegmentedControlSelectionNone;
  self.currentSelection.segment = kSectionedSegmentedControlSelectionNone;
  for (UISegmentedControl *segmentedControl in self.segmentedControls) {
    segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
  }
}

- (SectionedSegmentedControlSelection*) currentSelection {
  if (!_currentSelection) {
    _currentSelection = [SectionedSegmentedControlSelection selectionWithSection:kSectionedSegmentedControlSelectionNone
                                                                         segment:kSectionedSegmentedControlSelectionNone];
  }
  return _currentSelection;
}

- (void) setCurrentSelection:(SectionedSegmentedControlSelection *)currentSelection {
  if (!currentSelection) return;
  if (currentSelection.section == kSectionedSegmentedControlSelectionNone && currentSelection.segment == kSectionedSegmentedControlSelectionNone) {
    [self clearSelection];
    return;
  }
  if (currentSelection.section > self.numberOfSections) return;
  if (currentSelection.segment > [self numberOfSegmentsAtSection:currentSelection.section]) return;
  
  _currentSelection = currentSelection;
  
  for (NSUInteger i = 0; i < self.numberOfSections; i++) {
    UISegmentedControl *segmentedControl = self.segmentedControls[i];
    //Found segmented control, set selected index.
    if (currentSelection.section == i) {
      segmentedControl.selectedSegmentIndex = currentSelection.segment;
      
    //Selecting other segment, clear selection of this segmented control.
    } else {
      segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    }
  }
  
}

#pragma mark - Actions

- (void) selectedSegment:(UISegmentedControl*)sender {
  NSInteger section = sender.tag;
  NSInteger segment = sender.selectedSegmentIndex;
  
  self.currentSelection.section = section;
  self.currentSelection.segment = segment;
  
  //Deselect all other segmented controls
  for (NSUInteger i = 0; i < self.numberOfSections; i++) {
    if (i != section) {
      UISegmentedControl *segmentedControl = self.segmentedControls[i];
      segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    }
  }
  
  [self sendActionsForControlEvents:UIControlEventValueChanged];
}


@end
