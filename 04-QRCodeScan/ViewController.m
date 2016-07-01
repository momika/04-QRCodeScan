//
//  ViewController.m
//  04-QRCodeScan
//
//  Created by vera on 16/6/23.
//  Copyright © 2016年 vera. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)QRCodeButtonClick:(id)sender
{
    [self presentViewController:[[QRCodeViewController alloc] init] animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}








- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
