//
//  LLFormattingTextField.m
//  LLFormattingTextField
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "LLFormattingTextField.h"
@interface LLFormattingTextField()<UITextFieldDelegate>

@property (nonatomic, strong) NSString *previousTextFieldContent;
@property (nonatomic, strong) UITextRange *previousSelection;

@end

@implementation LLFormattingTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self configureField];
}
- (instancetype)init
{
    self = [super init];
    [self configureField];
    return self;
}

- (void)configureField {
    self.delegate = self;
    [self addTarget:self
             action:@selector(reformatAsCardNumber:)
   forControlEvents:UIControlEventEditingChanged];
}

- (NSInteger)maxCount {
    if(_maxCount <= 0) {
        _maxCount = 16;
    }
    return _maxCount;
}

- (NSString *)separatorSymbol {
    if (_separatorSymbol.length <= 0) {
        _separatorSymbol = @"-";
    }
    return _separatorSymbol;
}

- (ESupportInputType)supportInputType
{
    return _supportInputType;
}

- (NSInteger)separatorCount
{
    if (_separatorCount <= 0) {
        _separatorCount = 4;
    }
    return _separatorCount;
}
// Version 1.2
// Source and explanation: http://stackoverflow.com/a/19161529/1709587
-(void)reformatAsCardNumber:(UITextField *)textField
{
    // In order to make the cursor end up positioned correctly, we need to
    // explicitly reposition it after we inject spaces into the text.
    // targetCursorPosition keeps track of where the cursor needs to end up as
    // we modify the string, and at the end we set the cursor position to it.
    NSUInteger targetCursorPosition =
    [textField offsetFromPosition:textField.beginningOfDocument
                       toPosition:textField.selectedTextRange.start];
    
    NSString *cardNumberWithoutSpaces =
    [self removeNonDigits:textField.text
andPreserveCursorPosition:&targetCursorPosition];
    
    if ([cardNumberWithoutSpaces length] > self.maxCount) {
        // If the user is trying to enter more than 16 digits, we prevent
        // their change, leaving the text field in  its previous state.
        // While 16 digits is usual, credit card numbers have a hard
        // maximum of 19 digits defined by ISO standard 7812-1 in section
        // 3.8 and elsewhere. Applying this hard maximum here rather than
        // a maximum of 16 ensures that users with unusual card numbers
        // will still be able to enter their card number even if the
        // resultant formatting is odd.
        [textField setText:self.previousTextFieldContent];
        textField.selectedTextRange = self.previousSelection;
        return;
    }
    
    NSString *cardNumberWithSpaces =
    [self insertSpacesEveryFourDigitsIntoString:cardNumberWithoutSpaces
                      andPreserveCursorPosition:&targetCursorPosition];
    
    textField.text = cardNumberWithSpaces;
    UITextPosition *targetPosition =
    [textField positionFromPosition:[textField beginningOfDocument]
                             offset:targetCursorPosition];
    
    [textField setSelectedTextRange:
     [textField textRangeFromPosition:targetPosition
                           toPosition:targetPosition]
     ];
}

-(BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    // Note textField's current state before performing the change, in case
    // reformatTextField wants to revert it
    self.previousTextFieldContent = textField.text;
    self.previousSelection = textField.selectedTextRange;
    
    return YES;
}

/*
 Removes non-digits from the string, decrementing `cursorPosition` as
 appropriate so that, for instance, if we pass in `@"1111 1123 1111"`
 and a cursor position of `8`, the cursor position will be changed to
 `7` (keeping it between the '2' and the '3' after the spaces are removed).
 */
- (NSString *)removeNonDigits:(NSString *)string
    andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
    NSUInteger originalCursorPosition = *cursorPosition;
    NSMutableString *digitsOnlyString = [NSMutableString new];
    for (NSUInteger i=0; i<[string length]; i++) {
        unichar characterToAdd = [string characterAtIndex:i];
        NSLog(@"-----%tu",isalpha(characterToAdd));
        BOOL acceptInput = NO;
        switch (self.supportInputType) {
            case ESupportInputTypeOnlyDigit:
                acceptInput = isdigit(characterToAdd);
                break;
            case ESupportInputTypeOnlyAlpha:
                acceptInput = isalpha(characterToAdd);
                break;
            case ESupportInputTypeDigitAndAlpha:
                acceptInput = isdigit(characterToAdd) || isalpha(characterToAdd);
                break;
            default:
                acceptInput = isdigit(characterToAdd);
                break;
        }
        if (acceptInput) {
            NSString *stringToAdd =
            [NSString stringWithCharacters:&characterToAdd
                                    length:1];
            
            [digitsOnlyString appendString:stringToAdd];
        }
        else {
            if (i < originalCursorPosition) {
                (*cursorPosition)--;
            }
        }
    }
    
    return digitsOnlyString;
}

/*
 Inserts spaces into the string to format it as a credit card number,
 incrementing `cursorPosition` as appropriate so that, for instance, if we
 pass in `@"111111231111"` and a cursor position of `7`, the cursor position
 will be changed to `8` (keeping it between the '2' and the '3' after the
 spaces are added).
 */
- (NSString *)insertSpacesEveryFourDigitsIntoString:(NSString *)string
                          andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
    NSUInteger cursorPositionInSpacelessString = *cursorPosition;
    for (NSUInteger i=0; i<[string length]; i++) {
        if ((i>0) && ((i % self.separatorCount) == 0)) {
            [stringWithAddedSpaces appendString:self.separatorSymbol];
            if (i < cursorPositionInSpacelessString) {
                (*cursorPosition)++;
            }
        }
        unichar characterToAdd = [string characterAtIndex:i];
        NSString *stringToAdd =
        [NSString stringWithCharacters:&characterToAdd length:1];
        
        [stringWithAddedSpaces appendString:stringToAdd];
    }
    
    return stringWithAddedSpaces;
}
@end
