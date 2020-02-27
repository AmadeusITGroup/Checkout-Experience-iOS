//
//  ViewController.h
//  AmadeusCheckoutObjcShowcase
//
//  Created by Yann Armelin on 08/04/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AmadeusCheckout;


@interface ViewController : UIViewController<AMCheckoutDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) AMCheckoutContext *checkoutContext;
@property (strong, nonatomic) NSArray<AMPaymentMethod *> *paymentMethods;
@property (strong, nonatomic) AMPaymentMethod *selectedMethod;


@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (weak, nonatomic) IBOutlet UITextField *selectedMopText;
@property (weak, nonatomic) IBOutlet UIPickerView *selectedMopPicker;
@property (weak, nonatomic) IBOutlet UITextField *ppidTextField;
@property (weak, nonatomic) IBOutlet UILabel *resultField;
@property (weak, nonatomic) IBOutlet UISwitch *payButtonOnTopSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *dynamicVendorSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *customStylesSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *termsAndConditionsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *bookingDetailsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *amountBreakdownSwitch;

- (IBAction)pay:(id)sender;
- (IBAction)fetchPaymentMethods:(id)sender;
- (IBAction)payWithSelectedMethod:(id)sender;


#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;

#pragma mark UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;


@end


