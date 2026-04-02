import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - UI Elements
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // Секции
    private let sections = ["Внешний вид", "Градиент"]
    
    // Данные для секции "Внешний вид"
    private let appearanceItems = ["Тёмная тема"]
    
    // Данные для секции "Градиент"
    private var gradientItems: [String] = []
    
    private var themeSwitch: UISwitch {
        let uiSwitch = UISwitch()
        uiSwitch.isOn = UserDefaults.standard.bool(forKey: "isDarkMode")
        uiSwitch.addTarget(self, action: #selector(themeSwitchChanged), for: .valueChanged)
        return uiSwitch
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Настройки"
        view.backgroundColor = .systemBackground
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func themeSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isDarkMode")
        let interfaceStyle: UIUserInterfaceStyle = sender.isOn ? .dark : .light
        view.window?.overrideUserInterfaceStyle = interfaceStyle
        NotificationCenter.default.post(name: Notification.Name("ThemeChanged"), object: nil)
    }
    
    @objc private func selectStartColor() {
        showColorPicker(title: "Выберите начальный цвет", key: "startColor", defaultColor: .systemBlue)
    }
    
    @objc private func selectEndColor() {
        showColorPicker(title: "Выберите конечный цвет", key: "endColor", defaultColor: .systemPurple)
    }
    
    @objc private func resetGradient() {
        saveColor(.systemBlue, forKey: "startColor")
        saveColor(.systemPurple, forKey: "endColor")
        NotificationCenter.default.post(name: Notification.Name("GradientChanged"), object: nil)
        tableView.reloadData()
    }
    
    private func showColorPicker(title: String, key: String, defaultColor: UIColor) {
        guard #available(iOS 14.0, *) else {
            let alert = UIAlertController(title: "Ошибка", message: "Выбор цвета доступен с iOS 14", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let currentColor = loadSavedColor(key: key, defaultColor: defaultColor)
        let colorPicker = UIColorPickerViewController()
        colorPicker.title = title
        colorPicker.selectedColor = currentColor
        colorPicker.delegate = self
        colorPicker.supportsAlpha = false
        colorPicker.modalPresentationStyle = .popover
        
        // Сохраняем ключ для использования в делегате
        colorPicker.view.tag = key == "startColor" ? 0 : 1
        
        present(colorPicker, animated: true)
    }
    
    private func loadSavedColor(key: String, defaultColor: UIColor) -> UIColor {
        if let colorData = UserDefaults.standard.data(forKey: key),
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            return color
        }
        return defaultColor
    }
    
    private func saveColor(_ color: UIColor, forKey key: String) {
        if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) {
            UserDefaults.standard.set(colorData, forKey: key)
        }
        // Отправляем уведомление об изменении градиента
        NotificationCenter.default.post(name: Notification.Name("GradientChanged"), object: nil)
    }
    
    private func getCurrentStartColor() -> UIColor {
        return loadSavedColor(key: "startColor", defaultColor: .systemBlue)
    }
    
    private func getCurrentEndColor() -> UIColor {
        return loadSavedColor(key: "endColor", defaultColor: .systemPurple)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return appearanceItems.count
        } else {
            return 3 // начальный цвет, конечный цвет, сброс
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        
        if indexPath.section == 0 {
            // Секция "Внешний вид"
            cell.textLabel?.text = appearanceItems[indexPath.row]
            cell.accessoryView = themeSwitch
        } else {
            // Секция "Градиент"
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Начальный цвет"
                cell.detailTextLabel?.text = ""
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default
                
                // Показываем цветной кружок
                let colorView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                colorView.backgroundColor = getCurrentStartColor()
                colorView.layer.cornerRadius = 15
                colorView.layer.borderWidth = 1
                colorView.layer.borderColor = UIColor.lightGray.cgColor
                cell.accessoryView = colorView
                
            case 1:
                cell.textLabel?.text = "Конечный цвет"
                cell.detailTextLabel?.text = ""
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default
                
                let colorView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                colorView.backgroundColor = getCurrentEndColor()
                colorView.layer.cornerRadius = 15
                colorView.layer.borderWidth = 1
                colorView.layer.borderColor = UIColor.lightGray.cgColor
                cell.accessoryView = colorView
                
            case 2:
                cell.textLabel?.text = "Сбросить на стандартный"
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = .systemRed
                cell.accessoryView = nil
                cell.accessoryType = .none
                cell.selectionStyle = .default
                
            default:
                break
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                selectStartColor()
            case 1:
                selectEndColor()
            case 2:
                resetGradient()
            default:
                break
            }
        }
    }
}

// MARK: - UIColorPickerViewControllerDelegate
extension SettingsViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let selectedColor = viewController.selectedColor
        let isStartColor = viewController.view.tag == 0
        
        if isStartColor {
            saveColor(selectedColor, forKey: "startColor")
        } else {
            saveColor(selectedColor, forKey: "endColor")
        }
        
        NotificationCenter.default.post(name: Notification.Name("GradientChanged"), object: nil)
        tableView.reloadData()
    }
}
