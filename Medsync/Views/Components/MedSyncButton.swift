import UIKit

class MedSyncButton: UIButton {
    
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
    }
    
    private var style: ButtonStyle = .primary
    
    init(title: String, style: ButtonStyle = .primary) {
        super.init(frame: .zero)
        self.style = style
        setup(title: title)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup(title: "")
    }
    
    private func setup(title: String) {
        setTitle(title, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        layer.cornerRadius = 12
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        // Set height constraint
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        applyStyle()
    }
    
    private func applyStyle() {
        switch style {
        case .primary:
            backgroundColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
            setTitleColor(.white, for: .normal)
        case .secondary:
            backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.969, alpha: 1.0)
            setTitleColor(UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0), for: .normal)
            layer.borderWidth = 1
            layer.borderColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0).cgColor
        case .destructive:
            backgroundColor = UIColor(red: 1.0, green: 0.231, blue: 0.188, alpha: 1.0)
            setTitleColor(.white, for: .normal)
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.alpha = self.isHighlighted ? 0.8 : 1.0
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            }
        }
    }
} 