//
//  ViewController.m
//  SectionedSegmentedControl
//
//  Created by Mike Keller on 1/19/16.
//  Copyright © 2016 Meek Apps. All rights reserved.
//

#import "ViewController.h"
#import "SectionedSegmentedControl.h"

@interface ViewController ()
@property (strong, nonatomic) SectionedSegmentedControl *codeSectionedSegmentedControl;
@property (strong, nonatomic) UISegmentedControl *regularSegmentedControl;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  
  self.codeSectionedSegmentedControl = [[SectionedSegmentedControl alloc] initWithFrame:CGRectMake(10.0F, 100.0F, self.view.bounds.size.width - 20.0F, 34.0F)
                                                                       titlesForSection:@[@"1", @"2", @"3"], @[@"A"], @[@"hi", @"bye"], nil];
  self.codeSectionedSegmentedControl.tintColor = [UIColor redColor];
  [self.view addSubview:self.codeSectionedSegmentedControl];
  [self.codeSectionedSegmentedControl addTarget:self action:@selector(changedSectionedSegment:) forControlEvents:UIControlEventValueChanged];
  
  SectionedSegmentedControlSelection *selection = [SectionedSegmentedControlSelection selectionWithSection:2
                                                                                                   segment:0];
  [self.codeSectionedSegmentedControl setCurrentSelection:selection];
}

- (void) changedSectionedSegment:(SectionedSegmentedControl*)sectionedSegmentedControl {
  //TODO: need a way to get the segment and the section now.
  NSLog(@"changed value: %@", sectionedSegmentedControl.currentSelection);
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
