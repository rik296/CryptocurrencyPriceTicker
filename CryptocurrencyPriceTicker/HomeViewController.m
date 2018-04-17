//
//  HomeViewController.m
//  CryptocurrencyPriceTicker
//
//  Created by Rik Tsai on 2018/4/14.
//  Copyright © 2018年 Rik Tsai. All rights reserved.
//

#import "HomeViewController.h"
#import "API_Handler.h"
#import "CurrencyCell.h"

@interface HomeViewController ()
{
    NSMutableArray *currenciesArray;
    __weak IBOutlet UITableView *m_tableView;
}
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    currenciesArray = [[NSMutableArray alloc] init];
}

- (IBAction)refreshAction:(id)sender {
    [[API_Handler singleton]
     getTicker:E_CLOUD
     andStart:0
     andLimit:100
     andConvert:nil
     success:^(NSArray<TableCurrency*>* currencies) {
         
         [currenciesArray removeAllObjects];
         for (TableCurrency *item in currencies)
         {
             [currenciesArray addObject:item];
         }
         [m_tableView reloadData];
     }
     failure:^(NSInteger retCode) {
         
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [currenciesArray count];
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
    
    TableCurrency *item = [currenciesArray objectAtIndex:row];
    [cell.symbol setText:item.symbol];
    NSString *symbol = [item.symbol lowercaseString];
    [cell.icon setImage:[UIImage imageNamed:symbol]];
    NSString *rankAndName = [NSString stringWithFormat:@"#%@ %@", item.rank, item.name];
    [cell.rankAndName setText:rankAndName];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.groupingSize = 3;
    numberFormatter.usesGroupingSeparator = YES;
    numberFormatter.groupingSeparator = @",";
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    cell.value.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithFloat:[item.price_usd floatValue]]]];
    
    float percent = [item.percent_change_24h floatValue];
    [cell.percentView setBackgroundColor:(percent < 0 ? [UIColor colorWithRed:203.0/255.0 green:27.0/255.0 blue:69.0/255.0 alpha:1.0] : [UIColor colorWithRed:134.0/255.0 green:193.0/255.0 blue:102.0/255.0 alpha:1.0])];
    [cell.percent setText:[NSString stringWithFormat:@"%@%%", item.percent_change_24h]];
    
    return cell;
}

@end
