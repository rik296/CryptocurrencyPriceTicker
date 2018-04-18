//
//  HomeViewController.m
//  CryptocurrencyPriceTicker
//
//  Created by Rik Tsai on 2018/4/14.
//  Copyright © 2018年 Rik Tsai. All rights reserved.
//

#import "HomeViewController.h"
#import "API_Handler.h"
#import "DataBase_Handler.h"
#import "CurrencyCell.h"
#import "FiatConvertViewController.h"

#define FETCH_LIMIT 100

@interface HomeViewController ()
{
    NSMutableArray *currenciesArray;
    NSMutableArray *filterCurrenciesArray;
    BOOL isDoingSync;
    NSInteger currentFetchStart;
    NSNumberFormatter *numberFormatter;
    UITapGestureRecognizer *tapgr;
    
    __weak IBOutlet UITableView *m_tableView;
    __weak IBOutlet UIActivityIndicatorView *refreshIndicator;
    __weak IBOutlet UISearchBar *keywordSearchBar;
    __weak IBOutlet UISegmentedControl *m_segment;
    __weak IBOutlet NSLayoutConstraint *constraintBottomTableView;
}
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    currenciesArray = [[NSMutableArray alloc] init];
    filterCurrenciesArray = [[NSMutableArray alloc] init];
    
    m_segment.selectedSegmentIndex = 1;
    m_tableView.allowsMultipleSelectionDuringEditing = NO;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleCellViewLongPress:)];
    lpgr.minimumPressDuration = 1.3; //seconds
    lpgr.delegate = self;
    [m_tableView addGestureRecognizer:lpgr];
    
    tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTableViewTap:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initDisplayData];
}

