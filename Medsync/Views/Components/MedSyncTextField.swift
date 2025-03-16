import UIKit

class MedSyncTextField: UITextField {
    
    private let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    
    init(placeholder: String) {
        super.init(frame: .zero)
        setup(placeholder: placeholder)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup(placeholder: "")
    }
    
    private func setup(placeholder: String) {
        self.placeholder = placeholder
        font = UIFont.systemFont(ofSize: 16)
        backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.969, alpha: 1.0)
        layer.cornerRadius = 12
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        // Set height constraint
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
} 