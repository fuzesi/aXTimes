/*
 * "Hello Swift, Goodbye Obj-C."
 * Converted by 'objc2swift'
 *
 * https://github.com/yahoojapan/objc2swift
 */

import UIKit

private enum FirstSectionRowIndex: Int {
    case name = 0
    case code
    case description
    case client
    case defaultComment
    case duration
    case hourlyWage
    case budgetDays
    case remainingBudget
    case timeUnit
    case rounding
    case count
}

class AXDisplayProjectTabeViewCell: UITableViewCell{
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}

class AXDisplayProjectTableViewController: UITableViewController {

    @objc var project: Project?

    private let standardCellIdentifier = String(describing: AXStandardTableViewCell.self)
    private let colorRightSideIdentifier = String(describing: ColorRightSideTableViewCell.self)
    private let cellIdentifier = "Cell"

    override init(style: UITableView.Style) {
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizationConstants.projectDetails
        let rightButton = UIBarButtonItem(barButtonSystemItem: .edit,
                                          target: self,
                                          action: #selector(edit))
        navigationItem.rightBarButtonItem = rightButton
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0

        let standardNib = UINib(nibName: standardCellIdentifier,
                                bundle: nil)
        tableView.register(standardNib,
                           forCellReuseIdentifier: standardCellIdentifier)
        let colorNib = UINib(nibName: colorRightSideIdentifier,
                             bundle: nil)
        tableView.register(colorNib,
                           forCellReuseIdentifier: colorRightSideIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        super.viewWillAppear(animated)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return FirstSectionRowIndex.count.rawValue
        case 1:
            return 1
        case 2:
            var numberOfRows = 0
            if (project?.subProjects?.count ?? 0) > 0 {
                numberOfRows += project?.subProjects?.count ?? 0
            }
            return numberOfRows
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
            cell?.detailTextLabel?.textColor = UIColor.black
        }
        
        

        cell?.selectionStyle = .none
        cell?.accessoryType = .none
        
        cell?.textLabel?.text = ""
        cell?.detailTextLabel?.text = ""
        
        // reset (hide) the checkmark label
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case FirstSectionRowIndex.name.rawValue:
                // swiftlint:disable force_cast
                let colorCell = tableView.dequeueReusableCell(withIdentifier: colorRightSideIdentifier,
                                                                 for: indexPath) as! ColorRightSideTableViewCell
                colorCell.customTextLabel.text = LocalizationConstants.name
                colorCell.customDetailTextLabel.text = project?.name
                colorCell.colorView.backgroundColor = project?.color
                colorCell.selectionStyle = .none
                return colorCell
            case FirstSectionRowIndex.code.rawValue:
                cell?.textLabel?.text = LocalizationConstants.code
                cell?.detailTextLabel?.text = project?.code
            case FirstSectionRowIndex.description.rawValue:
                // swiftlint:disable force_cast
                let standardCell = tableView.dequeueReusableCell(withIdentifier: standardCellIdentifier,
                                                                 for: indexPath) as! AXStandardTableViewCell
                standardCell.customTextLabel.text = LocalizationConstants.description
                standardCell.customDetailTextLabel.text = project?.projectDescription
                return standardCell
            case FirstSectionRowIndex.client.rawValue:
                cell?.textLabel?.text = LocalizationConstants.client
                cell?.detailTextLabel?.text = project?.customer?.displayName
            case FirstSectionRowIndex.defaultComment.rawValue:
                // swiftlint:disable force_cast
                let standardCell = tableView.dequeueReusableCell(withIdentifier: standardCellIdentifier,
                                                                 for: indexPath) as! AXStandardTableViewCell
                standardCell.customTextLabel.text = LocalizationConstants.defaultComment
                standardCell.customDetailTextLabel.text = project?.defaultComment
                return standardCell
            case FirstSectionRowIndex.duration.rawValue:
                cell?.textLabel?.text = LocalizationConstants.duration
                cell?.detailTextLabel?.text = project?.timeRangeDisplayValue
            case FirstSectionRowIndex.hourlyWage.rawValue:
                cell?.textLabel?.text = "\(LocalizationConstants.hourlyWage) (\(SettingsManager().currencyIso))"
                cell?.detailTextLabel?.text = project?.hourlyWage?.stringValueNumberFormatted()
            case FirstSectionRowIndex.budgetDays.rawValue:
                cell?.textLabel?.text = project?.budgetDaysDescription()
                cell?.detailTextLabel?.text = project?.budgetDaysDisplayValue()
            case FirstSectionRowIndex.remainingBudget.rawValue:
                cell?.textLabel?.text = LocalizationConstants.remainingBudget
                cell?.detailTextLabel?.text = project?.remainingBudgetDaysTotalDisplayValue()
            case FirstSectionRowIndex.timeUnit.rawValue:
                cell?.textLabel?.text = LocalizationConstants.timeUnit
                cell?.detailTextLabel?.text = "\(project?.timeUnit?.stringValue ?? "") \(LocalizationConstants.minuteShort)"
            case FirstSectionRowIndex.rounding.rawValue:
                cell?.textLabel?.text = LocalizationConstants.rounding
                if let index = project?.roundingBehaviour?.uintValue,
                    Int(index) <= GlobalConstants.roundingBehaviourNames.count,
                    Int(index) >= 0 {
                    cell?.detailTextLabel?.text = GlobalConstants.roundingBehaviourNames[Int(index)]
                } else {
                    cell?.detailTextLabel?.text = "--"
                }
            default:
                break
            }

        case 1:
            cell?.textLabel?.text = LocalizationConstants.addSubproject
        case 2:
            let numberOfRowsInSection = tableView.numberOfRows(inSection: indexPath.section)
            cell?.selectionStyle = .default
            if indexPath.row != numberOfRowsInSection {
                cell?.textLabel?.text = project?.sortedSubProjects[indexPath.row].name
                cell?.accessoryType = .disclosureIndicator
            }
        default:
            break
        }
        return cell!
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return LocalizationConstants.subprojects
        case 2:
            return nil
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            break
        case 1:
            addSubproject()

