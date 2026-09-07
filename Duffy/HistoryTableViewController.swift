//
//  WeekViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 1/22/17.
//  Copyright © 2017 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class HistoryTableViewController: UITableViewController {

    private enum Constants {
        static let FOOTER_HEIGHT: CGFloat = 80.0
        static let FOOTER_MARGIN: CGFloat = 16.0
        static let MINIMUM_HEIGHT: CGFloat = 0.1
    }
    
    //MARK: Properties and State
    
    private let viewModel = HistoryViewModel()
    private var dataTypeItem: UIBarButtonItem?
    
    //MARK: Constructors
    
    init() {
        super.init(style: Globals.tableViewStyle())
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(style: Globals.tableViewStyle())
        self.modalPresentationStyle = .fullScreen
    }
    
    //MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filterItem = UIBarButtonItem(image: UIImage(systemName: "calendar", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), style: .plain, target: self, action: #selector(changeFilter))
        
        var rightItems: [UIBarButtonItem] = [filterItem]
        if DebugService.isDebugModeEnabled() {
            let dataTypeItem = UIBarButtonItem(image: dataTypeImage(), menu: dataTypeMenu())
            rightItems.append(dataTypeItem)
            self.dataTypeItem = dataTypeItem
        } else {
            changeDataType(.steps)
        }
        navigationItem.rightBarButtonItems = rightItems
        
        tableView.estimatedSectionHeaderHeight = BoldActionSectionHeaderView.estimatedHeight
        tableView.register(BoldActionSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: String(describing: BoldActionSectionHeaderView.self))
        tableView.register(PreviousValueTableViewCell.self, forCellReuseIdentifier: String(describing: PreviousValueTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: HistoryTrendChartTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: HistoryTrendChartTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: HistorySummaryTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: HistorySummaryTableViewCell.self))
        clearsSelectionOnViewWillAppear = true
        
        loadNextPage()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutFooter()
    }
    
    private func layoutFooter() {
        var footer: UIView?
        
        if let existingFooter = tableView.tableFooterView {
            footer = existingFooter
        } else {
            let newFooter = HistoryTableViewFooter()
            newFooter.addTarget(self, action: #selector(loadMorePressed))
            tableView.tableFooterView = newFooter
            footer = newFooter
        }
        
        if let footer = footer {
            footer.frame = CGRect(x: footer.frame.origin.x, y: footer.frame.origin.y, width: tableView.frame.size.width, height: Constants.FOOTER_HEIGHT)
        }
        
        footer?.isHidden = viewModel.isLoadMoreHidden
    }
    
    //MARK: Event handlers
    
    @IBAction private func changeFilter() {
        navigationController?.pushViewController(HistoryFilterTableViewController(selectedDate: viewModel.currentFilterDate, onDateSelected: { [weak self] in self?.updateDateFilter($0) }), animated: true)
    }
    
    @IBAction func loadMorePressed() {
        loadNextPage()
    }
    
    private func dataTypeImage() -> UIImage? {
        return UIImage(systemName: viewModel.dataType.symbolName(), withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
    }
    
    private func dataTypeMenu() -> UIMenu {
        let menuActions = HistoryDataType.allCases.map { dataType in
            let isSelected = dataType == viewModel.dataType
            let title = isSelected ? viewModel.dataTypeName : dataType.displayName()
            return UIAction(title: title, image: UIImage(systemName: dataType.symbolName()), identifier: UIAction.Identifier(dataType.rawValue), state: isSelected ? .on : .off) { [weak self] action in
                if let selectedDataType = HistoryDataType(rawValue: action.identifier.rawValue) {
                    self?.changeDataType(selectedDataType)
                }
            }
        }
        
        return UIMenu(title: "", children: menuActions)
    }
    
    private func changeDataType(_ dataType: HistoryDataType) {
        title = viewModel.loadingTitle
        
        Task {
            await viewModel.changeDataType(dataType)
            refresh()
        }
    }
    
    private func loadNextPage() {
        title = viewModel.loadingTitle
        
        Task {
            await viewModel.loadNextPage()
            refresh()
        }
    }
    
    private func updateDateFilter(_ filterDate: Date) {
        title = viewModel.loadingTitle
        
        Task {
            await viewModel.updateDateFilter(filterDate)
            refresh()
        }
    }
    
    private func refresh() {
        title = viewModel.title
        dataTypeItem?.image = dataTypeImage()
        dataTypeItem?.menu = dataTypeMenu()
        tableView.reloadData()
        
        if let footer = tableView.tableFooterView as? HistoryTableViewFooter {
            footer.isButtonHidden = !viewModel.canLoadMore
        }
    }
    
    //MARK: Table view datasource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return HistorySection.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch HistorySection(rawValue: section) {
        case .details:
            return viewModel.detailCount
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch HistorySection(rawValue: indexPath.section) {
        case .chart:
            let graphCell = tableView.dequeueReusableCell(withIdentifier: String(describing: HistoryTrendChartTableViewCell.self), for: indexPath) as! HistoryTrendChartTableViewCell
            graphCell.bind(to: viewModel.filteredValues, goal: viewModel.goal)
            return graphCell
        case .summary:
            let summaryCell = tableView.dequeueReusableCell(withIdentifier: String(describing: HistorySummaryTableViewCell.self), for: indexPath) as! HistorySummaryTableViewCell
            summaryCell.bind(to: viewModel.filteredValues, dataType: viewModel.dataType)
            return summaryCell
        case .details:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PreviousValueTableViewCell.self), for: indexPath) as! PreviousValueTableViewCell
            if let detail = viewModel.detail(at: indexPath.row) {
                cell.bind(to: detail.date, value: detail.value, trophy: detail.trophy)
            }
            return cell
        default:
            fatalError("Unexpected section")
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: BoldActionSectionHeaderView.self)) as? BoldActionSectionHeaderView,
              let historySection = HistorySection(rawValue: section)
        else {
            return nil
        }
        
        let sectionTitle: String
        var actionTitle: NSAttributedString?
        
        switch historySection {
        case .chart:
            sectionTitle = NSLocalizedString("Trend", comment: "")
            actionTitle = NSAttributedString(string: NSLocalizedString("Options", comment: "Title of a button that changes display options of a chart"))
        case .summary:
            sectionTitle = NSLocalizedString("Summary", comment: "Header of a section that summarizes aggregate data")
        case .details:
            sectionTitle = NSLocalizedString("Details", comment: "")
            actionTitle = viewModel.sort.displayText()
        }
        
        header.set(headerText: sectionTitle, actionAttributedText: actionTitle, menu: historySection.optionsMenu(handler: self))
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard section == numberOfSections(in: tableView) - 1 else {
            return Constants.FOOTER_MARGIN
        }
        
        return Constants.MINIMUM_HEIGHT
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == numberOfSections(in: tableView) - 1 else {
            return nil
        }
        
        return UIView()
    }
}

extension HistoryTableViewController: HistorySectionOptionHandler {
    
    func isDetailSortOptionEnabled(_ option: DetailSortOption) -> Bool {
        return viewModel.sort == option
    }
    
    func handleDetailSortOption(_ option: DetailSortOption) {
        guard viewModel.sort != option else { return }
        
        viewModel.sort = option
        tableView.reloadSections(IndexSet(integer: HistorySection.details.rawValue), with: .automatic)
    }
    
    func isHistoryTrendChartOptionAvailable(_ option: HistoryTrendChartOption) -> Bool {
        guard option == .goalIndicator else { return true }
        return viewModel.goal != nil
    }
    
    func handleHistoryTrendChartOption(_ option: HistoryTrendChartOption) {
        option.setEnabled(!option.isEnabled())
        tableView.reloadSections(IndexSet(integer: HistorySection.chart.rawValue), with: .fade)
    }
    
}
