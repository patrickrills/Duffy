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
        static let SAVE_SYMBOL_SIZE: CGFloat = 24.0
        static let DATE_PICKER_SECTION_SPACING: CGFloat = 24.0
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
                        .foregroundStyle(Color(.label))
                } label: {
                    Text(NSLocalizedString("Since", comment: ""))
                        .foregroundStyle(Color(.secondaryLabel))
                }
            } footer: {
                Text(String.localizedStringWithFormat(NSLocalizedString("Last %d days", comment: "Placeholder is a number of days"), sinceDateFilter.differenceInDays(from: Date())))
            }
            
            Section {
                DatePickerRepresentable(date: $sinceDateFilter, maximumDate: maximumDate)
            }
            .listSectionSpacing(.custom(Constants.DATE_PICKER_SECTION_SPACING))
        }
        .listStyle(.insetGrouped)
        .scrollBounceBehavior(.basedOnSize)
        .navigationTitle(NSLocalizedString("Select Date", comment: ""))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                saveButton
            }
        }
    }
    
    //MARK: Date picker and save button
    
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

//SwiftUI's graphical DatePicker reports its height before it's laid out at the width of its row and only corrects it after
//the first tap, which made the row jump. UIKit's picker is measured here at the width the row offers instead.
private struct DatePickerRepresentable: UIViewRepresentable {
    
    @Binding var date: Date
    let maximumDate: Date
    
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
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView picker: UIDatePicker, context: Context) -> CGSize? {
        guard let width = proposal.width, width.isFinite else { return nil }
        
        let size = picker.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
        return CGSize(width: width, height: size.height)
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