        case 2:
            let numberOfRowsInSection = tableView.numberOfRows(inSection: indexPath.section )
            if indexPath.row != numberOfRowsInSection {
                let aXDisplaySubProjectTableViewController = AXDisplaySubProjectTableViewController()
                aXDisplaySubProjectTableViewController.subProject = project?.sortedSubProjects[indexPath.row]
                navigationController?.pushViewController(aXDisplaySubProjectTableViewController,
                                                         animated: true)
            }
        default:
            break

        }
    }

    @objc func edit() {
        let editProjectTableViewController = AXEditProjectTableViewController()
        editProjectTableViewController.project = project
        editProjectTableViewController.controllerTitle = LocalizationConstants.editProject
        editProjectTableViewController.newProject = false
        let navigationController = UINavigationController(rootViewController: editProjectTableViewController)
        navigationController.extendedLayoutIncludesOpaqueBars = true
        present(navigationController,
                animated: true,
                completion: nil)
    }

    @objc func addSubproject() {
        if project?.subProjects?.count == 0, project?.dayEntries?.allObjects.count ?? 0 > 0 {
            let alert = UIAlertController(
                title: LocalizationConstants.warning,
                message: LocalizationConstants.addSubprojectWarning,
                preferredStyle: .alert)

            let okAction = UIAlertAction(
                title: LocalizationConstants.ok,
                style: .default,
                handler: { [weak self] (_) in
                    self?.showEditSubprojectController()
            })
            alert.addAction(okAction)
            present(alert,
                    animated: true,
                    completion: nil)
        } else {
            showEditSubprojectController()
        }
    }

    private func showEditSubprojectController() {
        let editProjectTableViewController = AXEditSubProjectTableViewController()
        editProjectTableViewController.parentProject = self.project
        editProjectTableViewController.subProject = nil
        editProjectTableViewController.controllerTitle = LocalizationConstants.addSubproject
        editProjectTableViewController.newSubProject = true
        let navigationController = UINavigationController(rootViewController: editProjectTableViewController)
        navigationController.extendedLayoutIncludesOpaqueBars = true
        present(navigationController,
                animated: true,
                completion: nil)
    }
}
