//
//  IAPHelper.h
//  Vaunt
//
//  Created by Mobile on 23/8/16.
//  Copyright © 2016 Arthur. All rights reserved.
//

#import <Foundation/Foundation.h>
@import StoreKit;

#define IAPKeyPack1 @"com.appgoland.carbon.pack1"

@protocol IAPHelperDelegate <NSObject>
@required
- (void)bankerFailedToConnect;
- (void)bankerNoProductsFound;
- (void)bankerFoundProducts:(NSArray *)products;
- (void)bankerFoundInvalidProducts:(NSArray *)products;
- (void)bankerProvideContent:(SKPaymentTransaction *)paymentTransaction;
- (void)bankerPurchaseComplete:(SKPaymentTransaction *)paymentTransaction;
- (void)bankerPurchaseFailed:(NSString *)productIdentifier withError:(NSString *)errorDescription;
- (void)bankerPurchaseCancelledByUser:(NSString *)productIdentifier;
- (void)bankerFailedRestorePurchases;

@optional
- (void)bankerDidRestorePurchases:(SKPaymentQueue *)queue;
- (void)bankerCanNotMakePurchases;
- (void)bankerContentDownloadComplete:(SKDownload *)download;
- (void)bankerContentDownloading:(SKDownload *)download;

@end


@interface IAPHelper: NSObject
<
SKPaymentTransactionObserver,
SKProductsRequestDelegate
>

+ (IAPHelper *)sharedInstance;

@property (weak, nonatomic) UIViewController <IAPHelperDelegate> *delegate;
@property (strong, nonatomic) SKProductsRequest *productsRequest;

+ (BOOL)isPurchased:(NSString *)productId;
+ (void)markAsPurchased:(NSString *)productId;

- (void)fetchProducts:(NSArray *)productIdentifiers;
- (void)purchaseItem:(SKProduct *)product;
- (void)restorePurchases;
- (BOOL)canMakePurchases;

@end


@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end

@implementation SKProduct (LocalizedPrice)

- (NSString *)localizedPrice {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.price];
    return formattedString;
}

@end
