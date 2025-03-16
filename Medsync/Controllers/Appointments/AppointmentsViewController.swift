import UIKit

class AppointmentsViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let addButton = MedSyncButton(title: "Add Appointment", style: .primary)
    private var appointments: [Appointment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        setupAddButton()
        loadAppointments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAppointments()
        tableView.reloadData()
    }
    
    private func setupView() {
        title = "Appointments"
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
        tableView.register(AppointmentCell.self, forCellReuseIdentifier: "AppointmentCell")
    }
    
    private func setupAddButton() {
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        addButton.addTarget(self, action: #selector(addAppointmentTapped), for: .touchUpInside)
    }
    
    private func loadAppointments() {
        appointments = DataStore.shared.loadAppointments()
        appointments.sort { $0.date < $1.date }
    }
    
    @objc private func addAppointmentTapped() {
        let addAppointmentVC = AddAppointmentViewController()
        let navigationController = UINavigationController(rootViewController: addAppointmentVC)
        present(navigationController, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension AppointmentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appointments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentCell", for: indexPath) as? AppointmentCell else {
            return UITableViewCell()
        }
        
        let appointment = appointments[indexPath.row]
        cell.configure(with: appointment)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let appointment = appointments[indexPath.row]
        let detailVC = AppointmentDetailViewController(appointment: appointment)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appointmentToDelete = appointments[indexPath.row]
            
            // Remove from data store
            appointments.remove(at: indexPath.row)
            DataStore.shared.saveAppointments(appointments)
            
            // Cancel notifications
            NotificationService.shared.cancelAppointmentReminder(for: appointmentToDelete.id)
            
            // Update UI
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - AppointmentCell

class AppointmentCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let locationLabel = UILabel()
    private let iconImageView = UIImageView()
    
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
        
        // Icon
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = .systemBlue
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(systemName: "calendar")
        contentView.addSubview(iconImageView)
        
        // Title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        contentView.addSubview(titleLabel)
        
        // Date label
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 16)
        dateLabel.textColor = .secondaryLabel
        contentView.addSubview(dateLabel)
        
        // Location label
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = UIFont.systemFont(ofSize: 14)
        locationLabel.textColor = .secondaryLabel
        contentView.addSubview(locationLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            locationLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            locationLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            locationLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with appointment: Appointment) {
        titleLabel.text = appointment.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateLabel.text = dateFormatter.string(from: appointment.date)
        
        locationLabel.text = appointment.location
    }
}

// MARK: - AddAppointmentViewController

class AddAppointmentViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleTextField = MedSyncTextField(placeholder: "Appointment Title")
    private let locationTextField = MedSyncTextField(placeholder: "Location")
    private let notesTextField = MedSyncTextField(placeholder: "Notes")
    
    private let dateLabel = UILabel()
    private let datePicker = UIDatePicker()
    
    private let durationLabel = UILabel()
    private let durationPicker = UIPickerView()
    
    private let reminderLabel = UILabel()
    private let reminderSwitch = UISwitch()
    private let reminderPicker = UIPickerView()
    
    private let saveButton = MedSyncButton(title: "Save Appointment", style: .primary)
    private let cancelButton = MedSyncButton(title: "Cancel", style: .secondary)
    
    private let durations = [15, 30, 45, 60, 90, 120]
    private let reminderTimes = [0, 15, 30, 60, 120, 1440] // minutes (0, 15, 30, 60, 2 hours, 1 day)
    private let reminderLabels = ["None", "15 minutes", "30 minutes", "1 hour", "2 hours", "1 day"]
    
    private var selectedDuration = 30
    private var selectedReminderTime: TimeInterval?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScrollView()
        setupTextFields()
        setupDateSection()
        setupDurationSection()
        setupReminderSection()
        setupButtons()
    }
    
    private func setupView() {
        title = "Add Appointment"
        view.backgroundColor = .systemGroupedBackground
        
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
        contentView.addSubview(titleTextField)
        contentView.addSubview(locationTextField)
        contentView.addSubview(notesTextField)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            locationTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            locationTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            locationTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            notesTextField.topAnchor.constraint(equalTo: locationTextField.bottomAnchor, constant: 16),
            notesTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            notesTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    private func setupDateSection() {
        dateLabel.text = "Date & Time"
        dateLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = Date()
        
        contentView.addSubview(dateLabel)
        contentView.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: notesTextField.bottomAnchor, constant: 24),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            datePicker.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    private func setupDurationSection() {
        durationLabel.text = "Duration"
        durationLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        durationPicker.translatesAutoresizingMaskIntoConstraints = false
        durationPicker.delegate = self
        durationPicker.dataSource = self
        
        // Set default selection
        let defaultIndex = durations.firstIndex(of: selectedDuration) ?? 1
        durationPicker.selectRow(defaultIndex, inComponent: 0, animated: false)
        
        contentView.addSubview(durationLabel)
        contentView.addSubview(durationPicker)
        
        NSLayoutConstraint.activate([
            durationLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 24),
            durationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            durationPicker.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 8),
            durationPicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            durationPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            durationPicker.heightAnchor.constraint(equalToConstant: 120),
        ])
    }
    
    private func setupReminderSection() {
        reminderLabel.text = "Reminder"
        reminderLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        reminderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        reminderSwitch.translatesAutoresizingMaskIntoConstraints = false
        reminderSwitch.addTarget(self, action: #selector(reminderSwitchChanged), for: .valueChanged)
        
        reminderPicker.translatesAutoresizingMaskIntoConstraints = false
        reminderPicker.delegate = self
        reminderPicker.dataSource = self
        reminderPicker.isHidden = true
        
        contentView.addSubview(reminderLabel)
        contentView.addSubview(reminderSwitch)
        contentView.addSubview(reminderPicker)
        
        NSLayoutConstraint.activate([
            reminderLabel.topAnchor.constraint(equalTo: durationPicker.bottomAnchor, constant: 24),
            reminderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            reminderSwitch.centerYAnchor.constraint(equalTo: reminderLabel.centerYAnchor),
            reminderSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            reminderPicker.topAnchor.constraint(equalTo: reminderLabel.bottomAnchor, constant: 8),
            reminderPicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            reminderPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            reminderPicker.heightAnchor.constraint(equalToConstant: 120),
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
            saveButton.topAnchor.constraint(equalTo: reminderPicker.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func reminderSwitchChanged() {
        reminderPicker.isHidden = !reminderSwitch.isOn
        
        if reminderSwitch.isOn {
            // Default to 30 minutes
            let defaultIndex = reminderTimes.firstIndex(of: 30) ?? 2
            reminderPicker.selectRow(defaultIndex, inComponent: 0, animated: false)
            selectedReminderTime = TimeInterval(reminderTimes[defaultIndex] * 60)
        } else {
            selectedReminderTime = nil
        }
    }
    
    @objc private func saveTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(message: "Please enter an appointment title")
            return
        }
        
        guard let location = locationTextField.text, !location.isEmpty else {
            showAlert(message: "Please enter a location")
            return
        }
        
        // Create appointment
        let appointment = Appointment(
            title: title,
            doctorId: nil,
            location: location,
            date: datePicker.date,
            duration: TimeInterval(selectedDuration * 60),
            notes: notesTextField.text,
            reminderTime: selectedReminderTime
        )
        
        // Save to data store
        var appointments = DataStore.shared.loadAppointments()
        appointments.append(appointment)
        DataStore.shared.saveAppointments(appointments)
        
        // Schedule notification
        if let reminderTime = selectedReminderTime {
            NotificationService.shared.scheduleAppointmentReminder(for: appointment)
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

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource

extension AddAppointmentViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == durationPicker {
            return durations.count
        } else if pickerView == reminderPicker {
            return reminderTimes.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == durationPicker {
            let duration = durations[row]
            if duration < 60 {
                return "\(duration) minutes"
            } else {
                let hours = duration / 60
                let minutes = duration % 60
                if minutes == 0 {
                    return "\(hours) hour\(hours > 1 ? "s" : "")"
                } else {
                    return "\(hours) hour\(hours > 1 ? "s" : "") \(minutes) min"
                }
            }
        } else if pickerView == reminderPicker {
            return reminderLabels[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == durationPicker {
            selectedDuration = durations[row]
        } else if pickerView == reminderPicker {
            let minutes = reminderTimes[row]
            selectedReminderTime = minutes > 0 ? TimeInterval(minutes * 60) : nil
        }
    }
}

// MARK: - AppointmentDetailViewController

class AppointmentDetailViewController: UIViewController {
    
    private let appointment: Appointment
    
    init(appointment: Appointment) {
        self.appointment = appointment
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
        title = "Appointment Details"
        view.backgroundColor = .systemGroupedBackground
    }
} 