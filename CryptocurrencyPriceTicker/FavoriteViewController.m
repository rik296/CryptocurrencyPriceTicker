//
//  SecondViewController.m
//  CryptocurrencyPriceTicker
//
//  Created by Rik Tsai on 2018/4/14.
//  Copyright © 2018年 Rik Tsai. All rights reserved.
//

#import "FavoriteViewController.h"
#import "API_Handler.h"
#import "DataBase_Handler.h"
#import "CurrencyCell.h"

@interface FavoriteViewController ()
{
    NSMutableArray *currenciesArray;
    NSMutableArray *filterCurrenciesArray;
    BOOL isDoingSync;
    NSNumberFormatter *numberFormatter;
    
    __weak IBOutlet UITableView *m_tableView;
    __weak IBOutlet UISearchBar *keywordSearchBar;
    __weak IBOutlet UISegmentedControl *m_segment;
    __weak IBOutlet NSLayoutConstraint *constraintBottomTableView;
}
@end

@implementation FavoriteViewController

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initDisplayData];
}

- (IBAction)refreshAction:(id)sender {
    NSMutableArray *tmpCurrencies = [NSMutableArray array];
    [tmpCurrencies setArray:currenciesArray];
    [currenciesArray removeAllObjects];
    [self refreshFavoriteCurrencies:tmpCurrencies];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Get Data

- (void)initDisplayData
{
    [currenciesArray setArray:[[DataBase_Handler singleton] fetchCurrenciesByFavorite]];
    [m_tableView reloadData];
}

- (void)refreshFavoriteCurrencies:(NSArray*)leftCurrencies
{
    if ([leftCurrencies count] == 0)
    {
        [self initDisplayData];
        return;
    }
    
    NSMutableArray *tmpCurrencies = [NSMutableArray array];
    TableCurrency *theCurrency = [leftCurrencies objectAtIndex:0];
    [[API_Handler singleton]
     getTickerSpecificCurrency:E_CLOUD
     andCoinID:theCurrency.coinID
     andConvert:nil
     success:^(TableCurrency *currency) {
         [currenciesArray addObject:currency];
         [tmpCurrencies setArray:leftCurrencies];
         [tmpCurrencies removeObjectAtIndex:0];
         [self refreshFavoriteCurrencies:tmpCurrencies];
     }
     failure:^(NSInteger retCode) {
         [currenciesArray addObject:theCurrency];
         [tmpCurrencies setArray:leftCurrencies];
         [tmpCurrencies removeObjectAtIndex:0];
         [self refreshFavoriteCurrencies:tmpCurrencies];
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
    UIStoryboard* story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [self.navigationController pushViewController:[story instantiateViewControllerWithIdentifier:@"FiatConvertViewController"] animated:YES];
    
    [m_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        TableCurrency *deleteCurrency = [filterCurrenciesArray objectAtIndex:indexPath.row];
        deleteCurrency.favorite = @(NO);
        [[DataBase_Handler singleton] storeModifyCurrency:deleteCurrency];
        [self initDisplayData];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    [keywordSearchBar resignFirstResponder];
}

#pragma mark -
#pragma mark Search Bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"Filter : %@", searchText);
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
