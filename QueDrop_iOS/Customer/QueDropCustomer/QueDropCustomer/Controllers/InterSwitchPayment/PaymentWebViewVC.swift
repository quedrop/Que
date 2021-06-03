//
//  PaymentWebViewVC.swift
//  QueDropCustomer
//
//  Created by C100-174 on 02/09/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit
import WebKit

@objc protocol PaymentWebViewVCDelegate:NSObjectProtocol{
    func paymentResultDidFinish(dic : [String:Any])
}

class PaymentWebViewVC: UIViewController {
    //CONSTANTS
    
    
    //VARIABLES
    var delegate:PaymentWebViewVCDelegate?
    var orderId = 0
    var tip : Float = 0
    var amount : Float = 0
    var dicResponse : [String : Any] = [:]
    
    //IBOUTLETS
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    //MARK:- VC LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        let link = URL(string:"\(INITIATE_PAYMENT)?orderId=\(orderId)&userId=\(USER_OBJ?.userId ?? 0)&tip=\(tip)&TestData=\(IS_TESTDATA)")!
        let request = URLRequest(url: link)
        webView.load(request)
    }
    
    //MARK:- BUTTON ACTIONS
    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
      
}
 //MARK:- WEBVIEW DELEGATE METHODS
extension PaymentWebViewVC : WKNavigationDelegate {
    private func webView(webView: WKWebView!, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError!) {
        showAlert(title: "Error", message: error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showAlert(title: "Error", message: error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finish");
        print("HOST: \(webView.url?.host ?? "")")
        
        let path = "\(webView.url!.scheme ?? "http")://"  + webView.url!.host! + webView.url!.path
        if(path.lowercased() == PAYMENT_SUCCESS_PAGE.lowercased()) {
            dicResponse = (webView.url?.queryDictionary())!
             print(dicResponse)
            if (self.delegate?.responds(to: #selector(self.delegate?.paymentResultDidFinish(dic:))))! {
                self.delegate?.paymentResultDidFinish(dic: dicResponse)
            }
            self.navigationController?.popViewController(animated: true)
           
        }
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        print("Content Process");
    }
    
   /* func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
        //print("Navigation Action : \(navigationAction.navigationType)")
       if (navigationAction.navigationType == WKNavigationType.LinkActivated && !navigationAction.request.URL.host!.lowercaseString.hasPrefix("www.appcoda.com")) {
           UIApplication.sharedApplication().openURL(navigationAction.request.URL)
            decisionHandler(WKNavigationActionPolicy.cancel)
        } else {
            decisionHandler(WKNavigationActionPolicy.allow)
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }*/
    
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

extension URL {
    func queryDictionary() -> [String:Any] {
        let components = self.query?.components(separatedBy: "&")
        var dictionary = [String:Any]()

        for pairs in components ?? [] {
            let pair = pairs.components(separatedBy: "=")
            if pair.count == 2 {
                dictionary[pair[0]] = pair[1]
            }
        }

        return dictionary
    }
}
