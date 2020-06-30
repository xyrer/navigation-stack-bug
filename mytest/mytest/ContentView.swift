//
//  ContentView.swift
//  mytest
//
//  Created by Gustavo Parrado on 30/06/20.
//  Copyright © 2020 xyrer. All rights reserved.
//

import SwiftUI
import NavigationStack
import Combine

struct ContentView: View {
	@EnvironmentObject var user:ObservableUser
	@State private var gotoLogin = false
	
    var body: some View {
		NavigationStackView {
			PushView(destination: loginView(),isActive: self.$gotoLogin) {
				EmptyView()
			}
			VStack {
				Text("Hello")
				Button(action: {
					self.gotoLogin.toggle()
				}) {
					Image(systemName: "xmark")
				}
			}
		}.envNavigationContext()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		ContentView()
    }
}


struct loginView:View {
	@EnvironmentObject var user:ObservableUser
	
	var body: some View {
		VStack {
			Text("login view")
		}
		.onNavigationComplete() {
			print("login view")
			self.user.loginAttempts = 0
		}
	}
}

class ObservableUser: ObservableObject {
	public var lockRemaining:Int = 0
	public let loginBlocked = PassthroughSubject<Bool,Never>()
	@Published var loginAttempts:Int = 0 {
		didSet {
			if loginAttempts >= 10 {
				self.lockLogin()
			}
		}
	}
	
	func lockLogin() {
		let now = Date()
		let unlockTime = now + 30
		self.lockRemaining = 30
		UserDefaults.standard.setValue(unlockTime, forKey: "unlockTime")
		self.loginBlocked.send(true)
	}
}
