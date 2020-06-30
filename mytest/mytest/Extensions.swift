//
//  Extensions.swift
//  mytest
//
//  Created by Gustavo Parrado on 30/06/20.
//  Copyright © 2020 xyrer. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import NavigationStack

class NavigationViewId: ObservableObject {
    let id: UUID = UUID()
}

class NavigationContext: ObservableObject {
    @Published var originViewId: UUID? = UUID()
    // Initial value so that onNavigationComplete is called on initial screen
}

extension View {
    func onNavigationComplete(perform action: (() -> Void)? = nil) -> some View {
        self
            .modifier(NavigationTrackModifier(action: action))
            .envNavigationId()
    }

    func envNavigationId() -> some View {
        self.environmentObject(NavigationViewId())
    }

    func envNavigationContext() -> some View {
        self.environmentObject(NavigationContext())
            .environmentObject(NavigationViewId())
    }
}

struct NavigationTrackModifier: ViewModifier {
	var action: (() -> Void)?
	
	@EnvironmentObject var navContext: NavigationContext
	
	@EnvironmentObject var navId: NavigationViewId
	
	func body(content: Content) -> some View {
		content
			.onDisappear {
				self.navContext.originViewId = self.navId.id
		}
		.onReceive(navContext.$originViewId) { viewId in
			if viewId != nil, viewId != self.navId.id {
				self.action?()
				self.navContext.originViewId = nil
			}
		}
	}
}
