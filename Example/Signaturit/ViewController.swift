//
//  ViewController.swift
//  Signaturit
//
//  Created by Signaturit on 10/13/2015.
//  Copyright (c) 2015 Signaturit. All rights reserved.
//

import UIKit
import Signaturit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func openSignaturit(sender: AnyObject) {
        send()
    }

    internal func send() {
        button.alpha            = 0
        activityIndicator.alpha = 1
        webView.alpha           = 0.5

        let uploadPDF  = NSBundle.mainBundle().URLForResource("Document", withExtension: "pdf")
        let recipients = [["email": "api@signaturit.com", "fullname": "Signaturit"]]
        let params     = ["delivery_type": "url"]

        let client: Signaturit = Signaturit(accessToken: "NGFhOWE3MjAwNThlMjY5M2M1MzQxZjNlOTY1M2U0MzhmNTlmMWE1NzIyMTdmMGQwYTkzZDBjOTg4YzZlMGY1NA", production: false)
/*
        client.getSignatureDocument("df21653b-c080-11e5-bf87-0a0f5351f1ad", documentId: "df4e9c2f-c080-11e5-bf87-0a0f5351f1ad").responseJSON { response in
            print(response)
        }
*/
/*
        client.createSignature([uploadPDF!], recipients: recipients, params: params, successHandler: { response in
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.activityIndicator.alpha = 0
                self.label.alpha             = 1
                self.webView.alpha           = 1
            })

            let signature = JSON(response.result.value!)
            let url       = signature["url"].stringValue

            self.webView.loadRequest(
                NSURLRequest(
                    URL: NSURL(string: url)!
                )
            )
        })
*/
    }
}

