//
//  BlinkView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 25.07.2022.
//

import SwiftUI

struct BlinkView: View {
    var body: some View {
        Color.gray
            .ignoresSafeArea()
            .opacity(0.7)
            .transition(
                .asymmetric(
                    insertion:
                            .opacity
                        .animation(.easeIn(duration: 0.05)),
                    removal:
                            .opacity
                        .animation(.easeOut(duration: 0.15))
                )
            )
    }
}

struct BlinkView_Previews: PreviewProvider {
    static var previews: some View {
        BlinkView()
    }
}