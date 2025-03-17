import UIKit

class HealthRemindersViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let addButton = MedSyncButton(title: "Add Reminder", style: .primary)
    private var reminders: [HealthReminder] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        setupAddButton()
        loadReminders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadReminders()
        tableView.reloadData()
    }
    
    private func setupView() {
        title = "Health Reminders"
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
        tableView.register(ReminderCell.self, forCellReuseIdentifier: "ReminderCell")
    }
    
    private func setupAddButton() {
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        addButton.addTarget(self, action: #selector(addReminderTapped), for: .touchUpInside)
    }
    
    private func loadReminders() {
        reminders = DataStore.shared.loadHealthReminders()
        
        // Sort reminders by due date
        reminders.sort { $0.dueDate < $1.dueDate }
    }
    
    @objc private func addReminderTapped() {
        let addReminderVC = AddReminderViewController()
        let navigationController = UINavigationController(rootViewController: addReminderVC)
        present(navigationController, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension HealthRemindersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Upcoming" : "Completed"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let upcomingReminders = reminders.filter { $0.status != .completed }
        let completedReminders = reminders.filter { $0.status == .completed }
        
        return section == 0 ? upcomingReminders.count : completedReminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as? ReminderCell else {
            return UITableViewCell()
        }
        
        let upcomingReminders = reminders.filter { $0.status != .completed }
        let completedReminders = reminders.filter { $0.status == .completed }
        
        let reminder = indexPath.section == 0 ? upcomingReminders[indexPath.row] : completedReminders[indexPath.row]
        cell.configure(with: reminder)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let upcomingReminders = reminders.filter { !$0.completed }
        let completedReminders = reminders.filter { $0.completed }
        
        let reminder = indexPath.section == 0 ? upcomingReminders[indexPath.row] : completedReminders[indexPath.row]
        let detailVC = ReminderDetailViewController(reminder: reminder)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let upcomingReminders = reminders.filter { !$0.completed }
        let completedReminders = reminders.filter { $0.completed }
        
        var reminder = indexPath.section == 0 ? upcomingReminders[indexPath.row] : completedReminders[indexPath.row]
        
        // Complete/Uncomplete action
        let completeTitle = reminder.completed ? "Mark Incomplete" : "Complete"
        let completeAction = UIContextualAction(style: .normal, title: completeTitle) { [weak self] (_, _, completion) in
            guard let self = self else { return }
            
            // Toggle completed status
            reminder.completed = !reminder.completed
            
            // Update in data store
            if let index = self.reminders.firstIndex(where: { $0.id == reminder.id }) {
                self.reminders[index] = reminder
                DataStore.shared.saveHealthReminders(self.reminders)
            }
            
            // Reload table
            self.tableView.reloadData()
            
            completion(true)
        }
        completeAction.backgroundColor = reminder.completed ? .systemOrange : .systemGreen
        
        // Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            
            // Remove from data store
            self.reminders.removeAll { $0.id == reminder.id }
            DataStore.shared.saveHealthReminders(self.reminders)
            
            // Reload table
            self.tableView.reloadData()
            
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction, completeAction])
    }
}

// MARK: - ReminderCell

class ReminderCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let categoryLabel = UILabel()
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
        accessoryType = .disclosureIndicator
        
        statusIndicator.translatesAutoresizingMaskIntoConstraints = false
        statusIndicator.layer.cornerRadius = 8
        contentView.addSubview(statusIndicator)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        contentView.addSubview(titleLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .secondaryLabel
        contentView.addSubview(dateLabel)
        
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.font = UIFont.systemFont(ofSize: 14)
        categoryLabel.textColor = .secondaryLabel
        contentView.addSubview(categoryLabel)
        
        NSLayoutConstraint.activate([
            statusIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusIndicator.widthAnchor.constraint(equalToConstant: 16),
            statusIndicator.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.leadingAnchor.constraint(equalTo: statusIndicator.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            categoryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            categoryLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            categoryLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with reminder: HealthReminder) {
        titleLabel.text = reminder.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateLabel.text = "Due: \(dateFormatter.string(from: reminder.dueDate))"
        
        categoryLabel.text = reminder.category.displayName
        
        if reminder.completed {
            statusIndicator.backgroundColor = .systemGreen
            titleLabel.textColor = .secondaryLabel
        } else {
            // Check if overdue
            if reminder.dueDate < Date() {
                statusIndicator.backgroundColor = .systemRed
            } else {
                statusIndicator.backgroundColor = .systemBlue
            }
            titleLabel.textColor = .label
        }
    }
}

// MARK: - AddReminderViewController

class AddReminderViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleTextField = MedSyncTextField(placeholder: "Reminder Title")
    private let descriptionTextField = MedSyncTextField(placeholder: "Description")
    
    private let categoryLabel = UILabel()
    private let categoryPicker = UIPickerView()
    
    private let dateLabel = UILabel()
    private let datePicker = UIDatePicker()
    
    private let recurrenceLabel = UILabel()
    private let recurrenceSwitch = UISwitch()
    private let recurrencePicker = UIPickerView()
    
    private let saveButton = MedSyncButton(title: "Save Reminder", style: .primary)
    private let cancelButton = MedSyncButton(title: "Cancel", style: .secondary)
    
    private let categories = HealthReminderCategory.allCases
    private let recurrenceOptions = ["None", "Daily", "Weekly", "Monthly", "Yearly"]
    
    private var selectedCategory = HealthReminderCategory.generalCheckup
    private var selectedRecurrence: RecurrencePattern?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScrollView()
        setupTextFields()
        setupCategorySection()
        setupDateSection()
        setupRecurrenceSection()
        setupButtons()
    }
    
    private func setupView() {
        title = "Add Health Reminder"
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
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
        contentView.addSubview(descriptionTextField)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            descriptionTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    private func setupCategorySection() {
        categoryLabel.text = "Category"
        categoryLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        categoryPicker.translatesAutoresizingMaskIntoConstraints = false
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        contentView.addSubview(categoryLabel)
        contentView.addSubview(categoryPicker)
        
        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 24),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            categoryPicker.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8),
            categoryPicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            categoryPicker.heightAnchor.constraint(equalToConstant: 120),
        ])
    }
    
    private func setupDateSection() {
        dateLabel.text = "Due Date"
        dateLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        
        contentView.addSubview(dateLabel)
        contentView.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: categoryPicker.bottomAnchor, constant: 24),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            datePicker.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    private func setupRecurrenceSection() {
        recurrenceLabel.text = "Recurring"
        recurrenceLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        recurrenceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        recurrenceSwitch.translatesAutoresizingMaskIntoConstraints = false
        recurrenceSwitch.addTarget(self, action: #selector(recurrenceSwitchChanged), for: .valueChanged)
        
        recurrencePicker.translatesAutoresizingMaskIntoConstraints = false
        recurrencePicker.delegate = self
        recurrencePicker.dataSource = self
        recurrencePicker.isHidden = true
        
        contentView.addSubview(recurrenceLabel)
        contentView.addSubview(recurrenceSwitch)
        contentView.addSubview(recurrencePicker)
        
        NSLayoutConstraint.activate([
            recurrenceLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 24),
            recurrenceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            recurrenceSwitch.centerYAnchor.constraint(equalTo: recurrenceLabel.centerYAnchor),
            recurrenceSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            recurrencePicker.topAnchor.constraint(equalTo: recurrenceLabel.bottomAnchor, constant: 8),
            recurrencePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recurrencePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            recurrencePicker.heightAnchor.constraint(equalToConstant: 120),
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
            saveButton.topAnchor.constraint(equalTo: recurrencePicker.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func recurrenceSwitchChanged() {
        recurrencePicker.isHidden = !recurrenceSwitch.isOn
        
        if recurrenceSwitch.isOn {
            // Default to weekly
            recurrencePicker.selectRow(2, inComponent: 0, animated: false)
            selectedRecurrence = .weekly(daysOfWeek: [Calendar.current.component(.weekday, from: Date())])
        } else {
            selectedRecurrence = nil
        }
    }
    
    @objc private func saveTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(message: "Please enter a reminder title")
            return
        }
        
        // Create reminder
        let reminder = HealthReminder(
            title: title,
            description: descriptionTextField.text ?? "",
            dueDate: datePicker.date,
            completed: false,
            category: selectedCategory,
            recurrence: selectedRecurrence,
            notes: nil
        )
        
        // Save to data store
        var reminders = DataStore.shared.loadHealthReminders()
        reminders.append(reminder)
        DataStore.shared.saveHealthReminders(reminders)
        
        // Schedule notification
        NotificationService.shared.scheduleHealthReminder(for: reminder)
        
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

extension AddReminderViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == categoryPicker {
            return categories.count
        } else if pickerView == recurrencePicker {
            return recurrenceOptions.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == categoryPicker {
            return categories[row].displayName
        } else if pickerView == recurrencePicker {
            return recurrenceOptions[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == categoryPicker {
            selectedCategory = categories[row]
        } else if pickerView == recurrencePicker {
            switch row {
            case 0: // None
                selectedRecurrence = nil
            case 1: // Daily
                selectedRecurrence = .daily
            case 2: // Weekly
                selectedRecurrence = .weekly(daysOfWeek: [Calendar.current.component(.weekday, from: Date())])
            case 3: // Monthly
                selectedRecurrence = .monthly(dayOfMonth: Calendar.current.component(.day, from: Date()))
            case 4: // Yearly
                let month = Calendar.current.component(.month, from: Date())
                let day = Calendar.current.component(.day, from: Date())
                selectedRecurrence = .yearly(month: month, day: day)
            default:
                selectedRecurrence = nil
            }
        }
    }
}

// MARK: - ReminderDetailViewController

class ReminderDetailViewController: UIViewController {
    
    private let reminder: HealthReminder
    
    init(reminder: HealthReminder) {
        self.reminder = reminder
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
        title = "Reminder Details"
        view.backgroundColor = .systemGroupedBackground
    }
} 