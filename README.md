Signaturit Swift SDK
====================
This package is a Swift wrapper around the Signaturit API. If you didn't read the documentation yet, maybe it's time to take a look [here](https://docs.signaturit.com/).

Configuration
-------------

The recommended way to install the SDK is through [cocoapods](https://cocoapods.org).

You can use Cocoapods to install Signaturit adding it to your Podfile:

```ruby
platform :ios, '8.0'
use_frameworks!

target 'MyApp' do
    pod 'Signaturit'
end
```

Please note that by default the client will use our sandbox API. When you are ready to start using the production environment just get the correct access token and pass an additional argument to the constructor:

```swift
let Signaturit = Signaturit(accessToken: "YOUR_ACCESS_TOKEN")
```

Examples
--------

## Signatures

### Count signature requests

Count your signature requests.

```swift
client.countSignatures().responseJSON { response in
    print(response)
}
```

### Get all signature requests

Retrieve all data from your signature requests using different filters.

##### All signatures

```swift
client.getSignatures().responseJSON { response in
    print(response)
}
```

##### Getting the last 50 signatures

```swift
client.getSignatures(50).responseJSON { response in
    print(response)
}
```

##### Getting signatures with custom field "crm_id"

```swift
let params = ["crm_id": "CUSTOM_ID"]
client.getSignatures(100, offset: 0, conditions: params).responseJSON { response in
    print(response)
}
```

### Get signature request

Get the information regarding a single signature request passing its ID.

```swift
client.getSignature("SIGNATURE_ID").responseJSON { response in
    print(response)
}
```
### Signature request

Create a new signature request. You can check all signature [params](https://docs.signaturit.com/api/v3#sign_create_sign).

```swift
let file       = NSBundle.mainBundle().URLForResource("Document", withExtension: "pdf")
let recipients = [["email": "john.doe@example.com", "name": "John Doe"]]
let params     = ["subject": "Receipt no. 250", "body": "Please sign the receipt"]

client.createSignature([file], recipients: recipients, params: params, successHandler: { response in
    print(response)
})
```

You can add custom info in your requests

```swift
let file       = NSBundle.mainBundle().URLForResource("Document", withExtension: "pdf")
let recipients = [["email": "john.doe@example.com", "name": "John Doe"]]
let params     = ["subject": "Receipt no. 250", "body": "Please sign the receipt", "data": ["crm_id": "45673"]]

client.createSignature([file], recipients: recipients, params: params, successHandler: { response in
    print(response)
})
```

You can send templates with the fields filled
```swift
let file       = NSBundle.mainBundle().URLForResource("Document", withExtension: "pdf")
let recipients = [["email": "john.doe@example.com", "name": "John Doe"]]
let params     = ["subject": "Receipt no. 250", "body": "Please sign the receipt", "templates": ["template_name"]]

client.createSignature([], recipients: recipients, params: params, successHandler: { response in
    print(response)
})
```

### Cancel signature request

Cancel a signature request.

```swift
client.cancelSignature("SIGNATURE_ID").responseJSON { response in
    print(response)
}
```

### Send reminder

Send a reminder email.

```swift
client.sendSignatureReminder("SIGNATURE_ID").responseJSON { response in
    print(response)
}
```

### Get audit trail

Get the audit trail of a signature request document

```swift
let path = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)

client.downloadAuditTrail("SIGNATURE_ID", documentId: "DOCUMENT_ID", path: path).responseJSON { response in
    print(response)
}
```

### Get signed document

Get the signed document of a signature request document

```swift
let path = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)

client.downloadSignedDocument(SIGNATURE_ID, documentId: "DOCUMENT_ID", path: path).responseJSON { response in
    print(response)
}
```

## Branding

### Get brandings

Get all account brandings.

```swift
client.getBrandings().responseJSON { response in
    print(response)
}
```

### Get branding

Get a single branding.

```swift
client.getBranding("BRANDING_ID").responseJSON { response in
    print(response)
}
```

### Create branding

Create a new branding. You can check all branding [params](https://docs.signaturit.com/api/v3#set_branding).`

```swift
let params = [
    "layout_color": "#FFBF00",
    "text_color": "#2A1B0A",
    "application_texts": ["sign_button": "Sign!"]
]

client.createBranding(params).responseJSON { response in
    print(response)
}
```

### Update branding

Update a single branding.

```swift
let params = ["application_texts" => ["send_button" => "Send!"]]

client.updateBranding("BRANDING_ID", params: params).responseJSON { response in
    print(response)
}
```

## Template

### Get all templates

Retrieve all data from your templates.

```swift
client.getTemplates().responseJSON { response in
    print(response)
}
```

## Email

### Get emails

####Get all certified emails

```swift
response = client.getEmails().responseJSON { response in
    print(response)
}
```

####Get last 50 emails

```swift
response = client.getEmails(50).responseJSON { response in
    print(response)
}
```

####Navigate through all emails in blocks of 50 results

```swift
response = client.getEmails(50, offset: 50).responseJSON { response in
    print(response)
}
```

### Count emails

Count all certified emails

```swift
response = client.countEmails().responseJSON { response in
    print(response)
}
```

### Get email

Get a single email

```swift
client.getEmail("EMAIL_ID").responseJSON { response in
    print(response)
}
```

### Create email

Create a new certified email.

```swift
let file       = NSBundle.mainBundle().URLForResource("Document", withExtension: "pdf")
let recipients = [["email": "john.doe@example.com", "name": "John Doe"]]
let subject    = "Swift subject"
let body       = "Swift body"
let params     = []

client.createEmail([file], recipients: recipients, subject :subject, body: body, params: params, successHandler: { response in
    print(response)
})
```

### Get audit trail document

Get the audit trail document of an email request.

```swift
let path = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)

client.downloadEmailAuditTrail("EMAIL_ID", certificateId: "CERTIFICATE_ID", path: path).responseJSON { response in
    print(response)
}
```
