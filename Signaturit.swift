import Alamofire

public class Signaturit {

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
            "user-agent": "signaturit-swift-sdk 1.1.0"
        ]

    }

    // MARK: - Signature

    /// Get signature information.
    public func getSignature(signatureId: String) -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/signatures/\(signatureId).json", headers: self.headers)
    }

    /// Get signatures information.
    public func getSignatures(limit: Int?, offset: Int?, var conditions: [String: AnyObject]? = [String: AnyObject]()) -> Request {
        conditions!["limit"]  = limit
        conditions!["offset"] = offset

        return getSignatures(conditions!)
    }

    /// Get signatures information.
    public func getSignatures(conditions: [String: AnyObject]? = [String: AnyObject]()) -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/signatures.json", headers: self.headers, parameters: conditions)
    }

    /// Get signatures count.
    public func countSignatures(conditions: [String: AnyObject]? = [String: AnyObject]()) -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/signatures/count.json", headers: self.headers, parameters: conditions)
    }

    /// Download the audit trail.
    public func downloadAuditTrail(signatureId: String, documentId: String, path: Request.DownloadFileDestination) -> Request {
        return Alamofire.download(Alamofire.Method.GET, self.url + "/v3/signatures/" + signatureId + "/documents/" + documentId + "/download/doc_proof", headers: self.headers, destination: path)
    }

    /// Download the signed document.
    public func downloadSignedDocument(signatureId: String, documentId: String, path: Request.DownloadFileDestination) -> Request {
        return Alamofire.download(Alamofire.Method.GET, self.url + "/v3/signatures/" + signatureId + "/documents/" + documentId + "/download/signed", headers: self.headers, destination: path)
    }

    /// Create a signature request.
    public func createSignature(files: [NSURL], recipients: [Dictionary<String, String>], params: Dictionary<String, AnyObject>? = [String: AnyObject](), successHandler: Response<AnyObject, NSError> -> Void) {
        return Alamofire.upload(.POST, self.url + "/v3/signatures.json", headers: self.headers, multipartFormData: { multipartFormData in
            for (index, recipient) in recipients.enumerate() {
                for (field, value) in recipient {
                    multipartFormData.appendBodyPart(
                        data: value.dataUsingEncoding(NSUTF8StringEncoding)!,
                        name: "recipients[\(index)][\(field)]"
                    )
                }
            }

            for file in files {
                multipartFormData.appendBodyPart(
                    fileURL: file,
                    name: "files[]"
                )
            }

            if params != nil {
                for (field, value) in params! {
                    multipartFormData.appendBodyPart(
                        data: value.dataUsingEncoding(NSUTF8StringEncoding)!,
                        name: String(field)
                    )
                }
            }
        }, encodingCompletion: { encodingResult in
            switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON(completionHandler: successHandler)

                case .Failure(let encodingError):
                    print(encodingError)
            }
        })
    }

    /// Cancel a signature request.
    public func cancelSignature(signatureId: String) -> Request {
        return Alamofire.request(Alamofire.Method.PATCH, "\(self.url)/v3/signatures/\(signatureId)/cancel.json", headers: self.headers)
    }

    /// Send signature reminder.
    public func sendSignatureReminder(signatureId: String) -> Request {
        return Alamofire.request(Alamofire.Method.POST, "\(self.url)/v3/signatures/\(signatureId)/reminder.json", headers: self.headers)
    }

    // MARK: - Branding

    /// Create a branding.
    public func createBranding(params: [String: AnyObject]? = [String: AnyObject]()) -> Request {
        return Alamofire.request(Alamofire.Method.POST, "\(self.url)/v3/brandings.json", headers: self.headers, parameters: params)
    }

    /// Update a branding.
    public func updateBranding(brandingId: String, params: [String: AnyObject]? = [String: AnyObject]()) -> Request {
        return Alamofire.request(Alamofire.Method.PATCH, "\(self.url)/v3/brandings/\(brandingId).json", headers: self.headers, parameters: params)
    }

    // MARK: - Template

    /// Get templates
    public func getTemplates() -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/templates.json", headers: self.headers)
    }

    // MARK: - Emails

    /// Get emails information.
    public func getEmails(limit: Int?, offset: Int?, var conditions: [String: AnyObject]? = [String: AnyObject]()) -> Request {
        conditions!["limit"]  = limit
        conditions!["offset"] = offset

        return getEmails(conditions!)
    }

    /// Get emails information.
    public func getEmails(conditions: [String: AnyObject] = [String: AnyObject]()) -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/emails.json", headers: self.headers, parameters: conditions)
    }

    /// Count emails.
    public func countEmails(conditions: [String: AnyObject]? = [String: AnyObject]()) -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/emails/count.json", headers: self.headers, parameters: conditions)
    }

    /// Get email information.
    public func getEmail(emailId: String) -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/emails/\(emailId).json", headers: self.headers)
    }

    /// Get email certificates information.
    public func getEmailCertificates(emailId: String) -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/emails/\(emailId)/certificates.json", headers: self.headers)
    }

    /// Get email certificate information.
    public func getEmailCertificate(emailId: String, certificateId: String) -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/emails/\(emailId)/certificates/\(certificateId).json", headers: self.headers)
    }

    /// Create a email.
    public func createEmail(files: [NSURL], recipients: [Dictionary<String, String>], subject: String?, body: String?, params: [String: AnyObject]? = [String: AnyObject](), successHandler: Response<AnyObject, NSError>? -> Void) {
        return Alamofire.upload(.POST, self.url + "/v3/emails.json", headers: self.headers, multipartFormData: { multipartFormData in
            if subject != nil {
                multipartFormData.appendBodyPart(
                    data: subject!.dataUsingEncoding(NSUTF8StringEncoding)!,
                    name: "subject"
                )
            }

            if body != nil {
                multipartFormData.appendBodyPart(
                    data: body!.dataUsingEncoding(NSUTF8StringEncoding)!,
                    name: "body"
                )
            }

            for (index, recipient) in recipients.enumerate() {
                for (field, value) in recipient {
                    multipartFormData.appendBodyPart(
                        data: value.dataUsingEncoding(NSUTF8StringEncoding)!,
                        name: "recipients[\(index)][\(field)]"
                    )
                }
            }

            for file in files {
                multipartFormData.appendBodyPart(
                    fileURL: file,
                    name: "files[]"
                )
            }

            if params != nil {
                for (field, value) in params! {
                    multipartFormData.appendBodyPart(
                        data: value.dataUsingEncoding(NSUTF8StringEncoding)!,
                        name: String(field)
                    )
                }
            }
        }, encodingCompletion: { encodingResult in
            switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON(completionHandler: successHandler)

                case .Failure(let encodingError):
                    print(encodingError)
            }
        })
    }

    /// Download the audit trail.
    public func downloadEmailAuditTrail(emailId: String, certificateId: String, path: Request.DownloadFileDestination) -> Request {
        return Alamofire.download(Alamofire.Method.GET, self.url + "/v3/emails/" + emailId + "/certificates/" + certificateId + "/download/audit_trail", headers: self.headers, destination: path)
    }

    /// Download the email document.
    public func downloadEmailDocument(emailId: String, certificateId: String, path: Request.DownloadFileDestination) -> Request {
        return Alamofire.download(Alamofire.Method.GET, self.url + "/v3/emails/" + emailId + "/certificates/" + certificateId + "/download/original", headers: self.headers, destination: path)
    }

    // MARK: - SMS

    /// Get sms information.
    public func getSMS(limit: Int?, offset: Int?, var conditions: [String: AnyObject]? = [String: AnyObject]()) -> Request {
        conditions!["limit"]  = limit
        conditions!["offset"] = offset
        
        return getSMS(conditions!)
    }
    
    /// Get sms information.
    public func getSMS(conditions: [String: AnyObject] = [String: AnyObject]()) -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/sms.json", headers: self.headers, parameters: conditions)
    }
    
    /// Count sms.
    public func countSMS(conditions: [String: AnyObject]? = [String: AnyObject]()) -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/sms/count.json", headers: self.headers, parameters: conditions)
    }
    
    /// Get sms information.
    public func getSingleSMS(smsId: String) -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/sms/\(smsId).json", headers: self.headers)
    }
    
    /// Create an sms.
    public func createSMS(files: [NSURL], recipients: [Dictionary<String, String>], body: String?, params: [String: AnyObject]? = [String: AnyObject](), successHandler: Response<AnyObject, NSError>? -> Void) {
        return Alamofire.upload(.POST, self.url + "/v3/sms.json", headers: self.headers, multipartFormData: { multipartFormData in
            if body != nil {
                multipartFormData.appendBodyPart(
                    data: body!.dataUsingEncoding(NSUTF8StringEncoding)!,
                    name: "body"
                )
            }
            
            for (index, recipient) in recipients.enumerate() {
                for (field, value) in recipient {
                    multipartFormData.appendBodyPart(
                        data: value.dataUsingEncoding(NSUTF8StringEncoding)!,
                        name: "recipients[\(index)][\(field)]"
                    )
                }
            }
            
            for file in files {
                multipartFormData.appendBodyPart(
                    fileURL: file,
                    name: "files[]"
                )
            }
            
            if params != nil {
                for (field, value) in params! {
                    multipartFormData.appendBodyPart(
                        data: value.dataUsingEncoding(NSUTF8StringEncoding)!,
                        name: String(field)
                    )
                }
            }
            }, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON(completionHandler: successHandler)
                    
                case .Failure(let encodingError):
                    print(encodingError)
                }
        })
    }
    
    /// Download the audit trail.
    public func downloadSMSAuditTrail(smsId: String, certificateId: String, path: Request.DownloadFileDestination) -> Request {
        return Alamofire.download(Alamofire.Method.GET, self.url + "/v3/sms/" + smsId + "/certificates/" + certificateId + "/download/audit_trail", headers: self.headers, destination: path)
    }

    // MARK: - Team

    /// Get users information.
    public func getUsers(limit: Int?, offset: Int?, var conditions: [String: AnyObject]? = [String: AnyObject]()) -> Request {
        conditions!["limit"]  = limit
        conditions!["offset"] = offset
        
        return getUsers(conditions!)
    }

    /// Get users information.
    public func getUsers(conditions: [String: AnyObject] = [String: AnyObject]()) -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/team/users.json", headers: self.headers, parameters: conditions)
    }

    /// Get seats information.
    public func getSeats(limit: Int?, offset: Int?, var conditions: [String: AnyObject]? = [String: AnyObject]()) -> Request {
        conditions!["limit"]  = limit
        conditions!["offset"] = offset
        
        return getSeats(conditions!)
    }
    
    /// Get seats information.
    public func getSeats(conditions: [String: AnyObject] = [String: AnyObject]()) -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/team/seats.json", headers: self.headers, parameters: conditions)
    }

    /// Get user information.
    public func getUser(userId: String) -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/team/users/\(userId).json", headers: self.headers)
    }

    /// Invite a user.
    public func inviteUser(email: String, role: String) -> Request {
        let params: [String: String] = [
            "email": email,
            "role": role
        ]

        return Alamofire.request(Alamofire.Method.POST, "\(self.url)/v3/team/users.json", headers: self.headers, parameters: params)
    }
    
    /// Update user role.
    public func changeUserRole(userId: String, role: String) -> Request {
        let params: [String: String] = ["role": role]

        return Alamofire.request(Alamofire.Method.PATCH, "\(self.url)/v3/team/users/\(userId).json", headers: self.headers, parameters: params)
    }

    /// Remove a user from the team.
    public func removeUser(userId: String) -> Request {
        return Alamofire.request(Alamofire.Method.DELETE, "\(self.url)/v3/team/users/\(userId).json", headers: self.headers)
    }

    /// Remove a seat from the team.
    public func removeSeat(seatId: String) -> Request {
        return Alamofire.request(Alamofire.Method.DELETE, "\(self.url)/v3/team/seats/\(seatId).json", headers: self.headers)
    }

    // MARK: - Groups

    /// Get groups information.
    public func getGroups(limit: Int?, offset: Int?, var conditions: [String: AnyObject]? = [String: AnyObject]()) -> Request {
        conditions!["limit"]  = limit
        conditions!["offset"] = offset
        
        return getGroups(conditions!)
    }
    
    /// Get groups information.
    public func getGroups(conditions: [String: AnyObject] = [String: AnyObject]()) -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/team/groups.json", headers: self.headers, parameters: conditions)
    }

    /// Get group information.
    public func getGroup(groupId: String) -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/team/groups/\(groupId).json", headers: self.headers)
    }

    /// Create a group.
    public func createGroup(name: String) -> Request {
        let params: [String: String] = [
            "name": name
        ]
        
        return Alamofire.request(Alamofire.Method.POST, "\(self.url)/v3/team/groups.json", headers: self.headers, parameters: params)
    }

    /// Update a group.
    public func updateGroup(groupId: String, name: String) -> Request {
        let params: [String: String] = ["name": name]
        
        return Alamofire.request(Alamofire.Method.PATCH, "\(self.url)/v3/team/groups/\(groupId).json", headers: self.headers, parameters: params)
    }

    /// Remove a group.
    public func deleteGroup(groupId: String) -> Request {
        return Alamofire.request(Alamofire.Method.DELETE, "\(self.url)/v3/team/groups/\(groupId).json", headers: self.headers)
    }

    /// Add a manager to a group.
    public func addManagerToGroup(groupId: String, userId: String) -> Request {
        return Alamofire.request(Alamofire.Method.POST, "\(self.url)/v3/team/groups/\(groupId)/managers/\(userId).json", headers: self.headers)
    }

    /// Add a member to a group.
    public func addMemberToGroup(groupId: String, userId: String) -> Request {
        return Alamofire.request(Alamofire.Method.POST, "\(self.url)/v3/team/groups/\(groupId)/members/\(userId).json", headers: self.headers)
    }

    /// Remove a manager to a group.
    public func removeManagerFromGroup(groupId: String, userId: String) -> Request {
        return Alamofire.request(Alamofire.Method.DELETE, "\(self.url)/v3/team/groups/\(groupId)/managers/\(userId).json", headers: self.headers)
    }
    
    /// Remove a member to a group.
    public func removeMemberFromGroup(groupId: String, userId: String) -> Request {
        return Alamofire.request(Alamofire.Method.DELETE, "\(self.url)/v3/team/groups/\(groupId)/members/\(userId).json", headers: self.headers)
    }

    // MARK: - Contacts

    /// Get contacts information.
    public func getContacts(limit: Int?, offset: Int?, var conditions: [String: AnyObject]? = [String: AnyObject]()) -> Request {
        conditions!["limit"]  = limit
        conditions!["offset"] = offset
        
        return getContacts(conditions!)
    }
    
    /// Get contacts information.
    public func getContacts(conditions: [String: AnyObject] = [String: AnyObject]()) -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/contacts.json", headers: self.headers, parameters: conditions)
    }
    
    /// Get contact information.
    public func getContact(contactId: String) -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/contacts/\(contactId).json", headers: self.headers)
    }
    
    /// Create a contact.
    public func createContact(email: String, name: String) -> Request {
        let params: [String: String] = [
            "email": email,
            "name": name
        ]
        
        return Alamofire.request(Alamofire.Method.POST, "\(self.url)/v3/contacts.json", headers: self.headers, parameters: params)
    }
    
    /// Update a contact.
    public func updateContact(contactId: String, email: String, name: String) -> Request {
        let params: [String: String] = [
            "email": email,
            "name": name
        ]
        
        return Alamofire.request(Alamofire.Method.PATCH, "\(self.url)/v3/contacts/\(contactId).json", headers: self.headers, parameters: params)
    }
    
    /// Remove a contact.
    public func deleteContact(contactId: String) -> Request {
        return Alamofire.request(Alamofire.Method.DELETE, "\(self.url)/v3/contacts/\(contactId).json", headers: self.headers)
    }

    // MARK: - Subscriptions
    
    /// Get subscriptions information.
    public func getSubscriptions(limit: Int?, offset: Int?, var conditions: [String: AnyObject]? = [String: AnyObject]()) -> Request {
        conditions!["limit"]  = limit
        conditions!["offset"] = offset
        
        return getSubscriptions(conditions!)
    }
    
    /// Get subscriptions information.
    public func getSubscriptions(conditions: [String: AnyObject] = [String: AnyObject]()) -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/subscriptions.json", headers: self.headers, parameters: conditions)
    }

    /// Get subscriptions count.
    public func countSubscriptions(conditions: [String: AnyObject]? = [String: AnyObject]()) -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/subscriptions/count.json", headers: self.headers, parameters: conditions)
    }

    /// Get subscription information.
    public func getSubscription(subscriptionId: String) -> Request {
        return Alamofire.request(Alamofire.Method.GET, "\(self.url)/v3/subscriptions/\(subscriptionId).json", headers: self.headers)
    }
    
    /// Create a subscription.
    public func createSubscription(url: String, events: [String]) -> Request {
        let params: [String: AnyObject] = [
            "url": url,
            "events": events
        ]
        
        return Alamofire.request(Alamofire.Method.POST, "\(self.url)/v3/subscriptions.json", headers: self.headers, parameters: params)
    }
    
    /// Update a subscription.
    public func updateSubscription(subscriptionId: String, url: String, events: [String]) -> Request {
        let params: [String: AnyObject] = [
            "url": url,
            "events": events
        ]
        
        return Alamofire.request(Alamofire.Method.PATCH, "\(self.url)/v3/subscriptions/\(subscriptionId).json", headers: self.headers, parameters: params)
    }
    
    /// Remove a subscription.
    public func deleteSubscription(subscriptionId: String) -> Request {
        return Alamofire.request(Alamofire.Method.DELETE, "\(self.url)/v3/subscriptions/\(subscriptionId).json", headers: self.headers)
    }
}
