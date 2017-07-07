//
//  IAPViewController.swift
//  Carbon
//
//  Created by Mobile on 9/22/16.
//  Copyright © 2016 Robert. All rights reserved.
//

import UIKit
import MBProgressHUD

class IAPViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, IAPHelperDelegate, IAPItemTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    var iapItems: [IAPItem]!
    var iapHelper: IAPHelper!
    var iapItemsArray: [SKProduct]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initIAPItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func closeBtnTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func restorePurchaseBtnTapped(_ sender: AnyObject) {
        if iapHelper.canMakePurchases() {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            iapHelper.restorePurchases()
        }
    }
    
    // MARK: - UITableViewDatasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return iapItems!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.size.width
        let height = (screenWidth / 2 - 10) * 182.0 / 150.0 + 10
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "IAPItem", for: indexPath) as! IAPItemTableViewCell
        
        let iapItem = iapItems?[indexPath.row]
        cell.lblTitle.text = iapItem?.itemTitle
        cell.tvDescription.text = iapItem?.itemDescription
        cell.imvPhoto.image = UIImage(named: (iapItem?.itemImageName!)!)
        
        cell.indexPath = indexPath
        cell.delegate = self
        
        if (iapItem?.itemPrice?.isEmpty)! {
            cell.btnPurchase.isHidden = true
        } else {
            cell.btnPurchase.isHidden = false
        }
        
        if IAPHelper.isPurchased(iapItem?.itemIAPKey) {
            cell.btnPurchase.setBackgroundImage(UIImage(named: "CarbonPurchased"), for: UIControlState.normal)
            cell.btnPurchase.setTitle(NSLocalizedString("PURCHASED", comment: ""), for: UIControlState.normal)
            cell.lblPrice.text = ""
        } else {
            cell.btnPurchase.setBackgroundImage(UIImage(named: "CarbonPurchase"), for: UIControlState.normal)
            cell.btnPurchase.setTitle("", for: UIControlState.normal)
            cell.lblPrice.text = iapItem?.itemPrice
        }
        
        return cell
    }
    
    // MARK: - IAPItemTableViewCellDelegate
    func purchase(_ indexPath: IndexPath) {
        let iapItem = iapItems?[indexPath.row]
        
        if !IAPHelper.isPurchased(iapItem?.itemIAPKey) && iapHelper.canMakePurchases() {
            for product in iapItemsArray {
                if product.productIdentifier == iapItem?.itemIAPKey {
                    iapHelper.purchaseItem(product)
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                    return
                }
            }
        }
    }
    
    // MARK: - Custom Functions
    func initIAPItems() {
        let iapItem1 = IAPItem()
        iapItem1.itemImageName = "Splash"
        iapItem1.itemIAPKey = IAPKeyPack1
        iapItem1.itemTitle = ""
        iapItem1.itemDescription = ""
        iapItem1.itemPrice = ""
        iapItems = [iapItem1]
        
        // In app purchase
        iapItemsArray = []
        iapHelper = IAPHelper()
        iapHelper?.delegate = self
        
        var iapKeys = [String]()
        for iapItem in iapItems! {
            iapKeys.append(iapItem.itemIAPKey!)
        }
        iapHelper?.fetchProducts(iapKeys)
    }
    
    // MARK: - IAPHelper Delegate
    func bankerFailedToConnect() {
        
    }
    
    func bankerNoProductsFound() {
        
    }
    
    func bankerFoundProducts(_ products: [Any]!) {
        iapItemsArray = products as! [SKProduct]!
        for product in iapItemsArray {
            for iapItem in iapItems {
                if product.productIdentifier == iapItem.itemIAPKey {
                    iapItem.itemPrice = product.localizedPrice
                    iapItem.itemTitle = product.localizedTitle
                    iapItem.itemDescription = product.localizedDescription
                    break;
                }
            }
        }
        self.tableView.reloadData()
    }
    
    func bankerFoundInvalidProducts(_ products: [Any]!) {
        
    }
    
    func bankerProvideContent(_ paymentTransaction: SKPaymentTransaction!) {
        
    }
    
    func bankerPurchaseComplete(_ paymentTransaction: SKPaymentTransaction!) {
        MBProgressHUD.hide(for: self.view, animated: true)
        
        let prodId = paymentTransaction.payment.productIdentifier
        IAPHelper.mark(asPurchased: prodId)
        self.tableView.reloadData()
    }
    
    func bankerPurchaseFailed(_ productIdentifier: String!, withError errorDescription: String!) {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func bankerPurchaseCancelled(byUser productIdentifier: String!) {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func bankerFailedRestorePurchases() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func bankerDidRestorePurchases(_ queue: SKPaymentQueue!) {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
}
