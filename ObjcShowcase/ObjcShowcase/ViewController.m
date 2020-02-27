//
//  ViewController.m
//  AmadeusCheckoutObjcShowcase
//
//  Created by Yann Armelin on 08/04/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
-(AMCheckoutOptions *)buildOptions;
@end



@implementation ViewController


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.paymentMethods = @[];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIPickerView* picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 300)];
    self.selectedMopPicker = picker;
    picker.delegate = self;
    picker.dataSource = self;
    
    UIToolbar * toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    toolbar.barStyle = UIBarStyleDefault;
    toolbar.translucent = true;
    [toolbar sizeToFit];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(payWithSelectedMethod:)];
    UIBarButtonItem* spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    [toolbar setItems:@[spaceButton, doneButton]  animated: false];
    toolbar.userInteractionEnabled = true;
    
    self.selectedMopText.inputView = picker;
    self.selectedMopText.inputAccessoryView = toolbar;
}


-(void)paymentContext:(AMCheckoutContext *)checkoutContext didFailToLoadWithError:(NSError *)error {
    NSLog(@"Host application: Payment didFailToLoadWithError");
    self.resultField.text = @"Loading issue";
    
    self.checkoutContext = nil;
}

-(void)paymentContext:(AMCheckoutContext *)checkoutContext didFinishWithStatus:(enum AMPaymentStatus)status error:(NSError *)error {
    NSLog(@"Host application: Payment didFinishWithStatus");
    switch(status){
        case AMPaymentStatusSuccess:
            NSLog(@"Host application: Payment didFinishWithStatus 'success'");
            self.resultField.text = @"Success";
            break;
        case AMPaymentStatusFailure:
        case AMPaymentStatusUnknown:
        {
            NSLog(@"Host application: Payment didFinishWithStatus 'failure'");
            NSString * statusStr = (status == AMPaymentStatusFailure ? @"Failure" : @"Unknown");
            NSString * errorType = [AMError typeToString:error.amErrorType];
            NSString * errorFeature = [AMError featureToString:error.amErrorFeature];
            self.resultField.text = [NSString stringWithFormat:@"%@(%ld)\nType: %@\nFeature: %@", statusStr, (long)error.code ,errorType, errorFeature];
            break;
        }
        case AMPaymentStatusCancellation:
            NSLog(@"Host application: Payment didFinishWithStatus 'cancellation'");
            self.resultField.text = @"Cancellation";
            break;
        default:
            break;
    }
    
    self.checkoutContext = nil;
}

