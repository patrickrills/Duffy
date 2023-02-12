//
//  GraphicRectangularFullView.swift
//  Duffy WatchKit Extension
//
//  Created by Patrick Rills on 1/28/23.
//  Copyright © 2023 Big Blue Fly. All rights reserved.
//

import SwiftUI
import UIKit
import ClockKit

@available(watchOSApplicationExtension 7.0, *)
struct GraphicRectangularFullView: View {
    let shoeImage: UIImage
    let title: String
    let titleTintColor: UIColor
    let totalStepsFormatted: String
    
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: -4.0) {
                HStack(alignment: .center) {
                    Image(uiImage: shoeImage.withRenderingMode(.alwaysTemplate))
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color(titleTintColor))
    
                    Text(title)
                        .font(.system(size: 17.0, weight: .medium, design: .rounded))
                        .foregroundColor(Color(titleTintColor))
                }
                
                
                Text(totalStepsFormatted)
                    .font(.system(size: 42.0, weight: .semibold, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .foregroundColor(Color.white)
                    .complicationForeground()
            }
            
            Spacer()
        }
    }
}

@available(watchOSApplicationExtension 7.0, *)
struct ComplicationController_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            CLKComplicationTemplateGraphicRectangularFullView(GraphicRectangularFullView(shoeImage: UIImage(systemName: "s.square.fill")!, title: "Steps", titleTintColor: .cyan, totalStepsFormatted: "7,890")).previewContext()
            
            CLKComplicationTemplateGraphicRectangularFullView(GraphicRectangularFullView(shoeImage: UIImage(systemName: "g.square.fill")!, title: "Green Version", titleTintColor: .cyan, totalStepsFormatted: "23,456")).previewContext(faceColor: .green)
        }
    }
}
