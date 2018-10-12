//
//  Menu.swift
//  GrafittiBackgrounds
//
//  Created by Lee Arromba on 03/12/2017.
//  Copyright © 2017 Pink Chicken. All rights reserved.
//

import Cocoa

// sourcery: name = Menu
protocol Menuable: Mockable {
	var viewModel: MenuViewModel { get }
    func item(at index: Int) -> MenuItemable?
}

class Menu: NSMenu, Menuable {
	var viewModel: MenuViewModel {
		didSet {
			update(viewModel: viewModel)
		}
	}

	init(viewModel: MenuViewModel, items: [NSMenuItem]) {
		self.viewModel = viewModel
        super.init(title: viewModel.title)
		items.forEach { addItem($0) }
    }

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func item(at index: Int) -> MenuItemable? {
        guard index >= items.startIndex, index < items.endIndex else {
            return nil
        }
        return items[index] as? MenuItemable
    }

	// MARK: - private

	private func update(viewModel: MenuViewModel) {
		title = viewModel.title
		autoenablesItems = viewModel.autoenablesItems
	}
}