-(AMCheckoutOptions *)buildOptions {
    AMCheckoutOptions * result = [[AMCheckoutOptions alloc] init];
    result.displayPayButtonOnTop = self.payButtonOnTopSwitch.isOn;
    result.dynamicVendor = self.dynamicVendorSwitch.isOn;
    if(self.customStylesSwitch.isOn) {
        result.primaryBackgroundColor = [UIColor colorWithRed:57.0/255.0 green:75.0/255.0 blue:97.0/255.0 alpha:1.0];
        result.secondaryBackgroundColor = [UIColor colorWithRed:41.0/255.0 green:59.0/255.0 blue:80.0/255.0 alpha:1.0];
        result.primaryForegroundColor = UIColor.whiteColor;
        result.secondaryForegroundColor = [UIColor colorWithRed:151.0/255.0 green:164.0/255.0 blue:179.0/255.0 alpha:1.0];
        result.accentColor = [UIColor colorWithRed:250.0/255.0 green:202.0/255.0 blue:0.0/255.0 alpha:1.0];
        result.errorColor = [UIColor colorWithRed:255.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0];
        result.font = [UIFont italicSystemFontOfSize:16.0];
        result.emphasisFont = [UIFont italicSystemFontOfSize:18.0];
    }
    
    result.appCallbackScheme = @"amadeus-checkout-swift-demo-app";
    
    if(self.termsAndConditionsSwitch.isOn){
        result.termsAndConditions = @[
            [[AMTermsAndConditions alloc] initWithLink:[NSURL URLWithString:@"https://amadeus.com/"] localizedLabel:@"Amadeus terms and conditions"],
            [[AMTermsAndConditions alloc] initWithLink:[NSURL URLWithString:@"https://amadeus.com/en/policies/privacy-policy"] localizedLabel:@"Privacy policy"]
       ];
    }
    if(self.bookingDetailsSwitch.isOn){
        NSArray * passengerList = @[@"Andy Davis", @"Carl Fredricksen", @"Alfredo Linguini"];
        NSTimeZone * parisTimezone = [[NSTimeZone alloc] initWithName:@"Europe/Paris"];
        NSTimeZone * newyorkTimezone = [[NSTimeZone alloc] initWithName:@"America/New_York"];
        
        NSDate *now = [[NSDate alloc] init];
        NSDate *d1 = [NSCalendar.currentCalendar dateByAddingUnit:NSCalendarUnitMinute value:1500 toDate:now options:0];
        NSDate *a1 = [NSCalendar.currentCalendar dateByAddingUnit:NSCalendarUnitMinute value:500 toDate:d1 options:0];
        NSDate *d2 = [NSCalendar.currentCalendar dateByAddingUnit:NSCalendarUnitMinute value:15000 toDate:a1 options:0];
        NSDate *a2 = [NSCalendar.currentCalendar dateByAddingUnit:NSCalendarUnitMinute value:500 toDate:d2 options:0];

        
        NSArray * flightList = @[
            [[AMFlight alloc] initWithDepartureAirport:@"Paris CDG" departureDate:d1 departureTimezone:parisTimezone arrivalAirport:@"New York JFK" arrivalDate:a1 arrivalTimezone:newyorkTimezone],
            [[AMFlight alloc] initWithDepartureAirport:@"New York JFK" departureDate:d2 departureTimezone:newyorkTimezone arrivalAirport:@"Paris CDG" arrivalDate:a2 arrivalTimezone:parisTimezone]
        ];
        result.bookingDetails = [[AMBookingDetails alloc] initWithPassengerList:passengerList flightList:flightList];
    }

    if(self.amountBreakdownSwitch.isOn) {
        result.amountBreakdown = @[
            [[AMAmountDetails alloc] initWithLabel:@"Flight ticket" amount:79.26],
            [[AMAmountDetails alloc] initWithLabel:@"Seat" amount:10.00],
            [[AMAmountDetails alloc] initWithLabel:@"Excess luggage" amount:9.50],
            [[AMAmountDetails alloc] initWithLabel:@"VAT" amount:24.69]
        ];
    }
    
    return result;
}


- (IBAction)pay:(id)sender {
    NSString * ppid = self.ppidTextField.text;
    self.checkoutContext = [[AMCheckoutContext alloc] initWithPpid:ppid environment:ppid.length ? AMEnvironmentPdt : AMEnvironmentMock];
    self.checkoutContext.hostViewController = self;
    self.checkoutContext.delegate = self;
    [self.checkoutContext presentChoosePaymentMethodViewControllerWithOptions:[self buildOptions]];
}

-(IBAction)fetchPaymentMethods:(id)sender {
    self.selectedMethod = nil;
    [self.selectedMopText resignFirstResponder];
    
    NSString * ppid = self.ppidTextField.text;
    self.checkoutContext = [[AMCheckoutContext alloc] initWithPpid:ppid environment:ppid.length ? AMEnvironmentPdt : AMEnvironmentMock];
    self.checkoutContext.hostViewController = self;
    self.checkoutContext.delegate = self;
    [self.checkoutContext fetchPaymentMethodsWithCallback:^(NSArray<AMPaymentMethod *> * methods) {
        if(methods != nil && methods.count > 0) {
            self.paymentMethods = methods;
            self.selectedMethod = methods.firstObject;
            
            [self.selectedMopPicker reloadAllComponents];
            [self.selectedMopPicker selectRow:0 inComponent:0 animated:NO];
            [self.selectedMopText becomeFirstResponder];
        }
    }];
}

- (IBAction)payWithSelectedMethod:(id)sender {
    [self.selectedMopText resignFirstResponder];
    [self.checkoutContext presentPaymentViewController:self.selectedMethod options:[self buildOptions]];
}



- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.paymentMethods.count;
}
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(self.paymentMethods[row].paymentMethodType == AMPaymentMethodTypeAlternativeMethodOfPayment){
        return self.paymentMethods[row].name;
    } else {
        return [AMPaymentMethod typeToString:[self.paymentMethods objectAtIndex:row].paymentMethodType];
    }
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedMethod = [self.paymentMethods objectAtIndex:row];
}

@end
