//
//  LLFormattingTextField.h
//  LLFormattingTextField
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ESupportInputType) {
    ESupportInputTypeOnlyDigit,         //仅支持输入数字
    ESupportInputTypeOnlyAlpha,         //仅支持输入字母
    ESupportInputTypeDigitAndAlpha,     //支持输入数字和字母
};

@interface LLFormattingTextField : UITextField

@property (nonatomic, assign) NSInteger maxCount; //最大输入量 默认16
@property (nonatomic, assign) NSInteger separatorCount;//分隔数 默认每4个分隔
@property (nonatomic, copy) NSString *separatorSymbol;////分隔符号 默认“-”
@property (nonatomic, assign) ESupportInputType supportInputType; //支持输入数据类型 默认ESupportInputTypeOnlyDigit

@end