- (IBAction)refreshAction:(id)sender {
    [self refreshTop100Data];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Get Data

- (void)initDisplayData
{
    [refreshIndicator startAnimating];
    currentFetchStart = 0;
    isDoingSync = YES;
    
    // fetch data from database for initial display
    [[API_Handler singleton]
     getTicker:E_DATABASE
     andStart:currentFetchStart
     andLimit:FETCH_LIMIT
     andConvert:nil
     success:^(NSArray<TableCurrency*>* currencies) {
         
         [currenciesArray removeAllObjects];
         for (TableCurrency *item in currencies)
         {
             [currenciesArray addObject:item];
         }
         [m_tableView reloadData];
         
         // then renew data from Cloud
         [[API_Handler singleton]
          getTicker:E_CLOUD
          andStart:currentFetchStart
          andLimit:FETCH_LIMIT
          andConvert:nil
          success:^(NSArray<TableCurrency*>* currencies) {
              
              [currenciesArray removeAllObjects];
              for (TableCurrency *item in currencies)
              {
                  [currenciesArray addObject:item];
              }
              [m_tableView reloadData];
              
              currentFetchStart += 100;
              isDoingSync = NO;
              [refreshIndicator stopAnimating];
          }
          failure:^(NSInteger retCode) {
              isDoingSync = NO;
              [refreshIndicator stopAnimating];
          }];
     }
     failure:^(NSInteger retCode) {
         isDoingSync = NO;
     }];
}

- (void)refreshTop100Data
{
    [refreshIndicator startAnimating];
    currentFetchStart = 0;
    
    [[API_Handler singleton]
     getTicker:E_CLOUD
     andStart:currentFetchStart
     andLimit:FETCH_LIMIT
     andConvert:nil
     success:^(NSArray<TableCurrency*>* currencies) {
         
         [currenciesArray removeAllObjects];
         for (TableCurrency *item in currencies)
         {
             [currenciesArray addObject:item];
         }
         
         currentFetchStart += 100;
         isDoingSync = NO;
         m_tableView.contentOffset = CGPointMake(0, 0 - m_tableView.contentInset.top);
         [m_tableView reloadData];
         [refreshIndicator stopAnimating];
     }
     failure:^(NSInteger retCode) {
         isDoingSync = NO;
         [refreshIndicator stopAnimating];
     }];
}

- (void)getMoreData
{
    [[API_Handler singleton]
     getTicker:E_CLOUD
     andStart:currentFetchStart
     andLimit:FETCH_LIMIT
     andConvert:nil
     success:^(NSArray<TableCurrency*>* currencies) {
         
         for (TableCurrency *item in currencies)
         {
             [currenciesArray addObject:item];
         }
         [m_tableView reloadData];
         
         constraintBottomTableView.constant = 0.0;
         [self.view layoutIfNeeded];
         [refreshIndicator stopAnimating];
         
         currentFetchStart += 100;
         isDoingSync = NO;
     }
     failure:^(NSInteger retCode) {
         isDoingSync = NO;
         constraintBottomTableView.constant = 0.0;
         [self.view layoutIfNeeded];
         [refreshIndicator stopAnimating];
     }];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self keywordFilter];
    return [filterCurrenciesArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    
    NSString *CellIdentifier = [[NSString alloc] initWithFormat:@"Cell%ld", (long)row];
    
    CurrencyCell *cell = (CurrencyCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [m_tableView registerNib:[UINib nibWithNibName:@"CurrencyCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = (CurrencyCell*)[m_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    TableCurrency *item = [filterCurrenciesArray objectAtIndex:row];
    
    // symbol
    [cell.symbol setText:item.symbol];
    
    // icon image
    NSString *symbol = [item.symbol lowercaseString];
    UIImage *iconImage = [UIImage imageNamed:symbol];
    [cell.icon setImage:(iconImage != nil ? iconImage : [UIImage imageNamed:@"other"])];
    
    // rank and name
    NSString *rankAndName = [NSString stringWithFormat:@"#%@ %@", item.rank, item.name];
    [cell.rankAndName setText:rankAndName];
    
    // value
    double displayValue = 0.0;
    switch (m_segment.selectedSegmentIndex) {
        case 0:
            displayValue = [item.market_cap_usd doubleValue];
            break;
        case 1:
            displayValue = [item.price_usd doubleValue];
            break;
        case 2:
            displayValue = [item.s24h_volume_usd doubleValue];
            break;
        case 3:
            displayValue = [item.price_usd doubleValue];
            break;
        default:
            break;
    }
    cell.value.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithDouble:displayValue]]];
    
    // percent view
    float percent = [item.percent_change_24h floatValue];
    if (percent == 0.0)
    {
        [cell.percentView setBackgroundColor:[UIColor lightGrayColor]];
    }
    else
    {
        [cell.percentView setBackgroundColor:(percent < 0 ? [UIColor colorWithRed:203.0/255.0 green:27.0/255.0 blue:69.0/255.0 alpha:1.0] : [UIColor colorWithRed:134.0/255.0 green:193.0/255.0 blue:102.0/255.0 alpha:1.0])];
    }
    [cell.percent setText:[NSString stringWithFormat:@"%@%%", (item.percent_change_24h.length > 0 ? item.percent_change_24h : @"0.00")]];
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableCurrency *theCurrency = [filterCurrenciesArray objectAtIndex:[indexPath row]];
    
    UIStoryboard* story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FiatConvertViewController *vc = [story instantiateViewControllerWithIdentifier:@"FiatConvertViewController"];
    vc.coinID = theCurrency.coinID;
    [self.navigationController pushViewController:vc animated:YES];
    
    [m_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    if (h > [UIScreen mainScreen].bounds.size.height)
    {
        float reload_distance = 10.0;
        if ((y > h + reload_distance) && (isDoingSync == NO))
        {
            NSLog(@"[HomeViewController] Get More Currencies");
            isDoingSync = YES;
            constraintBottomTableView.constant = 57.0;
            [self.view layoutIfNeeded];
            [refreshIndicator startAnimating];
            [self getMoreData];
        }
    }
    
    /*
    if (offset.y < -100 && (isDoingSync == NO))
    {
        NSLog(@"[HomeViewController] Refresh Top 100 Currencies");
        isDoingSync = YES;
        [self refreshTop100Data];
    }
     */
}

-(void)handleCellViewLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:m_tableView];
    
    NSIndexPath *indexPath = [m_tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"long press on table view but not on a row");
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"long press on table view at row %ld", indexPath.row);
    }
    else {
        NSLog(@"gestureRecognizer.state = %ld", gestureRecognizer.state);
    }
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Add to My Favorite?" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{}];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        // OK button tapped.
        // add favorite currency
        TableCurrency *theCurrency = [filterCurrenciesArray objectAtIndex:indexPath.row];
        theCurrency.favorite = @(YES);
        [[DataBase_Handler singleton] storeModifyCurrency:theCurrency];
        
        [self dismissViewControllerAnimated:YES completion:^{}];
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)handleTableViewTap:(UITapGestureRecognizer *)gestureRecognizer
{
    [m_tableView removeGestureRecognizer:tapgr];
    [keywordSearchBar resignFirstResponder];
}

#pragma mark -
#pragma mark Search Bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"Filter : %@", searchText);
    [m_tableView removeGestureRecognizer:tapgr];
    [m_tableView addGestureRecognizer:tapgr];
    [m_tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [theSearchBar resignFirstResponder];
}

- (void)keywordFilter
{
    [filterCurrenciesArray removeAllObjects];
    
    if (keywordSearchBar.text.length == 0)
    {
        [filterCurrenciesArray setArray:currenciesArray];
    }
    else
    {
        for (TableCurrency *item in currenciesArray)
        {
            if ([item.symbol containsString:[keywordSearchBar.text uppercaseString]])
            {
                [filterCurrenciesArray addObject:item];
            }
        }
    }
}

#pragma mark -
#pragma mark UISegment Action

- (IBAction)segmentAction:(id)sender
{
    [m_tableView reloadData];
}

@end
