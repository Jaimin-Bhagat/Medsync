import UIKit
import MapKit

class DoctorFinderViewController: UIViewController {
    
    private let mapView = MKMapView()
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let segmentedControl = UISegmentedControl(items: ["Map", "List"])
    
    private var doctors: [MKMapItem] = []
    private var selectedSpecialty: String?
    
    private let specialties = [
        "General Practitioner",
        "Cardiologist",
        "Dermatologist",
        "Neurologist",
        "Pediatrician",
        "Psychiatrist",
        "Orthopedist",
        "Gynecologist",
        "Ophthalmologist",
        "Dentist"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSearchBar()
        setupSegmentedControl()
        setupMapView()
        setupTableView()
        requestLocationPermission()
    }
    
    private func setupView() {
        title = "Find Doctor"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add filter button
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(filterTapped))
    }
    
    private func setupSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search by name or specialty"
        searchBar.delegate = self
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupSegmentedControl() {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        view.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        mapView.delegate = self
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DoctorCell.self, forCellReuseIdentifier: "DoctorCell")
        tableView.isHidden = true
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func requestLocationPermission() {
        LocationService.shared.requestLocationPermission()
        
        // Center map on user location
        LocationService.shared.getCurrentLocation { [weak self] location in
            guard let self = self, let location = location else { return }
            
            let region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 2000,
                longitudinalMeters: 2000
            )
            self.mapView.setRegion(region, animated: true)
            
            // Search for doctors nearby
            self.searchNearbyDoctors()
        }
    }
    
    private func searchNearbyDoctors() {
        LocationService.shared.searchNearbyDoctors(specialty: selectedSpecialty) { [weak self] mapItems in
            guard let self = self else { return }
            
            self.doctors = mapItems
            
            // Add annotations to map
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            for doctor in mapItems {
                let annotation = MKPointAnnotation()
                annotation.coordinate = doctor.placemark.coordinate
                annotation.title = doctor.name
                annotation.subtitle = doctor.placemark.thoroughfare
                
                self.mapView.addAnnotation(annotation)
            }
            
            self.tableView.reloadData()
        }
    }
    
    @objc private func filterTapped() {
        let actionSheet = UIAlertController(title: "Filter by Specialty", message: nil, preferredStyle: .actionSheet)
        
        // Add all specialties
        for specialty in specialties {
            actionSheet.addAction(UIAlertAction(title: specialty, style: .default) { [weak self] _ in
                self?.selectedSpecialty = specialty
                self?.searchNearbyDoctors()
            })
        }
        
        // Add "All" option
        actionSheet.addAction(UIAlertAction(title: "All Doctors", style: .default) { [weak self] _ in
            self?.selectedSpecialty = nil
            self?.searchNearbyDoctors()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            // Map view
            mapView.isHidden = false
            tableView.isHidden = true
        } else {
            // List view
            mapView.isHidden = true
            tableView.isHidden = false
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension DoctorFinderViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doctors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorCell", for: indexPath) as? DoctorCell else {
            return UITableViewCell()
        }
        
        let doctor = doctors[indexPath.row]
        cell.configure(with: doctor)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let doctor = doctors[indexPath.row]
        let detailVC = DoctorDetailViewController(doctor: doctor)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// MARK: - UISearchBarDelegate

extension DoctorFinderViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        selectedSpecialty = searchText
        searchNearbyDoctors()
        searchBar.resignFirstResponder()
    }
}

// MARK: - MKMapViewDelegate

extension DoctorFinderViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't customize user location
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "DoctorAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            // Add info button
            let infoButton = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = infoButton
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation else { return }
        
        // Find the doctor that matches this annotation
        if let doctor = doctors.first(where: { $0.name == annotation.title && $0.placemark.thoroughfare == annotation.subtitle }) {
            let detailVC = DoctorDetailViewController(doctor: doctor)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

// MARK: - DoctorCell

class DoctorCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let addressLabel = UILabel()
    private let distanceLabel = UILabel()
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
        iconImageView.image = UIImage(systemName: "stethoscope")
        contentView.addSubview(iconImageView)
        
        // Name label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        contentView.addSubview(nameLabel)
        
        // Address label
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.font = UIFont.systemFont(ofSize: 14)
        addressLabel.textColor = .secondaryLabel
        addressLabel.numberOfLines = 2
        contentView.addSubview(addressLabel)
        
        // Distance label
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.font = UIFont.systemFont(ofSize: 14)
        distanceLabel.textColor = .secondaryLabel
        contentView.addSubview(distanceLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            
            nameLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            addressLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            addressLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            addressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            distanceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            distanceLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 4),
            distanceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            distanceLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with doctor: MKMapItem) {
        nameLabel.text = doctor.name
        
        // Format address
        var addressComponents: [String] = []
        if let thoroughfare = doctor.placemark.thoroughfare {
            addressComponents.append(thoroughfare)
        }
        if let subThoroughfare = doctor.placemark.subThoroughfare {
            addressComponents.insert(subThoroughfare, at: 0)
        }
        if let locality = doctor.placemark.locality {
            addressComponents.append(locality)
        }
        if let administrativeArea = doctor.placemark.administrativeArea {
            addressComponents.append(administrativeArea)
        }
        
        addressLabel.text = addressComponents.joined(separator: ", ")
        
        // Calculate distance
        if let userLocation = LocationService.shared.locationManager.location {
            let distance = userLocation.distance(from: doctor.placemark.location!)
            let distanceInMiles = distance / 1609.34 // Convert meters to miles
            
            if distanceInMiles < 0.1 {
                distanceLabel.text = "Less than 0.1 miles away"
            } else {
                distanceLabel.text = String(format: "%.1f miles away", distanceInMiles)
            }
        } else {
            distanceLabel.text = "Distance unknown"
        }
    }
}

