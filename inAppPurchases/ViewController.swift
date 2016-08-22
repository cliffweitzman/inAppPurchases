//
//  ViewController.swift
//  inAppPurchases
//
//  Created by Cliff Weitzman on 8/19/16.
//  Copyright © 2016 Cliff Weitzman. All rights reserved.
//


import UIKit
import StoreKit

class ViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver{
    
    //Variables
        //Change this to the start of your own bundleID (the full bundelID of this project is currently com.cliffweitzman.inAppPurchase)
    var identifire = "com.cliffweitzman"
    
    @IBOutlet var adLabel: UILabel!
    @IBOutlet var coinLabel: UILabel!
    
    @IBOutlet var outRemoveAds: UIButton!
    @IBOutlet var outAddCoins: UIButton!
    var coins = 50
    
    //Varialbe to keep instance of product
    var p = SKProduct()
    
    //Products list, which will be populated from apple's server at viewDidLoad
    var list = [SKProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set if buttons are clickable
        outRemoveAds.isEnabled = false
        outAddCoins.isEnabled = false
        
        //Set up for IAP (In App Purchase) connection with app store
        if(SKPaymentQueue.canMakePayments()) {
            //Put the available products in the Set
            let productID:NSSet = NSSet(objects: "\(identifire).addcoins", "\(identifire).removeads")
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            
            request.delegate = self
            request.start()
            
            print("IAP is enabled, loading")
            
            //Check at the beginnig of every sessions if purchases were already made. If so, automaticaly restore them. Comment out as needed for testing.
            //            SKPaymentQueue.defaultQueue().addTransactionObserver(self)
            //            SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
            
        } else {
            print("please enable IAPS")
        }
    }
    
    //Gets called from viewDidLoad when the request variable is assigned. Pulls down product information from apple server.
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("product request")
        let myProduct = response.products
        
        for product in myProduct {
            //printing for clarity
            print(product.productIdentifier)
            print(product.localizedTitle)
            print(product.localizedDescription)
            print(product.price)
            
            //Important, this is where the product instances that we got from the Apple server are added to our list and can be accessed when a purchase is attempted:
            list.append(product)
            print("product added")
        }
        
        //Sets buttons to be clickable now that we have instances of our products to buy
        outRemoveAds.isEnabled = true
        outAddCoins.isEnabled = true
    }
    
    
    //Non-Consumable purchase
    @IBAction func removeAds(_ sender: UIButton) {
        //Get relevant product from the list of available purchases
        for product in list {
            let prodID = product.productIdentifier
            if(prodID == "\(identifire).removeads") {
                p = product
                buyProduct()
                //once we find our product there is no reason to keep ittorating through the list so we break
                break
            }
        }
    }
    
    
    //Consumable purchase
    @IBAction func addCoins(_ sender: UIButton) {
        for product in list {
            let prodID = product.productIdentifier
            if(prodID == "\(identifire).addcoins") {
                p = product
                buyProduct()
                break
            }
        }
    }
    
    func buyProduct() {
        let payment = SKPayment(product: p)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment as SKPayment)
        print("\(p.productIdentifier) successfully purchased")
    }
    
    
    //Payment Queue - where we make a payment
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
            print(trans.error)
            
            if trans.transactionState == .purchased {
                print("Purchase successful. Unlock IAP here.")
                let prodID = p.productIdentifier as String
                
                if prodID == "\(identifire).removeads" {
                    print("removing ads")
                    adLabel.removeFromSuperview()
                    
                } else if prodID == "\(identifire).addcoins" {
                    print("adding coins")
                    coins = coins + 50
                    coinLabel.text = "\(coins)"
                }
                
                queue.finishTransaction(trans)
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]){
        print("remove trans")
    }
    
    func finishTransaction(_ trans:SKPaymentTransaction){
        print("finish trans")
        SKPaymentQueue.default().finishTransaction(trans)
    }
    
    
    
    //Restore purchases - required for app sotre approval
    @IBAction func RestorePurchases(_ sender: UIButton) {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("transactions restored")
        
        for transaction in queue.transactions {
            let t: SKPaymentTransaction = transaction
            
            let prodID = t.payment.productIdentifier as String
            
            if prodID == "\(identifire).removeads" {
                print("removing ads")
                adLabel.removeFromSuperview()
                
            } else if prodID == "\(identifire).addcoins" {
                print("adding coins")
                coins = coins + 50
                coinLabel.text = "\(coins)"
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

