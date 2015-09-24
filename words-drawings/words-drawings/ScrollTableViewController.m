//
//  ScrollTableViewController.m
//  words-drawings
//
//  Created by Matthew McClure on 9/11/15.
//  Copyright © 2015 Matthew McClure. All rights reserved.
//

#import "ScrollTableViewController.h"
#import "DrawingTableViewCell.h"
#import "WordsTableViewCell.h"
#import "PassItOnViewController.h"
#import "PassViewController.h"
#import "JotViewController.h"

@interface ScrollTableViewController () <JotViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic) NSInteger numberOfRows;
//@property (strong, nonatomic) NSString *seedPrompt;
@property (strong, nonatomic) NSString *currentPrompt;
@property (strong, nonatomic) NSMutableArray *promptArray;
@property (strong, nonatomic) NSMutableArray *drawingArray;
@property (strong, nonatomic) IBOutlet UITableView *scrollTableView;
@property (strong, nonatomic) DrawingTableViewCell *currentDrawingCell;
@property (strong, nonatomic) WordsTableViewCell *currentWordsCell;
@property (nonatomic, strong) JotViewController *jotVC;
@property int counter;


@end

@implementation ScrollTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

  self.scrollTableView.allowsSelection = NO;
  self.currentWordsCell.textField.delegate = self;
  NSLog(@"SEED PROMPT: %@", _seedPrompt);
  
  _promptArray = [[NSMutableArray alloc] init];
  [_promptArray addObject: _seedPrompt];
  
  _drawingArray = [[NSMutableArray alloc] init];
  
  self.counter = 0;
  NSLog(@"counter starts at %d", _counter);
  
  self.numberOfRows = self.numberOfPlayers;

  UINib *wordsCell = [UINib nibWithNibName:@"wordsCell" bundle:nil];
  [self.scrollTableView registerNib:wordsCell forCellReuseIdentifier:@"wordsCell"];
  
  UINib *drawingCell = [UINib nibWithNibName:@"drawingCell" bundle:nil];
  [self.scrollTableView registerNib:drawingCell forCellReuseIdentifier:@"drawingCell"];
  
  [[NSNotificationCenter defaultCenter] addObserverForName:@"doneDrawingNotification" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
    UIImage *drawnImage = [self.jotVC renderImageWithScale:2.f
                                                               onColor:self.view.backgroundColor];
    
    [_drawingArray addObject:drawnImage];

    [self.jotVC clearAll];

    [self showNextCell];
//    _counter++;
    PassViewController *passView = [[PassViewController alloc] initWithNibName:@"PassViewController" bundle:[NSBundle mainBundle]];
    [_navController pushViewController:passView animated:YES];
  }];
  
  //press the GO button on the pass vc
  [[NSNotificationCenter defaultCenter] addObserverForName:@"popButtonPressed" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
    [_navController popViewControllerAnimated:YES];
  }];
  
  [[NSNotificationCenter defaultCenter] addObserverForName:@"doneGuessingNotification" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
    [self showNextCell];
    NSString *enteredString;
    enteredString = self.currentWordsCell.textField.text;
    [self.promptArray addObject:enteredString];
    
    for (NSString *string in _promptArray){
      NSLog(@"IN PROMPT ARRAY: %@", string);
    }
//
    PassViewController *passView = [[PassViewController alloc] initWithNibName:@"PassViewController" bundle:[NSBundle mainBundle]];
    [_navController pushViewController:passView animated:YES];
  }];
}

- (void)showNextCell {
  self.counter++;
  NSLog(@"UMM %d", self.counter);
//  NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_counter inSection:0];
//  [self.scrollTableView scrollToRowAtIndexPath:indexPath
//                              atScrollPosition:UITableViewScrollPositionMiddle
//                                      animated:NO];
  
  if (_counter < _numberOfRows) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_counter inSection:0];
    [self.scrollTableView scrollToRowAtIndexPath:indexPath
                                atScrollPosition:UITableViewScrollPositionMiddle
                                        animated:NO];

  } else {
    [self performSegueWithIdentifier:@"ShowEndOfGame" sender:self];
  }
}


//-(void)viewDidAppear:(BOOL)animated {
//  [super viewDidAppear:animated];
//  if (self.currentWordsCell) {
//    NSString *enteredString;
//    enteredString = self.currentWordsCell.textField.text;
//    [self.promptArray addObject:enteredString];
//  }
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row % 2 == 0) {
    DrawingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"drawingCell" forIndexPath:indexPath];
    self.jotVC = [[JotViewController alloc] init];
    self.jotVC.delegate = self;
    self.jotVC.state = JotViewStateDrawing;
    [self addChildViewController:self.jotVC];
    [cell.contentView addSubview:self.jotVC.view];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    self.currentDrawingCell = cell;
    int counterMinusOne = (_counter - 1);
    if (indexPath.row == 0) {
      cell.promptLabel.text = self.promptArray[0];
    } else {
      cell.promptLabel.text = self.promptArray[counterMinusOne];
    }
    
    [self.jotVC didMoveToParentViewController:self];
    self.jotVC.view.frame = cell.drawingView.frame;
//    cell.promptLabel.text = _seedPrompt;
    cell.timerLabel.text = [NSString stringWithFormat:@"%ld",(long)_durationOfRound];
    return cell;
  } else {
    WordsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"wordsCell" forIndexPath:indexPath];
    self.currentWordsCell = cell;
    cell.imageView.image = [_drawingArray objectAtIndex:indexPath.row-1];

    return cell;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//  [self.scrollTableView scrollToRowAtIndexPath:indexPath atScrollPosition: UITableViewScrollPositionMiddle animated: YES];
  CGFloat cellHeight = tableView.frame.size.height;
  return cellHeight;
}


@end
