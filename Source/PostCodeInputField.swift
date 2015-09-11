//
//  PostCodeInputField.swift
//  JudoKit
//
//  Created by Hamon Riazy on 09/09/2015.
//  Copyright © 2015 Judo Payments. All rights reserved.
//

import UIKit

public protocol PostCodeInputDelegate {
    func postCodeInput(input: PostCodeInputField, isValid: Bool)
}

public class PostCodeInputField: JudoPayInputField {
    
    var delegate: PostCodeInputDelegate?
    
    var billingCountry: BillingCountry = .UK {
        didSet {
            switch billingCountry {
            case .UK, .Canada:
                self.textField.keyboardType = .Default
            default:
                self.textField.keyboardType = .NumberPad
            }
        }
    }
    
    override func setupView() {
        super.setupView()
        self.textField.keyboardType = .Default
        self.textField.autocapitalizationType = .AllCharacters
        self.textField.autocorrectionType = .No
    }
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // only handle delegate calls for own textfield
        guard textField == self.textField else { return false }
        
        // get old and new text
        let oldString = textField.text!
        let newString = (oldString as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        if newString.characters.count == 0 {
            return true
        }
        
        switch billingCountry {
        case .UK:
            return newString.isAlphaNumeric() && newString.characters.count <= 8
        case .Canada:
            return newString.isAlphaNumeric() && newString.characters.count <= 6
        case .USA:
            return newString.isNumeric() && newString.characters.count <= 5
        default:
            return newString.isNumeric() && newString.characters.count <= 8
        }
    }

    // MARK: Custom methods
    
    override func textFieldDidChangeValue(textField: UITextField) {
        
        guard let newString = self.textField.text else { return }
        
        let usaRegex = try! NSRegularExpression(pattern: "(^\\d{5}$)|(^\\d{5}-\\d{4}$)", options: .AnchorsMatchLines)
        let ukRegex = try! NSRegularExpression(pattern: "(GIR 0AA)|((([A-Z-[QVX]][0-9][0-9]?)|(([A-Z-[QVX]][A-Z-[IJZ]][0-9][0-9]?)|(([A-Z-[QVX‌​]][0-9][A-HJKSTUW])|([A-Z-[QVX]][A-Z-[IJZ]][0-9][ABEHMNPRVWXY]))))\\s?[0-9][A-Z-[C‌​IKMOV]]{2})", options: .AnchorsMatchLines)
        let canadaRegex = try! NSRegularExpression(pattern: "[ABCEGHJKLMNPRSTVXY][0-9][ABCEGHJKLMNPRSTVWXYZ][0-9][ABCEGHJKLMNPRSTVWXYZ][0-9]", options: .AnchorsMatchLines)
        
        switch billingCountry {
        case .UK where ukRegex.numberOfMatchesInString(newString, options: NSMatchingOptions.WithoutAnchoringBounds, range: NSMakeRange(0, newString.characters.count)) > 0:
            self.delegate?.postCodeInput(self, isValid: true)
        case .Canada where canadaRegex.numberOfMatchesInString(newString, options: NSMatchingOptions.WithoutAnchoringBounds, range: NSMakeRange(0, newString.characters.count)) > 0 && newString.characters.count == 6:
            self.delegate?.postCodeInput(self, isValid: true)
        case .USA where usaRegex.numberOfMatchesInString(newString, options: NSMatchingOptions.WithoutAnchoringBounds, range: NSMakeRange(0, newString.characters.count)) > 0:
            self.delegate?.postCodeInput(self, isValid: true)
        case .Other where newString.isNumeric() && newString.characters.count <= 8:
            self.delegate?.postCodeInput(self, isValid: true)
        default:
            self.delegate?.postCodeInput(self, isValid: false)
        }
    }
    
    override func placeholder() -> String? {
        return "000000"
    }
    
    override func title() -> String {
        return self.billingCountry.titleDescription()
    }

}
