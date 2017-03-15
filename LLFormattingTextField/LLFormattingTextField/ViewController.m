//
//  ViewController.m
//  LLFormattingTextField
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "ViewController.h"
#import "LLFormattingTextField.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet LLFormattingTextField *formatTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.formatTextField.supportInputType = ESupportInputTypeDigitAndAlpha;
    self.formatTextField.separatorSymbol = @" ";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
