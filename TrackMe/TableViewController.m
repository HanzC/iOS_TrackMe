//
//  TableViewController.m
//  TrackMe
//
//  Created by Hanz Meyer on 4/22/21.
//

#import "TableViewController.h"
#import "GLManager.h"
#import "Location+CoreDataClass.h"

@interface TableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *popUpView;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (strong) NSMutableArray *dataArray;

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
        NSLog(@" *** TimeStamp:      %@", [arrayObjLoc valueForKey:@"timestamp"]);
        NSLog(@" *** TimeLoc Lat:    %@", [arrayObjLoc valueForKey:@"latitude"]);
        NSLog(@" *** TimeLoc Long:   %@", [arrayObjLoc valueForKey:@"longitude"]);
        NSLog(@"**\n\n");
    }
    NSLog(@"----\n\n\n---");
    
    
    // Execute Fetch Request For Time Location
    NSMutableArray *tmpArray = [[managedObjectContext executeFetchRequest:fetchRequestTime error:nil] mutableCopy];
    NSLog(@" *** TVC > TmpArray:    %@", tmpArray);

    NSManagedObject *arrayObj;
    for (int x = 0; x < [tmpArray count]; x++)
    {
        arrayObj = [tmpArray objectAtIndex:x];
        NSLog(@" *** TVC > TimeStamp: %@", [arrayObj valueForKey:@"timestamp"]);
        //NSLog(@" *** TVC > TimeLoc Lat:   %@", [[arrayObj valueForKey:@"time_location"] valueForKey:@"latitude"]);
        //NSLog(@" *** TVC > TimeLoc Long:  %@", [[arrayObj valueForKey:@"time_location"] valueForKey:@"longitude"]);
        NSLog(@"**\n\n");
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

//    cell.textLabel.text = @"TEST";
//    cell.textLabel.font = [cell.textLabel.font fontWithSize:20];
//    cell.imageView.image = [UIImage imageNamed:@"icon57x57"];
//    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    
    // Configure the cell...
    NSManagedObject *device = [self.dataArray objectAtIndex:indexPath.row];
    //[cell.textLabel setText:[NSString stringWithFormat:@"%@", [device valueForKey:@"timestamp"]]];
    //[cell.detailTextLabel setText:@"HERE"]; //[cell.detailTextLabel setText:[device valueForKey:@"latitude"]];
    
    // Initialize TimeStamp Label
    UILabel *lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, _tableView.frame.size.width/2, 35)];
    //lblTemp.tag = 1;
    //lblTemp.font =  [UIFont fontNamesForFamilyName:@"Arial"];
    lblTemp.font =  [UIFont fontWithName:@"Arial-BoldMT" size:15];
    lblTemp.backgroundColor = [UIColor yellowColor];
    lblTemp.text = [NSString stringWithFormat:@"%@", [device valueForKey:@"timestamp"]];
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

    
    NSLog(@"*** Start ***");
    [UIView animateWithDuration:0.5 animations:^{
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
            
            annotPoint.coordinate = coordinates;
            annotPoint.title = @"Here";
            //point.subtitle = @"I'm here!!!";
            [self.mapView addAnnotation:annotPoint];
        }
    }];
    
//    [self.mapView removeAnnotations:self.mapView.annotations];
//    for (NSManagedObject *product in fetchedProductsLoc)
//    {
//        NSLog(@" *** Fetched Loc Time:   %@", [product valueForKey:@"timestamp"]);
//        NSLog(@" *** Fetched Loc Lat:    %@", [product valueForKey:@"latitude"]);
//        NSLog(@" *** Fetched Loc Long:   %@", [product valueForKey:@"longitude"]);
//        NSLog(@"*\n\n\n*");
//
//        annotPoint = [[MKPointAnnotation alloc] init];
//
//        NSString *latString = [product valueForKey:@"latitude"];
//        NSString *longString = [product valueForKey:@"longitude"];
//        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake( [latString doubleValue], [longString doubleValue]);
//
//        annotPoint.coordinate = coordinates;
//        annotPoint.title = @"Here";
//        //point.subtitle = @"I'm here!!!";
//        [self.mapView addAnnotation:annotPoint];
//    }
    
    
//    MKCoordinateRegion defaultRegion = MKCoordinateRegionMake(self.mapView.centerCoordinate, MKCoordinateSpanMake(50, 50)); //180, 360
//    [self.mapView setRegion:defaultRegion animated:YES];
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
         
         
         /*
         // Create fetch request for Time Location
         NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
         NSEntityDescription *entity = [NSEntityDescription entityForName:@"TimeLocation" inManagedObjectContext:self.managedObjectContext];
         [fetchRequest setEntity:entity];

         // define a sort descriptor
//         NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
//         NSArray *scArray = [[NSArray alloc]initWithObjects:descriptor, nil];

         // give sort descriptor array to the fetch request
//         fetchRequest.sortDescriptors = scArray;
         
         NSLog(@" *** DataArray Index: %@", [[_dataArray objectAtIndex:indexPath.row] valueForKey:@"timestamp"]);
         
         NSPredicate *p = [NSPredicate predicateWithFormat:@"timestamp == %@", [[_dataArray objectAtIndex:indexPath.row] valueForKey:@"timestamp"]];
         [fetchRequest setPredicate:p];

         // fetch all objects
         NSError *error = nil;
         NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
         
         for (NSManagedObject *product in fetchedObjects)
         {
             NSLog(@" *** Fetched Product: %@", product);
         }
         
         if (fetchedObjects == nil)
         {
             NSLog(@" *** Error: %@", error);
         }
         */
         
         [self.tableView reloadData];
     }
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
