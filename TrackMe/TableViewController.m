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
CLGeocoder *geocoder;
MKAnnotationView *pinView;

NSString *street;
NSString *city;
NSString *state;
NSString *posCode;
NSString *country;

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
    geocoder = [[CLGeocoder alloc] init];
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
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    MKMapRect rect = [self.mapView visibleMapRect];
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.mapView setVisibleMapRect:rect edgePadding:insets animated:YES];
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.alpha = 0.33;
    renderer.lineWidth = 4.0;

    return renderer;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    ///*
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;

    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = YES;
            pinView.image = [UIImage imageNamed:@"history"];
            pinView.calloutOffset = CGPointMake(5, 32);
            pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        else
        {
            pinView.annotation = annotation;
        }

        return pinView;
    }
    return nil;
    //*/

    /*
    static NSString *AnnotationIdentifier = @"Annotation";
    if ([annotation isKindOfClass:MKUserLocation.class])
        return nil;

    MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];

    if (!pinAnnotationView)
    {
        pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier] ;
        pinAnnotationView.canShowCallout = YES;
        pinAnnotationView.calloutOffset = CGPointMake(-7, 0);
        //pinAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }

    return pinAnnotationView;
    */
}

//- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
//{
//    NSLog(@" *** calloutAccessoryControlTapped > Annot Selected: %f", view.annotation.coordinate.latitude);
//}

//- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
//{
//    NSLog(@" *** Annot Title:    %@", view.annotation.title);
//
//    self.mapView.centerCoordinate = view.annotation.coordinate;
//    NSLog(@" *** Annot Selected: %f", view.annotation.coordinate.latitude);
//
//    //1. Location from latitude and longitude
//    CLLocation *location = [[CLLocation alloc] initWithLatitude:view.annotation.coordinate.latitude longitude:view.annotation.coordinate.longitude];
//
//    //2. After we have current coordinates, we use this method to fetch the information data of fetched coordinate
//    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
//    {
//        CLPlacemark *placemark = [placemarks lastObject];
//
//        street = placemark.thoroughfare;
//        city = placemark.locality;
//        state = placemark.administrativeArea;
//        posCode = placemark.postalCode;
//        country = placemark.country;
//        NSLog(@" *** Street: %@", state);
//    }];
//
//    NSLog(@"\n\n");
//}


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
    NSLog(@" *** TableViewController > cellForRowAtIndexPath:  %@", formattedDate);
    
    // Convert to String Date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSLog(@" *** %@", [formatter stringFromDate:formattedDate]);
    //NSLog(@"\n\n");
    
    
    // Initialize TimeStamp Label
    UILabel *lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, _tableView.frame.size.width/2 + 25, 35)];
    lblTemp.font =  [UIFont fontWithName:@"Arial-BoldMT" size:15];
    lblTemp.backgroundColor = [UIColor yellowColor];
    lblTemp.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:formattedDate]]; //[NSString stringWithFormat:@"%@", [device valueForKey:@"timestamp"]];
    lblTemp.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:lblTemp];
    
    
    int countPins = 0;
    // Create fetch request For Annotations
    NSEntityDescription *productEntityLoc = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchLoc = [[NSFetchRequest alloc] init];
    [fetchLoc setEntity:productEntityLoc];
    NSPredicate *pLoc = [NSPredicate predicateWithFormat:@"timestamp == %@", [[_dataArray objectAtIndex:indexPath.row] valueForKey:@"timestamp"]];
    [fetchLoc setPredicate:pLoc];
    
    NSError *fetchErrorLoc;
    NSArray *fetchedProductsLoc = [self.managedObjectContext executeFetchRequest:fetchLoc error:&fetchErrorLoc];
    for (NSManagedObject *product in fetchedProductsLoc)
    {
        //NSString *latString = [product valueForKey:@"latitude"];
        //NSString *longString = [product valueForKey:@"longitude"];
        //CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake( [latString doubleValue], [longString doubleValue]);
        
        NSString *tmp1 = [device valueForKey:@"timestamp"];
        NSString *tmp2 = [product valueForKey:@"timestamp"];
        if ([tmp1 isEqualToString:tmp2])
        {
            countPins++;
        }
        
        NSLog(@" *** cellForRowAtIndexPath > AnnotPoint Time:   %@", [product valueForKey:@"timestamp"]);
        NSLog(@" *** cellForRowAtIndexPath > AnnotPoint:        %f", annotPoint.coordinate.latitude);
        NSLog(@"\n\n\n");
    }
    NSLog(@" *** cellForRowAtIndexPath > Count:   %d", countPins);
    // Initialize Annotation Count Label
    UILabel *countTemp = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_tableView.frame) - 55, 5, 50, 35)];
    countTemp.font =  [UIFont fontWithName:@"Arial-BoldMT" size:15];
    countTemp.backgroundColor = [UIColor yellowColor];
    countTemp.text = [NSString stringWithFormat:@"%d", countPins];
    countTemp.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:countTemp];
    

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
            [self callReverseGeocode:pinView]; //annotation isKindOfClass:[MKUserLocation class]]
            annotPoint.coordinate = coordinates;
            annotPoint.title = [NSString stringWithFormat:@"%@", street];
            [self.mapView addAnnotation:annotPoint];
            
            // Add Overlay
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
//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
- (void)callReverseGeocode:(MKAnnotationView *)view
{
    //1. Location from latitude and longitude
    CLLocation *location = [[CLLocation alloc] initWithLatitude:view.annotation.coordinate.latitude longitude:view.annotation.coordinate.longitude];

    //2. After we have current coordinates, we use this method to fetch the information data of fetched coordinate
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
    {
        CLPlacemark *placemark = [placemarks lastObject];

        street = placemark.thoroughfare;
        city = placemark.locality;
        state = placemark.administrativeArea;
        posCode = placemark.postalCode;
        country = placemark.country;
        NSLog(@" *** Street: %@", state);
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    
    /* Create Date Label */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width/2 - 10, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:18]];
    [label setText:@"Date & Time"];
    [label setBackgroundColor:[UIColor blueColor]];
    [view addSubview:label];
    
    /* Create Pin Count Label */
    UILabel *countLbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(tableView.frame) - 110, 0, 100, 18)];
    [countLbl setFont:[UIFont boldSystemFontOfSize:18]];
    [countLbl setText:@"Pin Count"];
    [countLbl setBackgroundColor:[UIColor greenColor]];
    [countLbl setTextAlignment:NSTextAlignmentRight];
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
