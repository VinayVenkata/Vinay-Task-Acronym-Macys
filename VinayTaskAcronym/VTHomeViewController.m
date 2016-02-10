//
//  ViewController.m
//  AcronymDen
//
//  Created by Vinay on 02/09/16.
//  Copyright © 2016 Vinay. All rights reserved.
//

#import "VTHomeViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "MBProgressHUD.h"
#import "VTAcronym.h"

#define VT_BASE_URL @"http://www.nactem.ac.uk/software/acromine/dictionary.py"

@interface VTHomeViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UITextField *searchTextField;
@property (nonatomic, weak) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UILabel *noResultsLabel;

@property (nonatomic, retain) NSArray *responseList;
@property (nonatomic, retain) NSMutableArray *acronymsArray;

- (IBAction) searchButtonClicked:(UIButton *)sender;

@end

@implementation VTHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib
    
    self.acronymsArray = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)getAcronymFor:(NSString *)shortString {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *keyToLoad = @"sf";
    if ([shortString rangeOfString:@" "].location != NSNotFound) {
        keyToLoad=@"lf";
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:VT_BASE_URL parameters:[NSDictionary dictionaryWithObjectsAndKeys:shortString, keyToLoad, nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *error = nil;
        
        id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"%@", obj);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        
        @try {
            self.responseList = obj;
            [self.acronymsArray removeAllObjects];
            
            if (self.responseList.count > 0) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.noResultsLabel.hidden = YES;
                    self.tableView.hidden = NO;
                });
                
                NSArray *lfsArray = [[self.responseList objectAtIndex:0] objectForKey:@"lfs"];
                for (NSDictionary *lfDict in lfsArray) {
                    NSError *error;
                    VTAcronym *acronym = [[VTAcronym alloc] initWithDictionary:lfDict error:&error];
                    [self.acronymsArray addObject:acronym];
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view bringSubviewToFront:self.noResultsLabel];
                    self.noResultsLabel.hidden = NO;
                    self.tableView.hidden = YES;
                });
            }
            
        }
        @catch (NSException *exception) {
            NSLog(@"Error while retrieving response list.. %@", exception);
        }
        @finally {
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        
        NSLog(@"Error: %@", error);
        
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Alert"
                                      message:[NSString stringWithFormat: @"Error while fetching the Data. %@", [error localizedDescription]]
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction  actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
        {
            [alert dismissViewControllerAnimated:YES completion:nil];
            
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        
        
        
    }];
    
}

- (IBAction) searchButtonClicked:(UIButton *)sender {
    
    [self.searchTextField resignFirstResponder];
    
    [self getAcronymFor:self.searchTextField.text];
    
}

#pragma mark - TableView Delegate and Datasource Handler
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.responseList.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.acronymsArray.count;
    
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.searchTextField.text.uppercaseString;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        
    }
    
    @try{
        VTAcronym *acronym = [self.acronymsArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = acronym.lf;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Frequency: %@ , Since: %@",acronym.freq,acronym.since];
    }
    @catch (NSException *exception) {
        NSLog(@"Error while populating list data.. %@", exception);
    }
    @finally {
        
    }
    
    
    return cell;
}

#pragma mark - TextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
