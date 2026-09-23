//
//  HistoryFilterView.swift
//  Duffy
//
//  Created by Patrick Rills on 9/12/26.
//  Copyright © 2026 Big Blue Fly. All rights reserved.
//

import SwiftUI
import DuffyFramework

struct HistoryFilterView: View {
    
    //MARK: Layout mode and constants
    
    private enum Constants {
        static let EARLIEST_DAYS_AGO: Int = -7
        static let HEADER_HEIGHT: CGFloat = 16.0
        static let SAVE_SYMBOL_SIZE: CGFloat = 24.0
        static let PICKER_HEIGHT: CGFloat = 352.0
        static let PICKER_H_MARGIN: CGFloat = 16.0
    }
    
    //MARK: Properties and State
    
    let onDateSelected: (Date) -> ()
    
    @State private var sinceDateFilter: Date
    
    private let maximumDate = Date().dateByAdding(days: Constants.EARLIEST_DAYS_AGO)
    
    //MARK: Constructors
    
    init(selectedDate: Date, onDateSelected: @escaping (Date) -> ()) {
        self.onDateSelected = onDateSelected
        _sinceDateFilter = State(initialValue: selectedDate)
    }
    
    //MARK: Body
    
    var body: some View {
        List {
            Section {
                LabeledContent {
                    Text(Globals.fullDateFormatter().string(from: sinceDateFilter))
                        .foregroundStyle(Color(uiColor: .label))
                } label: {
                    Text(NSLocalizedString("Since", comment: ""))
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                }
            } header: {
                Color.clear
                    .frame(height: Constants.HEADER_HEIGHT)
            } footer: {
                Text(String.localizedStringWithFormat(NSLocalizedString("Last %d days", comment: "Placeholder is a number of days"), sinceDateFilter.differenceInDays(from: Date())))
            }
        }
        .listStyle(.grouped)
        .scrollDisabled(true)
        .safeAreaInset(edge: .bottom, spacing: 0.0) {
            datePicker
        }
        .navigationTitle(NSLocalizedString("Select Date", comment: ""))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                saveButton
            }
        }
    }
    
    //MARK: Date picker and save button
    
    private var datePicker: some View {
        DatePickerRepresentable(date: $sinceDateFilter,
                                maximumDate: maximumDate,
                                height: Constants.PICKER_HEIGHT)
        .padding(.horizontal, Constants.PICKER_H_MARGIN)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemGroupedBackground).ignoresSafeArea(edges: .bottom))
    }
    
    @ViewBuilder
    private var saveButton: some View {
        if #available(iOS 26.0, *) {
            Button {
                onDateSelected(sinceDateFilter)
            } label: {
                Image(systemName: "checkmark")
                    .fontWeight(.semibold)
            }
            .tint(Color(uiColor: Globals.secondaryColor()))
            .buttonStyle(.borderedProminent)
        } else {
            Button {
                onDateSelected(sinceDateFilter)
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: Constants.SAVE_SYMBOL_SIZE))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color(uiColor: Globals.secondaryColor()), Color(uiColor: .tertiarySystemFill))
            }
            .tint(Color(uiColor: Globals.secondaryColor()))
        }
    }
}

//MARK: UIKit date picker

private struct DatePickerRepresentable: UIViewRepresentable {
    
    @Binding var date: Date
    let maximumDate: Date
    let height: CGFloat
    
    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.maximumDate = maximumDate
        picker.date = date
        picker.tintColor = Globals.secondaryColor()
        picker.addTarget(context.coordinator, action: #selector(Coordinator.dateSelected(_:)), for: .valueChanged)
        return picker
    }
    
    func updateUIView(_ picker: UIDatePicker, context: Context) {
        context.coordinator.date = $date
        
        if picker.date != date {
            picker.date = date
        }
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIDatePicker, context: Context) -> CGSize? {
        guard let width = proposal.width else { return nil }
        return CGSize(width: width, height: height)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(date: $date)
    }
    
    class Coordinator: NSObject {
        
        var date: Binding<Date>
        
        init(date: Binding<Date>) {
            self.date = date
        }
        
        @objc func dateSelected(_ picker: UIDatePicker) {
            date.wrappedValue = picker.date
        }
    }
}
