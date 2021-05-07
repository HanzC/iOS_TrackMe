//
//  TableViewController.h
//  TrackMe
//
//  Created by Hanz Meyer on 4/22/21.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface TableViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *tableViewCell;
@property (strong, nonatomic) IBOutlet UILabel *dateLbl;
@property (strong, nonatomic) IBOutlet UILabel *pointsLbl;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end

