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

//    if ([GLManager sharedManager].transferLocationUpdates.count > 0)
//    {
//        for (id string in [GLManager sharedManager].transferLocationUpdates)
//        {
//            NSLog(@" *** String:    %@", [[string objectForKey:@"geometry"] objectForKey:@"coordinates"]);
//            NSLog(@" *** TimeStamp: %@", [[string objectForKey:@"properties"] objectForKey:@"timestamp"]);
//            NSLog(@" \n\n\n ");
//        }
//    }
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
    self.dataArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    [self.tableView reloadData];
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
    //return 2;
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UIAlertController *alert= [UIAlertController alertControllerWithTitle:@"Enter Folder Name" message:@"Keep it short and sweet" preferredStyle:UIAlertControllerStyleAlert];
//    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
//    {
//        textField.placeholder = @"folder name";
//        textField.keyboardType = UIKeyboardTypeDefault;
//    }];
//
//    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
//    {
//        NSLog(@"cancel btn");
//        [alert dismissViewControllerAnimated:YES completion:nil];
//    }];
//    [alert addAction:cancel];
//    [alert.view addSubview:_popUpView];
//
//    [self presentViewController:alert animated:YES completion:nil];
    
//    [self showAnimate];
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
         /*
         NSManagedObjectContext *context = [[GLManager sharedManager].fetchedResultsController managedObjectContext];
         [context deleteObject:[[GLManager sharedManager].fetchedResultsController objectAtIndexPath:indexPath]];
         NSError *error;
         if (![context save:&error])
         {
             NSLog(@" *** Can't Delete! %@ %@", error, [error localizedDescription]);
         }
         */
         
         
         /*
         NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Location"];
         NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timestamp == %@", [_dataArray objectAtIndex:indexPath.row]];
         [request setPredicate:predicate];

         NSError *error = nil;
         NSArray *result = [[GLManager sharedManager].managedObjectContext executeFetchRequest:request error:&error];
         if (!error && result.count > 0)
         {
             for(NSManagedObject *managedObject in result)
             {
                 [[GLManager sharedManager].managedObjectContext deleteObject:managedObject];
             }

             //Save context to write to store
             [[GLManager sharedManager].managedObjectContext save:nil];
         }
         */
         
         
        NSNumber *soughtPid = [NSNumber numberWithInt:53];
        NSEntityDescription *productEntity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:[GLManager sharedManager].managedObjectContext];
        NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
        [fetch setEntity:productEntity];
        NSPredicate *p=[NSPredicate predicateWithFormat:@"timestamp == %@", [_dataArray objectAtIndex:indexPath.row]];
        [fetch setPredicate:p];
        //... add sorts if you want them
        NSError *fetchError;
        NSArray *fetchedProducts = [[GLManager sharedManager].managedObjectContext executeFetchRequest:fetch error:&fetchError];
        // handle error
         
         for (NSManagedObject *product in fetchedProducts)
         {
             [[GLManager sharedManager].managedObjectContext deleteObject:product];
         }
         
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
