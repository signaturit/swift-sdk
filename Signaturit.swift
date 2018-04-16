import Alamofire

open class Signaturit {

    // MARK: - Configuration variables

    // Signaturit's production API URL
    private let PROD_BASE_URL = "https://api.signaturit.com"

    // Signaturit's sandbox API URL
    private let SANDBOX_BASE_URL = "https://api.sandbox.signaturit.com"

    // MARK: - Instance variables

    // Endpoint URL
    private var url: String;

    // Headers to send in every request
    private var headers: [String: String]

    // MARK: - Constructor

    /// Constructor
    public init(accessToken: String, production: Bool? = false) {
        self.url = production == nil || production == false ? SANDBOX_BASE_URL : PROD_BASE_URL

        self.headers = [
            "Authorization": "Bearer " + accessToken,
            "user-agent": "signaturit-swift-sdk 1.2.1"
        ]
    }

    // MARK: - Signature

    /// Get signature information.
    open func getSignature(signatureId: String) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/signatures/\(signatureId).json", headers: self.headers)
    }

    /// Get signatures information.
    open func getSignatures(limit: Int, offset: Int, conditions: [String: AnyObject]? = [String: AnyObject]()) -> DataRequest {
        var conditions = conditions
        conditions!["limit"]  = limit as AnyObject
        conditions!["offset"] = offset as AnyObject

        return getSignatures(conditions: conditions!)
    }

    /// Get signatures information.
    open func getSignatures(conditions: [String: AnyObject]? = [String: AnyObject]()) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/signatures.json", method: .get, parameters: conditions, headers: self.headers)
    }

    /// Get signatures count.
    open func countSignatures(conditions: [String: AnyObject]? = [String: AnyObject]()) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/signatures/count.json", method: .get, parameters: conditions, headers: self.headers)
    }

    /// Download the audit trail.
    open func downloadAuditTrail(signatureId: String, documentId: String, path: DownloadRequest.DownloadFileDestination?) -> DownloadRequest {
        return Alamofire.download("\(self.url)/v3/signatures/\(signatureId)/documents/\(documentId)/download/doc_proof", headers: self.headers, to: path)
    }

    /// Download the signed document.
    open func downloadSignedDocument(signatureId: String, documentId: String, path: DownloadRequest.DownloadFileDestination?) -> DownloadRequest {
        return Alamofire.download("\(self.url)/v3/signatures/\(signatureId)/documents/\(documentId)/download/signed", headers: self.headers, to: path)
    }

    /// Create a signature request.
    open func createSignature(files: [URL], recipients: [[String : Any]], params: [String : AnyObject]? = [String: AnyObject](), successHandler: @escaping (DataResponse<Any>) -> Void) {
        return Alamofire.upload(multipartFormData: { multipartFormData in
            Signaturit.parseTo(multipartData: multipartFormData, currentKey: "recipients", currentValue: recipients)

            for file in files {
                multipartFormData.append(
                    try! Data(contentsOf: file),
                    withName: "files[]",
                    fileName: file.lastPathComponent,
                    mimeType: "application/octet-stream"
                )
            }
            
            if params != nil {
                for (field, value) in params! {
                    multipartFormData.append(
                        value.data(using: String.Encoding.utf8.rawValue)!,
                        withName: String(field)
                    )
                }
            }
        }, to: "\(self.url)/v3/signatures.json", headers: self.headers, encodingCompletion: { encodingResult in
            switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: successHandler)

                case .failure(let encodingError):
                    print(encodingError)
            }
        })
    }

    /// Cancel a signature request.
    open func cancelSignature(signatureId: String) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/signatures/\(signatureId)/cancel.json", method: .patch, headers: self.headers)
    }

    /// Send signature reminder.
    open func sendSignatureReminder(signatureId: String) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/signatures/\(signatureId)/reminder.json", method: .post, headers: self.headers)
    }

    // MARK: - Branding

    /// Create a branding.
    open func createBranding(params: [String: AnyObject]? = [String: AnyObject]()) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/brandings.json", method: .post, parameters: params, headers: self.headers)
    }

    /// Update a branding.
    open func updateBranding(brandingId: String, params: [String: AnyObject]? = [String: AnyObject]()) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/brandings/\(brandingId).json", method: .patch, parameters: params, headers: self.headers)
    }

    // MARK: - Template

    /// Get templates
    open func getTemplates() -> DataRequest {
        return Alamofire.request("\(self.url)/v3/templates.json", headers: self.headers)
    }

    // MARK: - Emails

    /// Get emails information.
    open func getEmails(limit: Int?, offset: Int?, conditions: [String: AnyObject]? = [String: AnyObject]()) -> DataRequest {
        var conditions = conditions
        conditions!["limit"]  = limit as AnyObject
        conditions!["offset"] = offset as AnyObject

        return getEmails(conditions: conditions!)
    }

    /// Get emails information.
    open func getEmails(conditions: [String: AnyObject] = [String: AnyObject]()) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/emails.json", parameters: conditions, headers: self.headers)
    }

    /// Count emails.
    open func countEmails(conditions: [String: AnyObject]? = [String: AnyObject]()) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/emails/count.json", parameters: conditions, headers: self.headers)
    }

    /// Get email information.
    open func getEmail(emailId: String) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/emails/\(emailId).json", headers: self.headers)
    }

    /// Get email certificates information.
    open func getEmailCertificates(emailId: String) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/emails/\(emailId)/certificates.json", headers: self.headers)
    }

    /// Get email certificate information.
    open func getEmailCertificate(emailId: String, certificateId: String) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/emails/\(emailId)/certificates/\(certificateId).json", headers: self.headers)
    }

    /// Create a email.
    open func createEmail(files: [URL], recipients: [[String : Any]], subject: String?, body: String?, params: [String: AnyObject]? = [String: AnyObject](), successHandler: @escaping (DataResponse<Any>) -> Void) {
        return Alamofire.upload(multipartFormData: { multipartFormData in
            if subject != nil {
                multipartFormData.append(
                    subject!.data(using: String.Encoding.utf8)!,
                    withName: "subject"
                )
            }

            if body != nil {
                multipartFormData.append(
                    body!.data(using: String.Encoding.utf8)!,
                    withName: "body"
                )
            }

            Signaturit.parseTo(multipartData: multipartFormData, currentKey: "recipients", currentValue: recipients)

            for file in files {
                multipartFormData.append(
                    try! Data(contentsOf: file),
                    withName: "files[]",
                    fileName: file.lastPathComponent,
                    mimeType: "application/octet-stream"
                )
            }

            if params != nil {
                for (field, value) in params! {
                    multipartFormData.append(
                        value.data(using: String.Encoding.utf8.rawValue)!,
                        withName: String(field)
                    )
                }
            }
        }, to: "\(self.url)/v3/emails.json", headers: self.headers, encodingCompletion: { encodingResult in
            switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: successHandler)

                case .failure(let encodingError):
                    print(encodingError)
            }
        })
    }

    /// Download the audit trail.
    open func downloadEmailAuditTrail(emailId: String, certificateId: String, path: DownloadRequest.DownloadFileDestination?) -> DownloadRequest {
        return Alamofire.download("\(self.url)/v3/emails/\(emailId)/certificates/\(certificateId)/download/audit_trail", headers: self.headers, to: path)
    }

    /// Download the email document.
    open func downloadEmailDocument(emailId: String, certificateId: String, path: DownloadRequest.DownloadFileDestination?) -> DownloadRequest {
        return Alamofire.download("\(self.url)/v3/emails/\(emailId)/certificates/\(certificateId)/download/original", headers: self.headers, to: path)
    }

    // MARK: - SMS

    /// Get sms information.
    open func getSMS(limit: Int?, offset: Int?, conditions: [String: AnyObject]? = [String: AnyObject]()) -> DataRequest {
        var conditions = conditions
        conditions!["limit"]  = limit as AnyObject
        conditions!["offset"] = offset as AnyObject
        
        return getSMS(conditions: conditions!)
    }
    
    /// Get sms information.
    open func getSMS(conditions: [String: AnyObject] = [String: AnyObject]()) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/sms.json", parameters: conditions, headers: self.headers)
    }
    
    /// Count sms.
    open func countSMS(conditions: [String: AnyObject]? = [String: AnyObject]()) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/sms/count.json", parameters: conditions, headers: self.headers)
    }
    
    /// Get sms information.
    open func getSingleSMS(smsId: String) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/sms/\(smsId).json", method: .get, headers: self.headers)
    }
    
    /// Create an sms.
    open func createSMS(files: [URL], recipients: [[String : Any]], body: String?, params: [String: AnyObject]? = [String: AnyObject](), successHandler: @escaping (DataResponse<Any>) -> Void) {
        return Alamofire.upload(multipartFormData: { multipartFormData in
            if body != nil {
                multipartFormData.append(
                    body!.data(using: String.Encoding.utf8)!,
                    withName: "body"
                )
            }

            Signaturit.parseTo(multipartData: multipartFormData, currentKey: "recipients", currentValue: recipients)

            for file in files {
                multipartFormData.append(
                    try! Data(contentsOf: file),
                    withName: "files[]",
                    fileName: file.lastPathComponent,
                    mimeType: "application/octet-stream"
                )
            }

            if params != nil {
                for (field, value) in params! {
                    multipartFormData.append(
                        value.data(using: String.Encoding.utf8.rawValue)!,
                        withName: String(field)
                    )
                }
            }
        }, to: "\(self.url)/v3/sms.json", headers: self.headers, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: successHandler)
                    
                case .failure(let encodingError):
                    print(encodingError)
                }
        })
    }
    
    /// Download the audit trail.
    open func downloadSMSAuditTrail(smsId: String, certificateId: String, path: DownloadRequest.DownloadFileDestination?) -> DownloadRequest {
        return Alamofire.download("\(self.url)/v3/sms/\(smsId)/certificates/\(certificateId)/download/audit_trail", headers: self.headers, to: path)
    }

    // MARK: - Team

    /// Get users information.
    open func getUsers(limit: Int?, offset: Int?, conditions: [String: AnyObject]? = [String: AnyObject]()) -> DataRequest {
        var conditions = conditions
        conditions!["limit"]  = limit as AnyObject
        conditions!["offset"] = offset as AnyObject
        
        return getUsers(conditions: conditions!)
    }

    /// Get users information.
    open func getUsers(conditions: [String: AnyObject] = [String: AnyObject]()) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/team/users.json", parameters: conditions, headers: self.headers)
    }

    /// Get seats information.
    open func getSeats(limit: Int?, offset: Int?, conditions: [String: AnyObject]? = [String: AnyObject]()) -> DataRequest {
        var conditions = conditions
        conditions!["limit"]  = limit as AnyObject
        conditions!["offset"] = offset as AnyObject
        
        return getSeats(conditions: conditions!)
    }
    
    /// Get seats information.
    open func getSeats(conditions: [String: AnyObject] = [String: AnyObject]()) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/team/seats.json", parameters: conditions, headers: self.headers)
    }

    /// Get user information.
    open func getUser(userId: String) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/team/users/\(userId).json", method: .get, headers: self.headers)
    }

    /// Invite a user.
    open func inviteUser(email: String, role: String) -> DataRequest {
        let params: [String: String] = [
            "email": email,
            "role": role
        ]

        return Alamofire.request("\(self.url)/v3/team/users.json", method: .post, parameters: params, headers: self.headers)
    }
    
    /// Update user role.
    open func changeUserRole(userId: String, role: String) -> DataRequest {
        let params: [String: String] = ["role": role]

        return Alamofire.request("\(self.url)/v3/team/users/\(userId).json", method: .patch, parameters: params, headers: self.headers)
    }

    /// Remove a user from the team.
    open func removeUser(userId: String) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/team/users/\(userId).json", method: .delete, headers: self.headers)
    }

    /// Remove a seat from the team.
    open func removeSeat(seatId: String) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/team/seats/\(seatId).json", method: .delete, headers: self.headers)
    }

    // MARK: - Groups

    /// Get groups information.
    open func getGroups(limit: Int?, offset: Int?, conditions: [String: AnyObject]? = [String: AnyObject]()) -> DataRequest {
        var conditions = conditions
        conditions!["limit"]  = limit as AnyObject
        conditions!["offset"] = offset as AnyObject
        
        return getGroups(conditions: conditions!)
    }
    
    /// Get groups information.
    open func getGroups(conditions: [String: AnyObject] = [String: AnyObject]()) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/team/groups.json", parameters: conditions, headers: self.headers)
    }

    /// Get group information.
    open func getGroup(groupId: String) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/team/groups/\(groupId).json", method: .get, headers: self.headers)
    }

    /// Create a group.
    open func createGroup(name: String) -> DataRequest {
        let params: [String: String] = [
            "name": name
        ]
        
        return Alamofire.request("\(self.url)/v3/team/groups.json", method: .post, parameters: params, headers: self.headers)
    }

    /// Update a group.
    open func updateGroup(groupId: String, name: String) -> DataRequest {
        let params: [String: String] = ["name": name]
        
        return Alamofire.request("\(self.url)/v3/team/groups/\(groupId).json", method: .patch, parameters: params, headers: self.headers)
    }

    /// Remove a group.
    open func deleteGroup(groupId: String) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/team/groups/\(groupId).json", method: .delete, headers: self.headers)
    }

    /// Add a manager to a group.
    open func addManagerToGroup(groupId: String, userId: String) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/team/groups/\(groupId)/managers/\(userId).json", method: .post, headers: self.headers)
    }

    /// Add a member to a group.
    open func addMemberToGroup(groupId: String, userId: String) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/team/groups/\(groupId)/members/\(userId).json", method: .post, headers: self.headers)
    }

    /// Remove a manager to a group.
    open func removeManagerFromGroup(groupId: String, userId: String) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/team/groups/\(groupId)/managers/\(userId).json", method: .delete, headers: self.headers)
    }
    
    /// Remove a member to a group.
    open func removeMemberFromGroup(groupId: String, userId: String) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/team/groups/\(groupId)/members/\(userId).json", method: .delete, headers: self.headers)
    }

    // MARK: - Contacts

    /// Get contacts information.
    open func getContacts(limit: Int?, offset: Int?, conditions: [String: AnyObject]? = [String: AnyObject]()) -> DataRequest {
        var conditions = conditions
        conditions!["limit"]  = limit as AnyObject
        conditions!["offset"] = offset as AnyObject
        
        return getContacts(conditions: conditions!)
    }
    
    /// Get contacts information.
    open func getContacts(conditions: [String: AnyObject] = [String: AnyObject]()) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/contacts.json", parameters: conditions, headers: self.headers)
    }
    
    /// Get contact information.
    open func getContact(contactId: String) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/contacts/\(contactId).json", method: .get, headers: self.headers)
    }
    
    /// Create a contact.
    open func createContact(email: String, name: String) -> DataRequest {
        let params: [String: String] = [
            "email": email,
            "name": name
        ]
        
        return Alamofire.request("\(self.url)/v3/contacts.json", method: .post, parameters: params, headers: self.headers)
    }
    
    /// Update a contact.
    open func updateContact(contactId: String, email: String, name: String) -> DataRequest {
        let params: [String: String] = [
            "email": email,
            "name": name
        ]
        
        return Alamofire.request("\(self.url)/v3/contacts/\(contactId).json", method: .patch, parameters: params, headers: self.headers)
    }
    
    /// Remove a contact.
    open func deleteContact(contactId: String) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/contacts/\(contactId).json", method: .delete, headers: self.headers)
    }

    // MARK: - Subscriptions
    
    /// Get subscriptions information.
    open func getSubscriptions(limit: Int?, offset: Int?, conditions: [String: AnyObject]? = [String: AnyObject]()) -> DataRequest {
        var conditions = conditions
        conditions!["limit"]  = limit as AnyObject
        conditions!["offset"] = offset as AnyObject
        
        return getSubscriptions(conditions: conditions!)
    }
    
    /// Get subscriptions information.
    open func getSubscriptions(conditions: [String: AnyObject] = [String: AnyObject]()) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/subscriptions.json", parameters: conditions, headers: self.headers)
    }

    /// Get subscriptions count.
    open func countSubscriptions(conditions: [String: AnyObject]? = [String: AnyObject]()) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/subscriptions/count.json", parameters: conditions, headers: self.headers)
    }

    /// Get subscription information.
    open func getSubscription(subscriptionId: String) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/subscriptions/\(subscriptionId).json", method: .get, headers: self.headers)
    }
    
    /// Create a subscription.
    open func createSubscription(url: String, events: [String]) -> DataRequest {
        let params: [String: AnyObject] = [
            "url": url as AnyObject,
            "events": events as AnyObject
        ]
        
        return Alamofire.request("\(self.url)/v3/subscriptions.json", method: .post, parameters: params, headers: self.headers)
    }
    
    /// Update a subscription.
    open func updateSubscription(subscriptionId: String, url: String, events: [String]) -> DataRequest {
        let params: [String: AnyObject] = [
            "url": url as AnyObject,
            "events": events as AnyObject
        ]
        
        return Alamofire.request("\(self.url)/v3/subscriptions/\(subscriptionId).json", method: .patch, parameters: params, headers: self.headers)
    }
    
    /// Remove a subscription.
    open func deleteSubscription(subscriptionId: String) -> DataRequest {
        return Alamofire.request("\(self.url)/v3/subscriptions/\(subscriptionId).json", method: .delete, headers: self.headers)
    }
}

extension Signaturit {
    // inout
    public static func parseTo(multipartData: MultipartFormData, currentKey: String, currentValue: Any) {
        if let arrayAny: [Any] = currentValue as? [Any] {
            for (index, element) in arrayAny.enumerated() {
                self.parseTo(multipartData: multipartData, currentKey: currentKey + "[\(index)]", currentValue: element)
            }
        } else if let dicAny: [String: Any] = currentValue as? [String: Any] {
            for (field, value) in dicAny {
                self.parseTo(multipartData: multipartData, currentKey: currentKey + "[\(field)]", currentValue: value)
            }
        } else {
            if let data: Data = "\(currentValue)".data(using: String.Encoding.utf8) {
                multipartData.append(
                    data,
                    withName: currentKey // "recipients[\(index)][\(field)]"
                )
            }
        }
    }
}
