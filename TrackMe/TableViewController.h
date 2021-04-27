//
//  TableViewController.h
//  TrackMe
//
//  Created by Hanz Meyer on 4/22/21.
//

#import <UIKit/UIKit.h>


@interface TableViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *tableViewCell;
@property (strong, nonatomic) IBOutlet UILabel *dateLbl;
@property (strong, nonatomic) IBOutlet UILabel *pointsLbl;

@end

