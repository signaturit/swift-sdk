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

    @IBAction func send() {
        _send()
    }

    internal func _send() {
        button.alpha            = 0
        activityIndicator.alpha = 1
        webView.alpha           = 0.5

        let client: Signaturit = Signaturit(accessToken: "NGFhOWE3MjAwNThlMjY5M2M1MzQxZjNlOTY1M2U0MzhmNTlmMWE1NzIyMTdmMGQwYTkzZDBjOTg4YzZlMGY1NA", production: false)

//        client.getSignature(signatureId: "635f2189-91ea-11e6-868f-0680f0041fef").responseJSON { response in
//            print("signatures - getSignature")
//            print(response.result.value!)
//        }

//        client.getSignatures(limit: 2, offset: 1).responseJSON { response in
//            print("signatures - getSignatures with limit 2 & offset 1")
//            print(response.result.value!)
//        }

//        client.getSignatures(conditions: ["status": "completed"] as Dictionary<String, AnyObject>).responseJSON { response in
//            print("signatures - getSignatures with condition status = completed")
//            print(response.result.value!)
//        }

//        client.getSignatures().responseJSON { response in
//            print("signatures - getSignatures")
//            print(response.result.value!)
//        }

//        client.countSignatures().responseJSON { response in
//            print("signatures - countSignatures")
//            print(response.result.value!)
//        }

//        client.countSignatures(conditions: ["status": "completed"] as Dictionary<String, AnyObject>).responseJSON { response in
//            print("signatures - countSignatures with conditions")
//            print(response.result.value!)
//        }
        
//        client.downloadAuditTrail(signatureId: "635f2189-91ea-11e6-868f-0680f0041fef", documentId: "637d60e1-91ea-11e6-868f-0680f0041fef", path: DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)).responseJSON { response in
//            print("signatures - downloadAuditTrail")
//        }

//        client.downloadSignedDocument(signatureId: "635f2189-91ea-11e6-868f-0680f0041fef", documentId: "637d60e1-91ea-11e6-868f-0680f0041fef", path: DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)).responseJSON { response in
//            print("signatures - downloadSignedDocument")
//        }

        client.createSignature(
            files: [Bundle.main.url(forResource: "Document", withExtension: "pdf")!],
            recipients: [["email": "api@signaturit.com", "fullname": "Signaturit"]],
            params: ["delivery_type": "url"] as Dictionary<String, AnyObject>,
            successHandler: { response in
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.activityIndicator.alpha = 0
                    self.label.alpha             = 1
                    self.webView.alpha           = 1
                })

                let signature = JSON(response.result.value!)
                let url       = signature["url"].stringValue

                self.webView.loadRequest(
                    URLRequest(
                        url: URL(string: url)!
                    )
                )
            }
        )

//        client.cancelSignature(signatureId: "8b935300-f622-11e7-aa80-0620c73c8b3c").responseJSON { response in
//            print("signatures - cancelSignature")
//            print(response.result.value!)
//        }

//        client.sendSignatureReminder(signatureId: "8b935300-f622-11e7-aa80-0620c73c8b3c").responseJSON { response in
//            print("signatures - sendSignatureReminder")
//            print(response.result.value!)
//        }
    }
}

