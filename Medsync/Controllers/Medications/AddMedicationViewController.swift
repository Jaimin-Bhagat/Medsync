import UIKit

class AddMedicationViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let nameTextField = MedSyncTextField(placeholder: "Medication Name")
    private let dosageTextField = MedSyncTextField(placeholder: "Dosage (e.g., 10mg)")
    private let instructionsTextField = MedSyncTextField(placeholder: "Instructions")
    
    private let scheduleLabel = UILabel()
    private let scheduleTableView = UITableView(frame: .zero, style: .insetGrouped)
    private let addScheduleButton = MedSyncButton(title: "Add Schedule", style: .secondary)
    
    private let colorLabel = UILabel()
    private let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumInteritemSpacing = 10
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private let refillReminderSwitch = UISwitch()
    private let refillReminderLabel = UILabel()
    private let refillDatePicker = UIDatePicker()
    
    private let saveButton = MedSyncButton(title: "Save Medication", style: .primary)
    private let cancelButton = MedSyncButton(title: "Cancel", style: .secondary)
    
    private var selectedColor = "#FF5733" // Default color
    private var scheduleTimes: [Medication.MedicationTime] = []
    
    private let colors = [
        "#FF5733", // Red
        "#33FF57", // Green
        "#3357FF", // Blue
        "#FF33F5", // Pink
        "#F5FF33", // Yellow
        "#33FFF5", // Cyan
        "#F533FF", // Purple
        "#FF8333", // Orange
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScrollView()
        setupTextFields()
        setupScheduleSection()
        setupColorSection()
        setupRefillSection()
        setupButtons()
    }
    
    private func setupView() {
        title = "Add Medication"
        view.backgroundColor = .systemGroupedBackground
        
        // Add done button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
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
    
    private func setupTextFields() {
        contentView.addSubview(nameTextField)
        contentView.addSubview(dosageTextField)
        contentView.addSubview(instructionsTextField)
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            dosageTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            dosageTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dosageTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            instructionsTextField.topAnchor.constraint(equalTo: dosageTextField.bottomAnchor, constant: 16),
            instructionsTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            instructionsTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    private func setupScheduleSection() {
        scheduleLabel.text = "Schedule"
        scheduleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        scheduleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        scheduleTableView.translatesAutoresizingMaskIntoConstraints = false
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        scheduleTableView.register(ScheduleCell.self, forCellReuseIdentifier: "ScheduleCell")
        scheduleTableView.isScrollEnabled = false
        
        addScheduleButton.translatesAutoresizingMaskIntoConstraints = false
        addScheduleButton.addTarget(self, action: #selector(addScheduleTapped), for: .touchUpInside)
        
        contentView.addSubview(scheduleLabel)
        contentView.addSubview(scheduleTableView)
        contentView.addSubview(addScheduleButton)
        
        NSLayoutConstraint.activate([
            scheduleLabel.topAnchor.constraint(equalTo: instructionsTextField.bottomAnchor, constant: 24),
            scheduleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            scheduleTableView.topAnchor.constraint(equalTo: scheduleLabel.bottomAnchor, constant: 8),
            scheduleTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scheduleTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scheduleTableView.heightAnchor.constraint(equalToConstant: 150),
            
            addScheduleButton.topAnchor.constraint(equalTo: scheduleTableView.bottomAnchor, constant: 8),
            addScheduleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addScheduleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    private func setupColorSection() {
        colorLabel.text = "Color"
        colorLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        colorCollectionView.backgroundColor = .clear
        
        contentView.addSubview(colorLabel)
        contentView.addSubview(colorCollectionView)
        
        NSLayoutConstraint.activate([
            colorLabel.topAnchor.constraint(equalTo: addScheduleButton.bottomAnchor, constant: 24),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 8),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupRefillSection() {
        refillReminderLabel.text = "Refill Reminder"
        refillReminderLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        refillReminderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        refillReminderSwitch.translatesAutoresizingMaskIntoConstraints = false
        refillReminderSwitch.addTarget(self, action: #selector(refillSwitchChanged), for: .valueChanged)
        
        refillDatePicker.translatesAutoresizingMaskIntoConstraints = false
        refillDatePicker.datePickerMode = .date
        refillDatePicker.minimumDate = Date()
        refillDatePicker.isHidden = true
        
        contentView.addSubview(refillReminderLabel)
        contentView.addSubview(refillReminderSwitch)
        contentView.addSubview(refillDatePicker)
        
        NSLayoutConstraint.activate([
            refillReminderLabel.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 24),
            refillReminderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            refillReminderSwitch.centerYAnchor.constraint(equalTo: refillReminderLabel.centerYAnchor),
            refillReminderSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            refillDatePicker.topAnchor.constraint(equalTo: refillReminderLabel.bottomAnchor, constant: 16),
            refillDatePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            refillDatePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    private func setupButtons() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        contentView.addSubview(saveButton)
        contentView.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: refillDatePicker.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func addScheduleTapped() {
        let scheduleVC = AddScheduleViewController()
        scheduleVC.delegate = self
        let navigationController = UINavigationController(rootViewController: scheduleVC)
        present(navigationController, animated: true)
    }
    
    @objc private func refillSwitchChanged() {
        refillDatePicker.isHidden = !refillReminderSwitch.isOn
    }
    
    @objc private func saveTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(message: "Please enter a medication name")
            return
        }
        
        guard let dosage = dosageTextField.text, !dosage.isEmpty else {
            showAlert(message: "Please enter a dosage")
            return
        }
        
        guard !scheduleTimes.isEmpty else {
            showAlert(message: "Please add at least one schedule")
            return
        }
        
        // Create medication
        let medication = Medication(
            name: name,
            dosage: dosage,
            schedule: scheduleTimes,
            instructions: instructionsTextField.text ?? "",
            color: selectedColor,
            imageURL: nil,
            refillDate: refillReminderSwitch.isOn ? refillDatePicker.date : nil,
            refillReminder: refillReminderSwitch.isOn,
            remainingDoses: nil
        )
        
        // Save to data store
        var medications = DataStore.shared.loadMedications()
        medications.append(medication)
        DataStore.shared.saveMedications(medications)
        
        // Schedule notifications
        for scheduleTime in scheduleTimes {
            NotificationService.shared.scheduleMedicationReminder(for: medication, at: scheduleTime.time)
        }
        
        if refillReminderSwitch.isOn {
            NotificationService.shared.scheduleRefillReminder(for: medication)
        }
        
        dismiss(animated: true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension AddMedicationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleTimes.isEmpty ? 1 : scheduleTimes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if scheduleTimes.isEmpty {
            let cell = UITableViewCell()
            cell.textLabel?.text = "No schedules added"
            cell.textLabel?.textColor = .secondaryLabel
            cell.selectionStyle = .none
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as? ScheduleCell else {
            return UITableViewCell()
        }
        
        let scheduleTime = scheduleTimes[indexPath.row]
        cell.configure(with: scheduleTime)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && !scheduleTimes.isEmpty {
            scheduleTimes.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !scheduleTimes.isEmpty
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension AddMedicationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCell else {
            return UICollectionViewCell()
        }
        
        let color = colors[indexPath.item]
        cell.configure(with: color, isSelected: color == selectedColor)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedColor = colors[indexPath.item]
        collectionView.reloadData()
    }
}

// MARK: - AddScheduleViewControllerDelegate

extension AddMedicationViewController: AddScheduleViewControllerDelegate {
    
    func didAddSchedule(_ schedule: Medication.MedicationTime) {
        scheduleTimes.append(schedule)
        scheduleTableView.reloadData()
    }
}

// MARK: - ScheduleCell

class ScheduleCell: UITableViewCell {
    
    private let timeLabel = UILabel()
    private let daysLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.font = UIFont.systemFont(ofSize: 14)
        daysLabel.textColor = .secondaryLabel
        
        contentView.addSubview(timeLabel)
        contentView.addSubview(daysLabel)
        
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            daysLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            daysLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            daysLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with schedule: Medication.MedicationTime) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timeLabel.text = formatter.string(from: schedule.time)
        
        daysLabel.text = formatDaysOfWeek(schedule.daysOfWeek)
    }
    
    private func formatDaysOfWeek(_ days: [Int]) -> String {
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let selectedDays = days.map { dayNames[$0 - 1] }
        
        if selectedDays.count == 7 {
            return "Every day"
        } else if selectedDays.count == 5 && !selectedDays.contains("Sat") && !selectedDays.contains("Sun") {
            return "Weekdays"
        } else if selectedDays.count == 2 && selectedDays.contains("Sat") && selectedDays.contains("Sun") {
            return "Weekends"
        } else {
            return selectedDays.joined(separator: ", ")
        }
    }
}

// MARK: - ColorCell

class ColorCell: UICollectionViewCell {
    
    private let colorView = UIView()
    private let checkmarkImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.layer.cornerRadius = 20
        colorView.clipsToBounds = true
        
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.image = UIImage(systemName: "checkmark")
        checkmarkImageView.tintColor = .white
        checkmarkImageView.isHidden = true
        
        contentView.addSubview(colorView)
        colorView.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            checkmarkImageView.centerXAnchor.constraint(equalTo: colorView.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: colorView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 20),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(with colorHex: String, isSelected: Bool) {
        if let color = colorHex.hexToUIColor() {
            colorView.backgroundColor = color
        } else {
            colorView.backgroundColor = .systemBlue
        }
        
        checkmarkImageView.isHidden = !isSelected
    }
}

// MARK: - AddScheduleViewController

protocol AddScheduleViewControllerDelegate: AnyObject {
    func didAddSchedule(_ schedule: Medication.MedicationTime)
}

class AddScheduleViewController: UIViewController {
    
    weak var delegate: AddScheduleViewControllerDelegate?
    
    private let timePicker = UIDatePicker()
    private let daysOfWeekLabel = UILabel()
    private let daysStackView = UIStackView()
    private let saveButton = MedSyncButton(title: "Save Schedule", style: .primary)
    
    private var selectedDays: [Int] = []
    private let dayButtons: [UIButton] = (0..<7).map { _ in UIButton() }
    private let dayNames = ["S", "M", "T", "W", "T", "F", "S"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTimePicker()
        setupDaysOfWeek()
        setupSaveButton()
    }
    
    private func setupView() {
        title = "Add Schedule"
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
    }
    
    private func setupTimePicker() {
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        
        view.addSubview(timePicker)
        
        NSLayoutConstraint.activate([
            timePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func setupDaysOfWeek() {
        daysOfWeekLabel.text = "Days of Week"
        daysOfWeekLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        daysOfWeekLabel.translatesAutoresizingMaskIntoConstraints = false
        
        daysStackView.translatesAutoresizingMaskIntoConstraints = false
        daysStackView.axis = .horizontal
        daysStackView.distribution = .fillEqually
        daysStackView.spacing = 8
        
        view.addSubview(daysOfWeekLabel)
        view.addSubview(daysStackView)
        
        NSLayoutConstraint.activate([
            daysOfWeekLabel.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 24),
            daysOfWeekLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            daysStackView.topAnchor.constraint(equalTo: daysOfWeekLabel.bottomAnchor, constant: 16),
            daysStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            daysStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            daysStackView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        for (index, button) in dayButtons.enumerated() {
            button.setTitle(dayNames[index], for: .normal)
            button.setTitleColor(.white, for: .selected)
            button.setTitleColor(.systemBlue, for: .normal)
            button.backgroundColor = .systemGray6
            button.layer.cornerRadius = 20
            button.tag = index + 1 // 1-7 for Sunday-Saturday
            button.addTarget(self, action: #selector(dayButtonTapped(_:)), for: .touchUpInside)
            
            daysStackView.addArrangedSubview(button)
            
            // Set height and width constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        }
    }
    
    private func setupSaveButton() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: daysStackView.bottomAnchor, constant: 32),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    @objc private func dayButtonTapped(_ sender: UIButton) {
        let day = sender.tag
        
        if selectedDays.contains(day) {
            selectedDays.removeAll { $0 == day }
            sender.isSelected = false
            sender.backgroundColor = .systemGray6
        } else {
            selectedDays.append(day)
            sender.isSelected = true
            sender.backgroundColor = .systemBlue
        }
    }
    
    @objc private func saveTapped() {
        guard !selectedDays.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please select at least one day", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let schedule = Medication.MedicationTime(time: timePicker.date, daysOfWeek: selectedDays)
        delegate?.didAddSchedule(schedule)
        dismiss(animated: true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
} 