import UIKit

class MedicationsViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let addButton = MedSyncButton(title: "Add Medication", style: .primary)
    private var medications: [Medication] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        setupAddButton()
        loadMedications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMedications()
        tableView.reloadData()
    }
    
    private func setupView() {
        title = "Medications"
        view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MedicationCell.self, forCellReuseIdentifier: "MedicationCell")
    }
    
    private func setupAddButton() {
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        addButton.addTarget(self, action: #selector(addMedicationTapped), for: .touchUpInside)
    }
    
    private func loadMedications() {
        medications = DataStore.shared.loadMedications()
    }
    
    @objc private func addMedicationTapped() {
        let addMedicationVC = AddMedicationViewController()
        let navigationController = UINavigationController(rootViewController: addMedicationVC)
        present(navigationController, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MedicationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MedicationCell", for: indexPath) as? MedicationCell else {
            return UITableViewCell()
        }
        
        let medication = medications[indexPath.row]
        cell.configure(with: medication)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let medication = medications[indexPath.row]
        let detailVC = MedicationDetailViewController(medication: medication)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let medicationToDelete = medications[indexPath.row]
            
            // Remove from data store
            medications.remove(at: indexPath.row)
            DataStore.shared.saveMedications(medications)
            
            // Cancel notifications
            NotificationService.shared.cancelMedicationReminders(for: medicationToDelete.id)
            
            // Update UI
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - MedicationCell

class MedicationCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let dosageLabel = UILabel()
    private let nextDoseLabel = UILabel()
    private let colorIndicator = UIView()
    
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
        
        // Color indicator
        colorIndicator.translatesAutoresizingMaskIntoConstraints = false
        colorIndicator.layer.cornerRadius = 12
        contentView.addSubview(colorIndicator)
        
        // Name label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        contentView.addSubview(nameLabel)
        
        // Dosage label
        dosageLabel.translatesAutoresizingMaskIntoConstraints = false
        dosageLabel.font = UIFont.systemFont(ofSize: 14)
        dosageLabel.textColor = .secondaryLabel
        contentView.addSubview(dosageLabel)
        
        // Next dose label
        nextDoseLabel.translatesAutoresizingMaskIntoConstraints = false
        nextDoseLabel.font = UIFont.systemFont(ofSize: 14)
        nextDoseLabel.textColor = .secondaryLabel
        contentView.addSubview(nextDoseLabel)
        
        NSLayoutConstraint.activate([
            colorIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorIndicator.widthAnchor.constraint(equalToConstant: 24),
            colorIndicator.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: colorIndicator.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dosageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            dosageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            
            nextDoseLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            nextDoseLabel.topAnchor.constraint(equalTo: dosageLabel.bottomAnchor, constant: 4),
            nextDoseLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with medication: Medication) {
        nameLabel.text = medication.name
        dosageLabel.text = medication.dosage
        
        // Set color indicator
        if let colorHex = medication.color.hexToUIColor() {
            colorIndicator.backgroundColor = colorHex
        } else {
            colorIndicator.backgroundColor = .systemBlue
        }
        
        // Find next dose
        if let nextDose = findNextDose(for: medication) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            nextDoseLabel.text = "Next: \(formatter.string(from: nextDose))"
        } else {
            nextDoseLabel.text = "No upcoming doses"
        }
    }
    
    private func findNextDose(for medication: Medication) -> Date? {
        let now = Date()
        let calendar = Calendar.current
        
        // Get all scheduled times for today and tomorrow
        var allTimes: [Date] = []
        
        for scheduleTime in medication.schedule {
            let weekday = calendar.component(.weekday, from: now) // 1 = Sunday, 7 = Saturday
            
            if scheduleTime.daysOfWeek.contains(weekday) {
                // Today's dose
                if let date = calendar.date(bySettingHour: calendar.component(.hour, from: scheduleTime.time),
                                           minute: calendar.component(.minute, from: scheduleTime.time),
                                           second: 0,
                                           of: now) {
                    allTimes.append(date)
                }
            }
            
            // Tomorrow's dose
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
            let tomorrowWeekday = calendar.component(.weekday, from: tomorrow)
            
            if scheduleTime.daysOfWeek.contains(tomorrowWeekday) {
                if let date = calendar.date(bySettingHour: calendar.component(.hour, from: scheduleTime.time),
                                           minute: calendar.component(.minute, from: scheduleTime.time),
                                           second: 0,
                                           of: tomorrow) {
                    allTimes.append(date)
                }
            }
        }
        
        // Find the next upcoming time
        return allTimes.filter { $0 > now }.min(by: { $0 < $1 })
    }
}

// Helper extension to convert hex string to UIColor
extension String {
    func hexToUIColor() -> UIColor? {
        var hexString = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        if hexString.count != 6 {
            return nil
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                      alpha: 1.0)
    }
} 