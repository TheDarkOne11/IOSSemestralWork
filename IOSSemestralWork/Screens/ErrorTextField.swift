//
//  ErrorTextField.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 21/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Resources

/**
 Visual representation of a TextField and a Label used for error messages.
 */
public class ErrorTextField {
    public private(set) var contentView: UIStackView!
    public private(set) weak var textField: UITextField!
    public private(set) weak var errorLabel: UILabel!
    
    public init() {
        let contentView = UIStackView()
        self.contentView = contentView
        contentView.axis = .vertical
        contentView.distribution = .fillProportionally
        contentView.spacing = 8
        
        let textField = UITextField()
        contentView.addArrangedSubview(textField)
        self.textField = textField
        textField.placeholder = L10n.FolderEditView.folderNamePlaceholder
        textField.enablesReturnKeyAutomatically = true
        
        let errorLabel = UILabel()
        contentView.addArrangedSubview(errorLabel)
        self.errorLabel = errorLabel
        errorLabel.text = "Error occured."
        errorLabel.textColor = UIColor.red
        errorLabel.font = UIFont.systemFont(ofSize: 12)
        errorLabel.isHidden = true
    }
}
