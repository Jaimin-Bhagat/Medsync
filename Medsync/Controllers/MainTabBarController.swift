import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }
    
    private func setupTabBar() {
        tabBar.tintColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
        tabBar.backgroundColor = .white
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func setupViewControllers() {
        // Medications Tab
        let medicationsVC = MedicationsViewController()
        let medicationsNav = UINavigationController(rootViewController: medicationsVC)
        medicationsNav.tabBarItem = UITabBarItem(title: "Medications", image: UIImage(systemName: "pill"), tag: 0)
        
        // Appointments Tab
        let appointmentsVC = AppointmentsViewController()
        let appointmentsNav = UINavigationController(rootViewController: appointmentsVC)
        appointmentsNav.tabBarItem = UITabBarItem(title: "Appointments", image: UIImage(systemName: "calendar"), tag: 1)
        
        // Health Records Tab
        let healthRecordsVC = HealthRecordsViewController()
        let healthRecordsNav = UINavigationController(rootViewController: healthRecordsVC)
        healthRecordsNav.tabBarItem = UITabBarItem(title: "Records", image: UIImage(systemName: "heart.text.square"), tag: 2)
        
        // Doctor Finder Tab
        let doctorFinderVC = DoctorFinderViewController()
        let doctorFinderNav = UINavigationController(rootViewController: doctorFinderVC)
        doctorFinderNav.tabBarItem = UITabBarItem(title: "Find Doctor", image: UIImage(systemName: "stethoscope"), tag: 3)
        
        // Health Reminders Tab
        let healthRemindersVC = HealthRemindersViewController()
        let healthRemindersNav = UINavigationController(rootViewController: healthRemindersVC)
        healthRemindersNav.tabBarItem = UITabBarItem(title: "Reminders", image: UIImage(systemName: "bell"), tag: 4)
        
        viewControllers = [
            medicationsNav,
            appointmentsNav,
            healthRecordsNav,
            doctorFinderNav,
            healthRemindersNav
        ]
    }
} 