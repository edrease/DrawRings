//
//  DrawingTableViewCell.h
//  words-drawings
//
//  Created by Matthew McClure on 9/21/15.
//  Copyright © 2015 Matthew McClure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScrollTableViewController;

@interface DrawingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@end
