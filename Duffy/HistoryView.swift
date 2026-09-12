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
        static let HEADER_FONT_SIZE: CGFloat = 22.0
    }
    
    //MARK: Properties and State
    
    let onShowFilter: (Date, @escaping (Date) -> ()) -> ()
    
    @State private var viewModel = HistoryViewModel()
    @State private var isLoading: Bool = false
    @State private var hasLoaded: Bool = false
    @State private var chartOptionsVersion: Int = 0
    
    //MARK: Body
    
    var body: some View {
        List {
            chartSection
            summarySection
            detailsSection
            loadMoreSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle(isLoading ? viewModel.loadingTitle : viewModel.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if DebugService.isDebugModeEnabled() {
                ToolbarItem(placement: .topBarTrailing) {
                    dataTypeMenu
                }
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
    
    //MARK: Sections
    
    private var chartSection: some View {
        Section {
            HistoryTrendChart(values: viewModel.filteredValues, goal: viewModel.goal, optionsVersion: chartOptionsVersion)
                .frame(height: Constants.CHART_HEIGHT)
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
        }
    }
    
    @ViewBuilder
    private var loadMoreSection: some View {
        if !viewModel.isLoadMoreHidden && viewModel.canLoadMore {
            Section {
                Button(NSLocalizedString("Show More", comment: "")) {
                    loadNextPage()
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
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
    
    private var dataTypeMenu: some View {
        Menu {
            ForEach(HistoryDataType.allCases, id: \.self) { dataType in
                let isSelected = dataType == viewModel.dataType
                Button {
                    changeDataType(dataType)
                } label: {
                    Label(isSelected ? viewModel.dataTypeName : dataType.displayName(), systemImage: isSelected ? "checkmark" : dataType.symbolName())
                }
            }
        } label: {
            Image(systemName: viewModel.dataType.symbolName())
                .fontWeight(.medium)
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
        onShowFilter(viewModel.currentFilterDate) { filterDate in
            load { await viewModel.updateDateFilter(filterDate) }
        }
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
