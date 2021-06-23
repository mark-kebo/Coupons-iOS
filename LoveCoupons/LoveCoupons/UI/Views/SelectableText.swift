//
//  SelectableText.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 17/03/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit
import SwiftUI

struct SelectableText: UIViewRepresentable {

    private var text: String
    private var selectable: Bool
    private var fontSize: CGFloat
    private var color: UIColor

    init(_ text: String, selectable: Bool = true, fontSize: CGFloat = 20, color: UIColor = .black) {
        self.text = text
        self.fontSize = fontSize
        self.color = color
        self.selectable = selectable
    }

    func makeUIView(context: Context) -> CustomUITextField {
        let textField = CustomUITextField(frame: .zero)
        textField.delegate = textField
        textField.text = self.text
        textField.textColor = self.color
        textField.returnKeyType = .done
        textField.font = UIFont(name: Constants.textFont, size: fontSize)
        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return textField
    }

    func updateUIView(_ uiView: CustomUITextField, context: Context) {
        uiView.text = self.text
        uiView._textBinding = .constant(self.text)
        uiView._isEditable = false
        uiView.isEnabled = self.selectable
    }

    func selectable(_ selectable: Bool) -> SelectableText {
        return SelectableText(self.text, selectable: selectable)
    }

}

/// This subclass is needed since we want to customize the cursor and the context menu
class CustomUITextField: UITextField, UITextFieldDelegate {

    /// (Not used for this workaround, see below for the full code) Binding from the `CustomTextField` so changes of the text can be observed by `SwiftUI`
    fileprivate var _textBinding: Binding<String>!

    /// If it is `true` the text field behaves normally. If `false` text cannot be modified only selected, copied and so on.
    fileprivate var _isEditable = true


    // change the cursor to have zero size
    override func caretRect(for position: UITextPosition) -> CGRect {
        return self._isEditable ? super.caretRect(for: position) : .zero
    }

    // override this method to customize the displayed items of 'UIMenuController' (the context menu when selecting text)
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {

        // disable 'cut', 'delete', 'paste','_promptForReplace:'
        // if it is not editable
        if (!_isEditable) {
            switch action {
            case #selector(cut(_:)),
                 #selector(delete(_:)),
                 #selector(paste(_:)):
                return false
            default:
                // do not show 'Replace...' which can also replace text
                // Note: This selector is private and may change
                if (action == Selector(("_promptForReplace:"))) {
                    return false
                }
            }
        }
        return super.canPerformAction(action, withSender: sender)
    }


    // === UITextFieldDelegate methods

    func textFieldDidChangeSelection(_ textField: UITextField) {
        // update the text of the binding
        self._textBinding.wrappedValue = textField.text ?? ""
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow changing the text depending on `self._isEditable`
        return self._isEditable
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }

}

struct SelectableText_Previews: PreviewProvider {
    static var previews: some View {
        SelectableText("test")
    }
}
