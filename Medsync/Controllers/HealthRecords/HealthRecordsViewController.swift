import UIKit

class HealthRecordsViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var healthProfile: HealthProfile?
    
    private let sections = ["Profile", "Vitals", "Documents"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        loadHealthProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadHealthProfile()
        tableView.reloadData()
    }
    
    private func setupView() {
        title = "Health Records"
        view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add edit button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(ProfileCell.self, forCellReuseIdentifier: "ProfileCell")
    }
    
    private func loadHealthProfile() {
        healthProfile = DataStore.shared.loadHealthProfile()
        
        // If no profile exists, create a basic one
        if healthProfile == nil {
            let newProfile = HealthProfile(
                name: "Your Name",
                dateOfBirth: Date(),
                gender: "Not Specified",
                height: nil,
                allergies: [],
                conditions: [],
                bloodType: nil,
                emergencyContacts: [],
                documents: [],
                vitalRecords: []
            )
            
            healthProfile = newProfile
            DataStore.shared.saveHealthProfile(newProfile)
        }
    }
    
    @objc private func addTapped() {
        let actionSheet = UIAlertController(title: "Add Health Record", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Add Vital Record", style: .default) { [weak self] _ in
            self?.addVitalRecord()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Add Document", style: .default) { [weak self] _ in
            self?.addDocument()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Add Emergency Contact", style: .default) { [weak self] _ in
            self?.addEmergencyContact()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    private func addVitalRecord() {
        let addVitalVC = AddVitalRecordViewController()
        let navigationController = UINavigationController(rootViewController: addVitalVC)
        present(navigationController, animated: true)
    }
    
    private func addDocument() {
        let addDocumentVC = AddDocumentViewController()
        let navigationController = UINavigationController(rootViewController: addDocumentVC)
        present(navigationController, animated: true)
    }
    
    private func addEmergencyContact() {
        let addContactVC = AddEmergencyContactViewController()
        let navigationController = UINavigationController(rootViewController: addContactVC)
        present(navigationController, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension HealthRecordsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let profile = healthProfile else { return 0 }
        
        switch sections[section] {
        case "Profile":
            return 1
        case "Vitals":
            return profile.vitalRecords.isEmpty ? 1 : min(profile.vitalRecords.count, 3)
        case "Documents":
            return profile.documents.isEmpty ? 1 : min(profile.documents.count, 3)
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let profile = healthProfile else { return UITableViewCell() }
        
        switch sections[indexPath.section] {
        case "Profile":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as? ProfileCell else {
                return UITableViewCell()
            }
            cell.configure(with: profile)
            return cell
            
        case "Vitals":
            if profile.vitalRecords.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.textLabel?.text = "No vital records"
                cell.textLabel?.textColor = .secondaryLabel
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                let vitalRecord = profile.vitalRecords.sorted(by: { $0.date > $1.date })[indexPath.row]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                
                cell.textLabel?.text = "\(vitalRecord.type.displayName): \(vitalRecord.value) \(vitalRecord.unit) (\(dateFormatter.string(from: vitalRecord.date)))"
                cell.accessoryType = .disclosureIndicator
                return cell
            }
            
        case "Documents":
            if profile.documents.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.textLabel?.text = "No documents"
                cell.textLabel?.textColor = .secondaryLabel
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                let document = profile.documents.sorted(by: { $0.date > $1.date })[indexPath.row]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                
                cell.textLabel?.text = "\(document.title) (\(dateFormatter.string(from: document.date)))"
                cell.accessoryType = .disclosureIndicator
                return cell
            }
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let profile = healthProfile else { return }
        
        switch sections[indexPath.section] {
        case "Profile":
            let profileVC = EditProfileViewController(profile: profile)
            navigationController?.pushViewController(profileVC, animated: true)
            
        case "Vitals":
            if !profile.vitalRecords.isEmpty {
                let vitalsVC = VitalsListViewController()
                navigationController?.pushViewController(vitalsVC, animated: true)
            }
            
        case "Documents":
            if !profile.documents.isEmpty {
                let documentsVC = DocumentsListViewController()
                navigationController?.pushViewController(documentsVC, animated: true)
            }
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let profile = healthProfile else { return nil }
        
        switch sections[section] {
        case "Vitals", "Documents":
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44))
            
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("See All", for: .normal)
            button.tag = section
            button.addTarget(self, action: #selector(seeAllTapped(_:)), for: .touchUpInside)
            
            footerView.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
                button.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
            ])
            
            // Only show if there are items
            let hasItems = section == 1 ? !profile.vitalRecords.isEmpty : !profile.documents.isEmpty
            return hasItems ? footerView : nil
            
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let profile = healthProfile else { return 0 }
        
        switch sections[section] {
        case "Vitals":
            return profile.vitalRecords.isEmpty ? 0 : 44
        case "Documents":
            return profile.documents.isEmpty ? 0 : 44
        default:
            return 0
        }
    }
    
    @objc private func seeAllTapped(_ sender: UIButton) {
        switch sections[sender.tag] {
        case "Vitals":
            let vitalsVC = VitalsListViewController()
            navigationController?.pushViewController(vitalsVC, animated: true)
            
        case "Documents":
            let documentsVC = DocumentsListViewController()
            navigationController?.pushViewController(documentsVC, animated: true)
            
        default:
            break
        }
    }
}

// MARK: - ProfileCell

class ProfileCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let dobLabel = UILabel()
    private let genderLabel = UILabel()
    private let bloodTypeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        accessoryType = .disclosureIndicator
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        dobLabel.translatesAutoresizingMaskIntoConstraints = false
        dobLabel.font = UIFont.systemFont(ofSize: 14)
        dobLabel.textColor = .secondaryLabel
        
        genderLabel.translatesAutoresizingMaskIntoConstraints = false
        genderLabel.font = UIFont.systemFont(ofSize: 14)
        genderLabel.textColor = .secondaryLabel
        
        bloodTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        bloodTypeLabel.font = UIFont.systemFont(ofSize: 14)
        bloodTypeLabel.textColor = .secondaryLabel
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(dobLabel)
        contentView.addSubview(genderLabel)
        contentView.addSubview(bloodTypeLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dobLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            dobLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dobLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            genderLabel.topAnchor.constraint(equalTo: dobLabel.bottomAnchor, constant: 4),
            genderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            genderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            bloodTypeLabel.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 4),
            bloodTypeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bloodTypeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bloodTypeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with profile: HealthProfile) {
        nameLabel.text = profile.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dobLabel.text = "DOB: \(dateFormatter.string(from: profile.dateOfBirth))"
        
        genderLabel.text = "Gender: \(profile.gender)"
        
        if let bloodType = profile.bloodType {
            bloodTypeLabel.text = "Blood Type: \(bloodType)"
        } else {
            bloodTypeLabel.text = "Blood Type: Not specified"
        }
    }
}

// MARK: - Placeholder View Controllers

class EditProfileViewController: UIViewController {
    
    private let profile: HealthProfile
    
    init(profile: HealthProfile) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Profile"
        view.backgroundColor = .systemGroupedBackground
    }
}

class VitalsListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Vitals"
        view.backgroundColor = .systemGroupedBackground
    }
}

class DocumentsListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Documents"
        view.backgroundColor = .systemGroupedBackground
    }
}

class AddVitalRecordViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Vital Record"
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

class AddDocumentViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Document"
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

class AddEmergencyContactViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Emergency Contact"
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
} 