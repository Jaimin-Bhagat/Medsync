import UIKit

class MedicationDetailViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let headerView = UIView()
    private let colorIndicator = UIView()
    private let nameLabel = UILabel()
    private let dosageLabel = UILabel()
    
    private let instructionsCard = MedSyncCardView()
    private let instructionsLabel = UILabel()
    private let instructionsValueLabel = UILabel()
    
    private let scheduleCard = MedSyncCardView()
    private let scheduleLabel = UILabel()
    private let scheduleTableView = UITableView()
    
    private let refillCard = MedSyncCardView()
    private let refillLabel = UILabel()
    private let refillDateLabel = UILabel()
    
    private let historyCard = MedSyncCardView()
    private let historyLabel = UILabel()
    private let historyTableView = UITableView()
    
    private let editButton = MedSyncButton(title: "Edit Medication", style: .primary)
    private let deleteButton = MedSyncButton(title: "Delete Medication", style: .destructive)
    
    private let medication: Medication
    private var medicationRecords: [MedicationRecord] = []
    
    init(medication: Medication) {
        self.medication = medication
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScrollView()
        setupHeaderView()
        setupInstructionsCard()
        setupScheduleCard()
        setupRefillCard()
        setupHistoryCard()
        setupButtons()
        loadMedicationRecords()
    }
    
    private func setupView() {
        title = "Medication Details"
        view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .white
        
        colorIndicator.translatesAutoresizingMaskIntoConstraints = false
        colorIndicator.layer.cornerRadius = 20
        if let colorHex = medication.color.hexToUIColor() {
            colorIndicator.backgroundColor = colorHex
        } else {
            colorIndicator.backgroundColor = .systemBlue
        }
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.text = medication.name
        
        dosageLabel.translatesAutoresizingMaskIntoConstraints = false
        dosageLabel.font = UIFont.systemFont(ofSize: 18)
        dosageLabel.textColor = .secondaryLabel
        dosageLabel.text = medication.dosage
        
        headerView.addSubview(colorIndicator)
        headerView.addSubview(nameLabel)
        headerView.addSubview(dosageLabel)
        contentView.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            colorIndicator.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            colorIndicator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            colorIndicator.widthAnchor.constraint(equalToConstant: 40),
            colorIndicator.heightAnchor.constraint(equalToConstant: 40),
            
            nameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: colorIndicator.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            dosageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            dosageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            dosageLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            dosageLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupInstructionsCard() {
        instructionsCard.translatesAutoresizingMaskIntoConstraints = false
        
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        instructionsLabel.text = "Instructions"
        
        instructionsValueLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsValueLabel.font = UIFont.systemFont(ofSize: 16)
        instructionsValueLabel.textColor = .secondaryLabel
        instructionsValueLabel.text = medication.instructions.isEmpty ? "No instructions provided" : medication.instructions
        instructionsValueLabel.numberOfLines = 0
        
        instructionsCard.addSubview(instructionsLabel)
        instructionsCard.addSubview(instructionsValueLabel)
        contentView.addSubview(instructionsCard)
        
        NSLayoutConstraint.activate([
            instructionsCard.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            instructionsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            instructionsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            instructionsLabel.topAnchor.constraint(equalTo: instructionsCard.topAnchor, constant: 16),
            instructionsLabel.leadingAnchor.constraint(equalTo: instructionsCard.leadingAnchor, constant: 16),
            instructionsLabel.trailingAnchor.constraint(equalTo: instructionsCard.trailingAnchor, constant: -16),
            
            instructionsValueLabel.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 8),
            instructionsValueLabel.leadingAnchor.constraint(equalTo: instructionsCard.leadingAnchor, constant: 16),
            instructionsValueLabel.trailingAnchor.constraint(equalTo: instructionsCard.trailingAnchor, constant: -16),
            instructionsValueLabel.bottomAnchor.constraint(equalTo: instructionsCard.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupScheduleCard() {
        scheduleCard.translatesAutoresizingMaskIntoConstraints = false
        
        scheduleLabel.translatesAutoresizingMaskIntoConstraints = false
        scheduleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        scheduleLabel.text = "Schedule"
        
        scheduleTableView.translatesAutoresizingMaskIntoConstraints = false
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        scheduleTableView.register(ScheduleCell.self, forCellReuseIdentifier: "ScheduleCell")
        scheduleTableView.isScrollEnabled = false
        scheduleTableView.separatorStyle = .none
        scheduleTableView.backgroundColor = .clear
        
        scheduleCard.addSubview(scheduleLabel)
        scheduleCard.addSubview(scheduleTableView)
        contentView.addSubview(scheduleCard)
        
        NSLayoutConstraint.activate([
            scheduleCard.topAnchor.constraint(equalTo: instructionsCard.bottomAnchor, constant: 16),
            scheduleCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            scheduleCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            scheduleLabel.topAnchor.constraint(equalTo: scheduleCard.topAnchor, constant: 16),
            scheduleLabel.leadingAnchor.constraint(equalTo: scheduleCard.leadingAnchor, constant: 16),
            scheduleLabel.trailingAnchor.constraint(equalTo: scheduleCard.trailingAnchor, constant: -16),
            
            scheduleTableView.topAnchor.constraint(equalTo: scheduleLabel.bottomAnchor, constant: 8),
            scheduleTableView.leadingAnchor.constraint(equalTo: scheduleCard.leadingAnchor),
            scheduleTableView.trailingAnchor.constraint(equalTo: scheduleCard.trailingAnchor),
            scheduleTableView.heightAnchor.constraint(equalToConstant: CGFloat(medication.schedule.count * 60)),
            scheduleTableView.bottomAnchor.constraint(equalTo: scheduleCard.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupRefillCard() {
        refillCard.translatesAutoresizingMaskIntoConstraints = false
        
        refillLabel.translatesAutoresizingMaskIntoConstraints = false
        refillLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        refillLabel.text = "Refill Information"
        
        refillDateLabel.translatesAutoresizingMaskIntoConstraints = false
        refillDateLabel.font = UIFont.systemFont(ofSize: 16)
        refillDateLabel.textColor = .secondaryLabel
        refillDateLabel.numberOfLines = 0
        
        if medication.refillReminder, let refillDate = medication.refillDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            refillDateLabel.text = "Refill reminder set for \(formatter.string(from: refillDate))"
        } else {
            refillDateLabel.text = "No refill reminder set"
        }
        
        refillCard.addSubview(refillLabel)
        refillCard.addSubview(refillDateLabel)
        contentView.addSubview(refillCard)
        
        NSLayoutConstraint.activate([
            refillCard.topAnchor.constraint(equalTo: scheduleCard.bottomAnchor, constant: 16),
            refillCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            refillCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            refillLabel.topAnchor.constraint(equalTo: refillCard.topAnchor, constant: 16),
            refillLabel.leadingAnchor.constraint(equalTo: refillCard.leadingAnchor, constant: 16),
            refillLabel.trailingAnchor.constraint(equalTo: refillCard.trailingAnchor, constant: -16),
            
            refillDateLabel.topAnchor.constraint(equalTo: refillLabel.bottomAnchor, constant: 8),
            refillDateLabel.leadingAnchor.constraint(equalTo: refillCard.leadingAnchor, constant: 16),
            refillDateLabel.trailingAnchor.constraint(equalTo: refillCard.trailingAnchor, constant: -16),
            refillDateLabel.bottomAnchor.constraint(equalTo: refillCard.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupHistoryCard() {
        historyCard.translatesAutoresizingMaskIntoConstraints = false
        
        historyLabel.translatesAutoresizingMaskIntoConstraints = false
        historyLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        historyLabel.text = "Medication History"
        
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        historyTableView.delegate = self
        historyTableView.dataSource = self
        historyTableView.register(HistoryCell.self, forCellReuseIdentifier: "HistoryCell")
        historyTableView.isScrollEnabled = false
        historyTableView.separatorStyle = .none
        historyTableView.backgroundColor = .clear
        
        historyCard.addSubview(historyLabel)
        historyCard.addSubview(historyTableView)
        contentView.addSubview(historyCard)
        
        NSLayoutConstraint.activate([
            historyCard.topAnchor.constraint(equalTo: refillCard.bottomAnchor, constant: 16),
            historyCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            historyCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            historyLabel.topAnchor.constraint(equalTo: historyCard.topAnchor, constant: 16),
            historyLabel.leadingAnchor.constraint(equalTo: historyCard.leadingAnchor, constant: 16),
            historyLabel.trailingAnchor.constraint(equalTo: historyCard.trailingAnchor, constant: -16),
            
            historyTableView.topAnchor.constraint(equalTo: historyLabel.bottomAnchor, constant: 8),
            historyTableView.leadingAnchor.constraint(equalTo: historyCard.leadingAnchor),
            historyTableView.trailingAnchor.constraint(equalTo: historyCard.trailingAnchor),
            historyTableView.heightAnchor.constraint(equalToConstant: 200),
            historyTableView.bottomAnchor.constraint(equalTo: historyCard.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupButtons() {
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        contentView.addSubview(editButton)
        contentView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            editButton.topAnchor.constraint(equalTo: historyCard.bottomAnchor, constant: 24),
            editButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            deleteButton.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 16),
            deleteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    private func loadMedicationRecords() {
        let allRecords = DataStore.shared.loadMedicationRecords()
        medicationRecords = allRecords.filter { $0.medicationId == medication.id }
            .sorted(by: { $0.scheduledTime > $1.scheduledTime })
        
        historyTableView.reloadData()
    }
    
    @objc private func editTapped() {
        // Navigate to edit medication screen
        let editVC = EditMedicationViewController(medication: medication)
        let navigationController = UINavigationController(rootViewController: editVC)
        present(navigationController, animated: true)
    }
    
    @objc private func deleteTapped() {
        let alert = UIAlertController(title: "Delete Medication", message: "Are you sure you want to delete this medication? This action cannot be undone.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteMedication()
        })
        
        present(alert, animated: true)
    }
    
    private func deleteMedication() {
        // Remove from data store
        var medications = DataStore.shared.loadMedications()
        medications.removeAll { $0.id == medication.id }
        DataStore.shared.saveMedications(medications)
        
        // Cancel notifications
        NotificationService.shared.cancelMedicationReminders(for: medication.id)
        
        // Navigate back
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MedicationDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == scheduleTableView {
            return medication.schedule.count
        } else if tableView == historyTableView {
            return medicationRecords.isEmpty ? 1 : min(medicationRecords.count, 5)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == scheduleTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as? ScheduleCell else {
                return UITableViewCell()
            }
            
            let scheduleTime = medication.schedule[indexPath.row]
            cell.configure(with: scheduleTime)
            
            return cell
        } else if tableView == historyTableView {
            if medicationRecords.isEmpty {
                let cell = UITableViewCell()
                cell.textLabel?.text = "No history available"
                cell.textLabel?.textColor = .secondaryLabel
                cell.selectionStyle = .none
                return cell
            }
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? HistoryCell else {
                return UITableViewCell()
            }
            
            let record = medicationRecords[indexPath.row]
            cell.configure(with: record)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == scheduleTableView {
            return 60
        } else if tableView == historyTableView {
            return 60
        }
        return 44
    }
}

// MARK: - HistoryCell

class HistoryCell: UITableViewCell {
    
    private let dateLabel = UILabel()
    private let statusLabel = UILabel()
    private let statusIndicator = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear
        
        statusIndicator.translatesAutoresizingMaskIntoConstraints = false
        statusIndicator.layer.cornerRadius = 8
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.textColor = .secondaryLabel
        
        contentView.addSubview(statusIndicator)
        contentView.addSubview(dateLabel)
        contentView.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            statusIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusIndicator.widthAnchor.constraint(equalToConstant: 16),
            statusIndicator.heightAnchor.constraint(equalToConstant: 16),
            
            dateLabel.leadingAnchor.constraint(equalTo: statusIndicator.trailingAnchor, constant: 16),
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            statusLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            statusLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with record: MedicationRecord) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        dateLabel.text = dateFormatter.string(from: record.scheduledTime)
        
        switch record.status {
        case .taken:
            statusLabel.text = "Taken"
            statusIndicator.backgroundColor = .systemGreen
        case .skipped:
            statusLabel.text = "Skipped"
            statusIndicator.backgroundColor = .systemOrange
        case .missed:
            statusLabel.text = "Missed"
            statusIndicator.backgroundColor = .systemRed
        case .pending:
            statusLabel.text = "Pending"
            statusIndicator.backgroundColor = .systemGray
        }
        
        if let actualTime = record.actualTime, record.status == .taken {
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            statusLabel.text = "Taken at \(timeFormatter.string(from: actualTime))"
        }
    }
}

// MARK: - EditMedicationViewController

class EditMedicationViewController: UIViewController {
    
    private let medication: Medication
    
    init(medication: Medication) {
        self.medication = medication
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        title = "Edit Medication"
        view.backgroundColor = .systemGroupedBackground
        
        // Add cancel button
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
} 