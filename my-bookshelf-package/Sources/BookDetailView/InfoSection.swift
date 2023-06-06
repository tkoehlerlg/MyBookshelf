//
//  SwiftUIView.swift
//  
//
//  Created by Torben Köhler on 06.06.23.
//

import SwiftUI

struct InfoSection: View {
    var title: String, value: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct InfoSection_Previews: PreviewProvider {
    static var previews: some View {
        InfoSection(title: "Title", value: "This is a Value")
    }
}