// MARK: - DoctorDetailViewController

class DoctorDetailViewController: UIViewController {
    
    private let doctor: MKMapItem
    private let mapView = MKMapView()
    private let infoCard = MedSyncCardView()
    private let nameLabel = UILabel()
    private let addressLabel = UILabel()
    private let phoneButton = MedSyncButton(title: "Call", style: .primary)
    private let directionsButton = MedSyncButton(title: "Directions", style: .secondary)
    private let saveButton = MedSyncButton(title: "Save to Favorites", style: .secondary)
    
    init(doctor: MKMapItem) {
        self.doctor = doctor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupMapView()
        setupInfoCard()
        setupButtons()
    }
    
    private func setupView() {
        title = doctor.name
        view.backgroundColor = .systemBackground
    }
    
    private func setupMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
        
        // Add annotation for the doctor
        let annotation = MKPointAnnotation()
        annotation.coordinate = doctor.placemark.coordinate
        annotation.title = doctor.name
        mapView.addAnnotation(annotation)
        
        // Set region
        let region = MKCoordinateRegion(
            center: doctor.placemark.coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        mapView.setRegion(region, animated: false)
    }
    
    private func setupInfoCard() {
        infoCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoCard)
        
        NSLayoutConstraint.activate([
            infoCard.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20),
            infoCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            infoCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        
        // Name label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        nameLabel.text = doctor.name
        infoCard.addSubview(nameLabel)
        
        // Address label
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.font = UIFont.systemFont(ofSize: 16)
        addressLabel.textColor = .secondaryLabel
        addressLabel.numberOfLines = 0
        
        // Format address
        var addressComponents: [String] = []
        if let thoroughfare = doctor.placemark.thoroughfare {
            addressComponents.append(thoroughfare)
        }
        if let subThoroughfare = doctor.placemark.subThoroughfare {
            addressComponents.insert(subThoroughfare, at: 0)
        }
        if let locality = doctor.placemark.locality {
            addressComponents.append(locality)
        }
        if let administrativeArea = doctor.placemark.administrativeArea {
            addressComponents.append(administrativeArea)
        }
        if let postalCode = doctor.placemark.postalCode {
            addressComponents.append(postalCode)
        }
        
        addressLabel.text = addressComponents.joined(separator: ", ")
        infoCard.addSubview(addressLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
            
            addressLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            addressLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            addressLabel.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
        ])
    }
    
    private func setupButtons() {
        phoneButton.translatesAutoresizingMaskIntoConstraints = false
        directionsButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        phoneButton.addTarget(self, action: #selector(callTapped), for: .touchUpInside)
        directionsButton.addTarget(self, action: #selector(directionsTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        infoCard.addSubview(phoneButton)
        infoCard.addSubview(directionsButton)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            phoneButton.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 24),
            phoneButton.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            phoneButton.trailingAnchor.constraint(equalTo: infoCard.centerXAnchor, constant: -8),
            
            directionsButton.topAnchor.constraint(equalTo: phoneButton.topAnchor),
            directionsButton.leadingAnchor.constraint(equalTo: infoCard.centerXAnchor, constant: 8),
            directionsButton.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
            directionsButton.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -16),
            
            saveButton.topAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    @objc private func callTapped() {
        guard let phoneNumber = doctor.phoneNumber else {
            let alert = UIAlertController(title: "No Phone Number", message: "This doctor does not have a phone number listed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let formattedNumber = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if let url = URL(string: "tel://\(formattedNumber)") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func directionsTapped() {
        // Open in Maps app
        MKMapItem.openMaps(with: [doctor], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    @objc private func saveTapped() {
        // Save doctor to favorites
        let alert = UIAlertController(title: "Doctor Saved", message: "This doctor has been saved to your favorites.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        // TODO: Implement actual saving functionality
    }
}

// MARK: - MKMapViewDelegate

extension DoctorDetailViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "DoctorAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
} 