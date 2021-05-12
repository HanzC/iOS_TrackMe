//
//  TableViewController.m
//  TrackMe
//
//  Created by Hanz Meyer on 4/22/21.
//

#import "TableViewController.h"
#import "GLManager.h"
#import "Location+CoreDataClass.h"
#import <QuartzCore/QuartzCore.h>

@interface TableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *popUpView;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (strong) NSMutableArray *dataArray;
@property (nonatomic, retain) MKPolyline *polyLine;

@end

@implementation TableViewController

MKPointAnnotation *annotPoint;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"newCell"];

    self.popUpView.layer.cornerRadius = 5;
    self.popUpView.layer.shadowOpacity = 0.8;
    self.popUpView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    //self.popUpView.alpha = 0;
    self.mapView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Location"];
    NSFetchRequest *fetchRequestTime = [[NSFetchRequest alloc] initWithEntityName:@"TimeLocation"];
//    self.dataArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    self.dataArray = [[managedObjectContext executeFetchRequest:fetchRequestTime error:nil] mutableCopy];
    
    
    // Execute Fetch Request For Location
    NSMutableArray *tmpArrayLoc = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSManagedObject *arrayObjLoc;
    for (int x = 0; x < [tmpArrayLoc count]; x++)
    {
        arrayObjLoc = [tmpArrayLoc objectAtIndex:x];
//        NSLog(@" *** TimeStamp:      %@", [arrayObjLoc valueForKey:@"timestamp"]);
//        NSLog(@" *** TimeLoc Lat:    %@", [arrayObjLoc valueForKey:@"latitude"]);
//        NSLog(@" *** TimeLoc Long:   %@", [arrayObjLoc valueForKey:@"longitude"]);
//        NSLog(@"**\n\n");
    }
//    NSLog(@"----\n\n\n---");
    
    
    // Execute Fetch Request For Time Location
    NSMutableArray *tmpArray = [[managedObjectContext executeFetchRequest:fetchRequestTime error:nil] mutableCopy];
    NSLog(@" *** TVC > TmpArray:    %@", tmpArray);

    NSManagedObject *arrayObj;
    for (int x = 0; x < [tmpArray count]; x++)
    {
        arrayObj = [tmpArray objectAtIndex:x];
//        NSLog(@" *** TVC > TimeStamp: %@", [arrayObj valueForKey:@"timestamp"]);
        //NSLog(@" *** TVC > TimeLoc Lat:   %@", [[arrayObj valueForKey:@"time_location"] valueForKey:@"latitude"]);
        //NSLog(@" *** TVC > TimeLoc Long:  %@", [[arrayObj valueForKey:@"time_location"] valueForKey:@"longitude"]);
//        NSLog(@"**\n\n");
    }
    
    [self.tableView reloadData];
}


#pragma mark - MapView Delegates
- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation
{
    
}

- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
//    id<MKAnnotation> mp = [annotationView point];
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate] ,250,250);
//    [mv setRegion:region animated:YES];
    
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    MKMapRect rect = [self.mapView visibleMapRect];
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.mapView setVisibleMapRect:rect edgePadding:insets animated:YES];
}


- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
    
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated;
{
    
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.alpha = 0.75;
    renderer.lineWidth = 1.0;

    return renderer;
}


