//
//  ViewController.m
//  CryptocurrencyPriceTicker
//
//  Created by Rik Tsai on 2018/4/18.
//  Copyright © 2018年 Rik Tsai. All rights reserved.
//

#import "FiatConvertViewController.h"
#import "API_Handler.h"
#import "DataBase_Handler.h"

#define Fiat_Code @[\
@"USD"\
,@"AUD"\
,@"BRL"\
,@"CAD"\
,@"CHF"\
,@"CLP"\
,@"CNY"\
,@"CZK"\
,@"DKK"\
,@"EUR"\
,@"GBP"\
,@"HKD"\
,@"HUF"\
,@"IDR"\
,@"ILS"\
,@"INR"\
,@"JPY"\
,@"KRW"\
,@"MXN"\
,@"MYR"\
,@"NOK"\
,@"NZD"\
,@"PHP"\
,@"PKR"\
,@"PLN"\
,@"RUB"\
,@"SEK"\
,@"SGD"\
,@"THB"\
,@"TRY"\
,@"TWD"\
,@"ZAR"\
]

@interface FiatConvertViewController ()
{
    __weak IBOutlet UITableView *m_tableView;
    __weak IBOutlet UIActivityIndicatorView *loadingIndicator;
    
    TableCurrency *currentCurrency;
    NSNumberFormatter *numberFormatter;
    BOOL isDoingSync;
}
@end

@implementation FiatConvertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    currentCurrency = [[DataBase_Handler singleton] fetchCurrencyByID:self.coinID];
    
    numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    isDoingSync = YES;
    [loadingIndicator startAnimating];
    [self getFiatConvert:Fiat_Code];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Get Data

- (void)getFiatConvert:(NSArray*)leftFiats
{
    if ([leftFiats count] == 0)
    {
        currentCurrency = [[DataBase_Handler singleton] fetchCurrencyByID:self.coinID];
        isDoingSync = NO;
        [loadingIndicator stopAnimating];
        [m_tableView reloadData];        
        NSLog(@"%@", currentCurrency.fiat_convert);
        return;
    }
    
    NSMutableArray *tmpFiats = [NSMutableArray array];
    NSString *fiatCode = [leftFiats objectAtIndex:0];
    [[API_Handler singleton]
     getTickerSpecificCurrency:E_CLOUD
     andCoinID:self.coinID
     andConvert:fiatCode
     success:^(TableCurrency *currency) {
         
         [tmpFiats setArray:leftFiats];
         [tmpFiats removeObjectAtIndex:0];
         [self getFiatConvert:tmpFiats];
         
     }
     failure:^(NSInteger retCode) {
         
         [tmpFiats setArray:leftFiats];
         [tmpFiats removeObjectAtIndex:0];
         [self getFiatConvert:tmpFiats];
         
     }];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else
    {
        return 3;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 + [Fiat_Code count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"Currency";
            break;
            
        default:
            return [Fiat_Code objectAtIndex:section-1];
            break;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    NSString *CellIdentifier = [[NSString alloc] initWithFormat:@"Cell%d%d", (int)section, (int)row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        if (section == 0)
        {
            cell.textLabel.text = currentCurrency.name;
            cell.detailTextLabel.text = currentCurrency.symbol;
        }
        else
        {
            switch (row) {
                case 0:
                    cell.textLabel.text = @"Price";
                    break;
                    
                case 1:
                    cell.textLabel.text = @"24H Volume";
                    break;
                    
                case 2:
                    cell.textLabel.text = @"Market Cap";
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    if (section != 0)
    {
        NSString *fiatCode = [Fiat_Code objectAtIndex:section-1];
        NSDictionary *fiatConvert = (NSDictionary*)currentCurrency.fiat_convert;
        double displayValue = 0.0;
        
        if (row == 0)
        {
            NSString *key_price = [NSString stringWithFormat:@"price_%@", [fiatCode lowercaseString]];
            if ([fiatConvert objectForKey:key_price] != nil && ![[fiatConvert objectForKey:key_price] isKindOfClass:[NSNull class]])
            {
                displayValue = [[fiatConvert objectForKey:key_price] doubleValue];
            }
        }
        else if (row == 1)
        {
            NSString *key_volume = [NSString stringWithFormat:@"24h_volume_%@", [fiatCode lowercaseString]];
            if ([fiatConvert objectForKey:key_volume] != nil && ![[fiatConvert objectForKey:key_volume] isKindOfClass:[NSNull class]])
            {
                displayValue = [[fiatConvert objectForKey:key_volume] doubleValue];
            }
        }
        else
        {
            NSString *key_market = [NSString stringWithFormat:@"market_cap_%@", [fiatCode lowercaseString]];
            if ([fiatConvert objectForKey:key_market] != nil && ![[fiatConvert objectForKey:key_market] isKindOfClass:[NSNull class]])
            {
                displayValue = [[fiatConvert objectForKey:key_market] doubleValue];
            }
        }
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithDouble:displayValue]]];
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    if (offset.y < -100 && (isDoingSync == NO))
    {
        NSLog(@"[FiatConvertViewController] Refresh Convert");
        isDoingSync = YES;
        [loadingIndicator startAnimating];
        [self getFiatConvert:Fiat_Code];
    }
}

@end
