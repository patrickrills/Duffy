//
//  HistoryView.swift
//  Duffy
//
//  Created by Patrick Rills on 9/7/26.
//  Copyright © 2026 Big Blue Fly. All rights reserved.
//

import SwiftUI
import DuffyFramework

struct HistoryView: View {
    
    private enum Constants {
        static let CHART_HEIGHT: CGFloat = 180.0
        static let CHART_MARGIN: CGFloat = 11.0
        static let HEADER_FONT_SIZE: CGFloat = 22.0
        static let CLOSE_SYMBOL_SIZE: CGFloat = 24.0
        static let DROPDOWN_SPACING: CGFloat = 4.0
    }
    
    //MARK: Properties and State
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = HistoryViewModel()
    @State private var isLoading: Bool = false
    @State private var hasLoaded: Bool = false
    @State private var chartOptionsVersion: Int = 0
    @State private var filterDate: Date?
    
    //MARK: Body
    
    var body: some View {
        NavigationStack {
            historyList
        }
        .tint(navigationTint)
    }
    
    private var historyList: some View {
        List {
            chartSection
            summarySection
            detailsSection
        }
            .listStyle(.insetGrouped)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $filterDate) { selectedDate in
                HistoryFilterView(selectedDate: selectedDate) { updatedDate in
                    filterDate = nil
                    load { await viewModel.updateDateFilter(updatedDate) }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    closeButton
                }
                
                ToolbarItem(placement: .principal) {
                    dropdownHeader
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: showFilter) {
                        Image(systemName: "calendar")
                            .fontWeight(.medium)
                    }
                }
            }
            .task {
                await initialLoad()
            }
    }
    
    //The navigation controller this screen used to be presented in only tinted itself before iOS 26
    private var navigationTint: Color? {
        if #available(iOS 26.0, *) {
            return nil
        }
        
        return Color(uiColor: Globals.secondaryColor())
    }
    
    @ViewBuilder
    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            if #available(iOS 26.0, *) {
                Image(systemName: "xmark")
            } else {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: Constants.CLOSE_SYMBOL_SIZE))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color(uiColor: Globals.secondaryColor()), Color(uiColor: .tertiarySystemFill))
            }
        }
    }
    
    //MARK: Sections
    
    private var chartSection: some View {
        Section {
            HistoryTrendChart(values: viewModel.filteredValues, goal: viewModel.goal, optionsVersion: chartOptionsVersion)
                .frame(height: Constants.CHART_HEIGHT)
                .listRowInsets(EdgeInsets(top: Constants.CHART_MARGIN, leading: 0.0, bottom: Constants.CHART_MARGIN, trailing: 0.0))
        } header: {
            header(NSLocalizedString("Trend", comment: "")) {
                Menu {
                    Section(NSLocalizedString("Lines", comment: "Title of section of options to change how the lines on a chart are drawn")) {
                        chartOptionToggle(.actualDataLine)
                        chartOptionToggle(.trendLine)
                    }
                    
                    Section(NSLocalizedString("Indicators", comment: "Title of section of options changing which markers are shown on a chart/graph")) {
                        if viewModel.goal != nil {
                            chartOptionToggle(.goalIndicator)
                        }
                        chartOptionToggle(.averageIndicator)
                    }
                } label: {
                    Text(NSLocalizedString("Options", comment: "Title of a button that changes display options of a chart"))
                }
            }
        }
    }
    
    private var summarySection: some View {
        Section {
            HistorySummaryView(values: viewModel.filteredValues, dataType: viewModel.dataType)
        } header: {
            header(NSLocalizedString("Summary", comment: "Header of a section that summarizes aggregate data")) {
                EmptyView()
            }
        }
    }
    
    private var detailsSection: some View {
        Section {
            ForEach(Array(0..<viewModel.detailCount), id: \.self) { index in
                if let detail = viewModel.detail(at: index) {
                    HistoryDetailRow(detail: detail)
                }
            }
        } header: {
            header(NSLocalizedString("Details", comment: "")) {
                Menu {
                    Picker(selection: sortBinding) {
                        ForEach(DetailSortOption.allCases, id: \.self) { option in
                            Label(option.menuOptionText(), systemImage: option.symbolName())
                                .tag(option)
                        }
                    } label: {
                        EmptyView()
                    }
                    .pickerStyle(.inline)
                } label: {
                    sortLabel
                }
            }
        } footer: {
            if !viewModel.isLoadMoreHidden && viewModel.canLoadMore {
                HStack {
                    Button(NSLocalizedString("Show More", comment: "")) {
                        loadNextPage()
                    }
                    .foregroundStyle(Color(uiColor: Globals.secondaryColor()))
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 20.0)
            }
        }
    }
    
    //MARK: Section headers and menus
    
    private func header<Action: View>(_ text: String, @ViewBuilder action: () -> Action) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(text)
                .font(.system(size: Constants.HEADER_FONT_SIZE, weight: .bold))
                .foregroundStyle(Color(uiColor: .label))
                .textCase(nil)
            
            Spacer()
            
            action()
                .font(.system(size: UIFont.labelFontSize))
                .foregroundStyle(Color(uiColor: Globals.secondaryColor()))
                .textCase(nil)
        }
    }
    
    private var sortLabel: Text {
        return Text(String(format: "%@ ", NSLocalizedString("Sort", comment: ""))) + Text(Image(systemName: viewModel.sort.symbolName()))
    }
    
    private var sortBinding: Binding<DetailSortOption> {
        return Binding(get: { viewModel.sort }, set: { viewModel.sort = $0 })
    }
    
    private func chartOptionToggle(_ option: HistoryTrendChartOption) -> some View {
        let isEnabled = Binding(get: { option.isEnabled() },
                                set: { enabled in
                                    option.setEnabled(enabled)
                                    chartOptionsVersion += 1
                                })
        
        return Toggle(isOn: isEnabled) {
            Label(option.displayName(), systemImage: option.symbolName())
        }
    }
    
    //MARK: Data type selection
    
    private var isDataTypeSelectable: Bool {
        return DebugService.isDebugModeEnabled()
    }
    
    private var headerSubtitle: String {
        return isLoading ? viewModel.loadingTitle : viewModel.title
    }
    
    @ViewBuilder
    private var dropdownHeader: some View {
        VStack(spacing: 0.0) {
            if isDataTypeSelectable {
                Menu {
                    dataTypeOptions
                } label: {
                    HStack(spacing: Constants.DROPDOWN_SPACING) {
                        Text(viewModel.dataTypeName)
                            .font(.headline)
                            .foregroundStyle(Color(uiColor: .label))
                        
                        Image(systemName: "chevron.down.circle.fill")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color(uiColor: Globals.secondaryColor()), Color(.systemGray5))
                    }
                }
            } else {
                Text(viewModel.dataTypeName)
                    .font(.headline)
                    .foregroundStyle(Color(uiColor: .label))
            }
            
            Text(headerSubtitle)
                .font(.subheadline)
                .foregroundStyle(Color(uiColor: .secondaryLabel))
        }
    }
    
    @ViewBuilder
    private var dataTypeOptions: some View {
        ForEach(HistoryDataType.allCases, id: \.self) { dataType in
            let isSelected = dataType == viewModel.dataType
            Button {
                changeDataType(dataType)
            } label: {
                Label(isSelected ? viewModel.dataTypeName : dataType.displayName(), systemImage: isSelected ? "checkmark" : dataType.symbolName())
            }
        }
    }
    
    //MARK: Event handlers
    
    private func initialLoad() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        isLoading = true
        
        if !DebugService.isDebugModeEnabled() {
            await viewModel.changeDataType(.steps)
        }
        
        await viewModel.loadNextPage()
        isLoading = false
    }
    
    private func showFilter() {
        filterDate = viewModel.currentFilterDate
    }
    
    private func loadNextPage() {
        load { await viewModel.loadNextPage() }
    }
    
    private func changeDataType(_ dataType: HistoryDataType) {
        load { await viewModel.changeDataType(dataType) }
    }
    
    private func load(_ work: @escaping () async -> ()) {
        isLoading = true
        
        Task {
            await work()
            isLoading = false
        }
    }
}

//MARK: Rows

private struct HistoryDetailRow: View {
    
    let detail: HistoryDetail
    
    var body: some View {
        LabeledContent {
            Text(Globals.dayFormatter().string(from: detail.date))
        } label: {
            Text(String(format: "%@ %@", detail.value, detail.trophy.symbol()).trimmingCharacters(in: .whitespaces))
                .fontWeight(detail.trophy != .none ? .bold : .regular)
                .foregroundStyle(Color(uiColor: .label))
        }
    }
}

//MARK: UIKit views reused by this screen

private struct HistoryTrendChart: UIViewRepresentable {
    
    let values: [Date : Double]
    let goal: Double?
    let optionsVersion: Int
    
    func makeUIView(context: Context) -> HistoryTrendChartView {
        let chart = HistoryTrendChartView()
        chart.backgroundColor = .clear
        return chart
    }
    
    func updateUIView(_ chart: HistoryTrendChartView, context: Context) {
        chart.goal = goal
        chart.dataSet = values
        chart.setNeedsDisplay()
    }
}