#pragma mark - Core Data
- (NSManagedObjectContext *)managedObjectContext
{
    if ([GLManager sharedManager].managedObjectContext != nil)
    {
        return [GLManager sharedManager].managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        //managedObjectContext = [[NSManagedObjectContext alloc] init]; // Deprecated //
        [GLManager sharedManager].managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [[GLManager sharedManager].managedObjectContext setPersistentStoreCoordinator: coordinator];
    }

    return [GLManager sharedManager].managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if ([GLManager sharedManager].managedObjectModel != nil)
    {
        return [GLManager sharedManager].managedObjectModel;
    }
    [GLManager sharedManager].managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return [GLManager sharedManager].managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
 {

    if ([GLManager sharedManager].persistentStoreCoordinator != nil)
    {
        return [GLManager sharedManager].persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Location.sqlite"]];
    NSError *error = nil;
     [GLManager sharedManager].persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        if(![[GLManager sharedManager].persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error])
        {
            /*Error for store creation should be handled in here*/
        }

    return [GLManager sharedManager].persistentStoreCoordinator;
}
- (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark - Pop Up Window
- (void)showAnimate
{
    self.popUpView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.popUpView.alpha = 0;
    [UIView animateWithDuration:.25 animations:^{
        self.popUpView.alpha = 1;
        self.popUpView.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)removeAnimate
{
    [UIView animateWithDuration:.25 animations:^{
        self.popUpView.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.popUpView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            //[self.popUpView removeFromSuperview];
        }
    }];
}

- (IBAction)showPopup:(id)sender
{
    [self showAnimate];
}

- (IBAction)closePopup:(id)sender
{
    [self removeAnimate];
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    [aView addSubview:self.view];
    if (animated) {
        [self showAnimate];
    }
}


#pragma mark - TableView Delegates
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"newCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSManagedObject *device = [self.dataArray objectAtIndex:indexPath.row];
    
    // Convert to Date Format
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *formattedDate = [dateFormatter dateFromString:[device valueForKey:@"timestamp"]];
    //NSLog(@" *** TableViewController > cellForRowAtIndexPath:  %@", formattedDate);
    
    // Convert to String Date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    //NSLog(@" *** %@", [formatter stringFromDate:formattedDate]);
    //NSLog(@"\n\n");
    
    
    // Initialize TimeStamp Label
    UILabel *lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, _tableView.frame.size.width/2 + 25, 35)];
    lblTemp.font =  [UIFont fontWithName:@"Arial-BoldMT" size:15];
    lblTemp.backgroundColor = [UIColor yellowColor];
    lblTemp.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:formattedDate]]; //[NSString stringWithFormat:@"%@", [device valueForKey:@"timestamp"]];
    lblTemp.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:lblTemp];
    

    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Create fetch request For Location
    NSEntityDescription *productEntityLoc = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchLoc = [[NSFetchRequest alloc] init];
    [fetchLoc setEntity:productEntityLoc];
    NSPredicate *pLoc = [NSPredicate predicateWithFormat:@"timestamp == %@", [[_dataArray objectAtIndex:indexPath.row] valueForKey:@"timestamp"]];
    [fetchLoc setPredicate:pLoc];
    
    NSError *fetchErrorLoc;
    NSArray *fetchedProductsLoc = [self.managedObjectContext executeFetchRequest:fetchLoc error:&fetchErrorLoc];
    // handle error

    // Remove overlays
    for (id<MKOverlay> overlayToRemove in self.mapView.overlays)
    {
       if ([overlayToRemove isKindOfClass:[MKPolyline class]])
           [self.mapView removeOverlay:overlayToRemove];
    }
    __block NSString *firstLocLat;
    __block NSString *firstLocLong;
    
    NSLog(@"*** Start ***");
    [UIView animateWithDuration:0.25 animations:^{
            //self.view.alpha = self.view.alpha==1?0:1;
        NSLog(@"*** IN Progress ***");
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        MKCoordinateRegion defaultRegion = MKCoordinateRegionMake(self.mapView.centerCoordinate, MKCoordinateSpanMake(50, 50)); //180, 360
        [self.mapView setRegion:defaultRegion animated:YES];
        
    }completion:^(BOOL finished)
    {
        NSLog(@"*** Finish ***");
        
        for (NSManagedObject *product in fetchedProductsLoc)
        {
            NSLog(@" *** Fetched Loc Time:   %@", [product valueForKey:@"timestamp"]);
            NSLog(@" *** Fetched Loc Lat:    %@", [product valueForKey:@"latitude"]);
            NSLog(@" *** Fetched Loc Long:   %@", [product valueForKey:@"longitude"]);
            NSLog(@"*\n\n\n*");
            
            annotPoint = [[MKPointAnnotation alloc] init];
            
            NSString *latString = [product valueForKey:@"latitude"];
            NSString *longString = [product valueForKey:@"longitude"];
            CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake( [latString doubleValue], [longString doubleValue]);
            
            // Add Annotation
            annotPoint.coordinate = coordinates;
            //annotPoint.title = @"Here";
            //point.subtitle = @"I'm here!!!";
            [self.mapView addAnnotation:annotPoint];
            
            // Add Overlay
//            CLLocation *location = [GLManager sharedManager].lastLocation;
//            latString = [NSString stringWithFormat:@"%.06f", location.coordinate.latitude];
//            longString = [NSString stringWithFormat:@"%.06f", location.coordinate.longitude];
            
            CLLocationCoordinate2D location[2];
            if (location[0].latitude == 0)
                location[0] = CLLocationCoordinate2DMake([latString doubleValue], [longString doubleValue]);
            else
                location[0] = CLLocationCoordinate2DMake([firstLocLat doubleValue], [firstLocLong doubleValue]);
            location[1] = CLLocationCoordinate2DMake([latString doubleValue], [longString doubleValue]);
            
            self.polyLine = [MKPolyline polylineWithCoordinates:location count:2];
            [self.mapView setVisibleMapRect:[self.polyLine boundingMapRect]];
            [self.mapView addOverlay:self.polyLine];
            
            firstLocLat = [NSString stringWithFormat:@"%.06f", [latString doubleValue]];
            firstLocLong = [NSString stringWithFormat:@"%.06f", [longString doubleValue]];
        }
    }];
 
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self performSegueWithIdentifier:@"detailsView" sender:self];
    //[self showAnimate];
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
     if (editingStyle == UITableViewCellEditingStyleDelete)
     {
         // Create fetch request For Location
         NSEntityDescription *productEntityLoc = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
         NSFetchRequest *fetchLoc = [[NSFetchRequest alloc] init];
         [fetchLoc setEntity:productEntityLoc];
         NSPredicate *pLoc = [NSPredicate predicateWithFormat:@"timestamp == %@", [[_dataArray objectAtIndex:indexPath.row] valueForKey:@"timestamp"]];
         [fetchLoc setPredicate:pLoc];
         
         NSError *fetchErrorLoc;
         NSArray *fetchedProductsLoc = [self.managedObjectContext executeFetchRequest:fetchLoc error:&fetchErrorLoc];
         // handle error

         for (NSManagedObject *product in fetchedProductsLoc)
         {
             NSLog(@" *** Fetched Loc Product: %@", [product valueForKey:@"timestamp"]);
             [self.managedObjectContext deleteObject:product];
         }
         [self.managedObjectContext save:&fetchErrorLoc];
         
         NSLog(@"*\n\n\n*");
         
         // Create fetch request for Time Location
         NSEntityDescription *productEntity = [NSEntityDescription entityForName:@"TimeLocation" inManagedObjectContext:self.managedObjectContext];
         NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
         [fetch setEntity:productEntity];
         NSPredicate *p = [NSPredicate predicateWithFormat:@"timestamp == %@", [[_dataArray objectAtIndex:indexPath.row] valueForKey:@"timestamp"]];
         [fetch setPredicate:p];
         
         NSError *fetchError;
         NSArray *fetchedProducts = [self.managedObjectContext executeFetchRequest:fetch error:&fetchError];
         // handle error

         for (NSManagedObject *product in fetchedProducts)
         {
             NSLog(@" *** Fetched Time Product: %@", product);
             [self.managedObjectContext deleteObject:product];
         }
         [self.managedObjectContext save:&fetchError];
         
         [_dataArray removeObjectAtIndex:indexPath.row];
         [self.mapView removeAnnotations:self.mapView.annotations];
         
         // Remove overlays
         for (id<MKOverlay> overlayToRemove in self.mapView.overlays)
         {
            if ([overlayToRemove isKindOfClass:[MKPolyline class]])
                [self.mapView removeOverlay:overlayToRemove];
         }
         
         [self.tableView reloadData];
     }
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return @"Date   Pin Count";
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    
    /* Create Date Label */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, tableView.frame.size.width/2 - 10, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:18]];
    [label setText:@"Test"];
    [label setBackgroundColor:[UIColor blueColor]];
    [view addSubview:label];
    
    /* Create Pin Count Label */
    UILabel *countLbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.view.frame) - tableView.frame.size.width/2 + 10, 5, tableView.frame.size.width/2 - 10, 18)];
    [countLbl setFont:[UIFont boldSystemFontOfSize:18]];
    [countLbl setText:@"Pin Count"];
    [countLbl setBackgroundColor:[UIColor greenColor]];
    [view addSubview:countLbl];
    
    [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]];
    
    return view;
}



- (IBAction)closeAction:(id)sender
{
    [self removeAnimate];
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    //I set the segue identifier in the interface builder
//    if ([segue.identifier isEqualToString:@"detailsView"])
//    {
//
//        NSLog(@"segue"); //check to see if method is called, it is NOT called upon cell touch
//
//        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
//        ///more code to prepare next view controller....
//    }
//}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
