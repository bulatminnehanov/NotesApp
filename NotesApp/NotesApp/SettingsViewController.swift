import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - UI Elements
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private let themeIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "moon")
        iv.tintColor = .systemBlue
        iv.contentMode = .scaleAspectFit
        iv.widthAnchor.constraint(equalToConstant: 24).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return iv
    }()
    
    private let themeSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.addTarget(self, action: #selector(themeSwitchChanged), for: .valueChanged)
        return uiSwitch
    }()
    
    private let themeLabel: UILabel = {
        let label = UILabel()
        label.text = "Тёмная тема"
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    private let themeRow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSettings()
        applyTheme(isDarkMode: themeSwitch.isOn)
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Настройки"
        view.backgroundColor = .systemBackground
        
        view.addSubview(stackView)
        themeRow.insertArrangedSubview(themeIcon, at: 0)
        themeRow.addArrangedSubview(themeLabel)
        themeRow.addArrangedSubview(themeSwitch)
        
        stackView.addArrangedSubview(themeRow)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func loadSettings() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        themeSwitch.isOn = isDarkMode
        applyTheme(isDarkMode: isDarkMode)
    }
    
    // MARK: - Actions
    @objc private func themeSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isDarkMode")
        applyTheme(isDarkMode: sender.isOn)
    }
    
    private func applyTheme(isDarkMode: Bool) {
        let interfaceStyle: UIUserInterfaceStyle = isDarkMode ? .dark : .light
            view.window?.overrideUserInterfaceStyle = interfaceStyle
            
            // Отправляем уведомление всем экранам
            NotificationCenter.default.post(name: Notification.Name("ThemeChanged"), object: nil)
    }
}
