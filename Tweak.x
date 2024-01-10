// Copyright (c) 2024 Nightwind

@import UIKit;

// Interface for the private method included in `UIView` called _viewControllerForAncestor and the _sectionContentInset method in `UITableView`
@interface UITableView (Private)
- (UIViewController *)_viewControllerForAncestor;
- (UIEdgeInsets)_sectionContentInset;
@end

// Here we are hooking UITableView in order to modify all of the UITableView's across the Settings app
%hook UITableView

// Here we change the style of the UITableView so that it does not include the round corners
- (UITableViewStyle)style {
	return UITableViewStyleGrouped;
}

// Changing the init so that the table view is initialized without the rounded corners
- (instancetype)initWithFrame:(CGRect) frame style:(UITableViewStyle)style {
	UIViewController *ancestor = [self _viewControllerForAncestor];

	// Checking for special cases
	if (ancestor && ![ancestor isKindOfClass:%c(UIInputViewController)] && ![ancestor isKindOfClass:%c(UIInputWindowController)] ) {
		return %orig(frame, UITableViewStyleGrouped);
	}

	return %orig;
}

// Overriding the getter method for the _sectionContentInset property.
// This will make sure that there are no insets on the sides of the cells, similar to iOS 14.
- (UIEdgeInsets)_sectionContentInset {
	UIEdgeInsets orig = %orig;
	UIViewController *ancestor = [self _viewControllerForAncestor];

	// Checking for special cases
	if (ancestor && ![ancestor isKindOfClass:%c(UIInputViewController)] && ![ancestor isKindOfClass:%c(UIInputWindowController)]) {
		return UIEdgeInsetsMake(orig.top, 0, orig.bottom, 0);
	}

	return orig;
}

// Overriding the setter method for the _sectionContentInset property.
// This will make sure that there are no insets on the sides of the cells, similar to iOS 14.
- (void)_setSectionContentInset:(UIEdgeInsets)insets {
	%orig([self _sectionContentInset]);
}

%end // %hook UITableView


// This hook is called at the very beginning when the Settings app launches.
// It will make the UINavigationBar appearance into the "legacy" one from iOS 14 and below.
%hook PreferencesAppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(id)launchOptions {
	UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
	[appearance configureWithDefaultBackground];
    [[UINavigationBar appearance] setScrollEdgeAppearance:appearance];

	return %orig;
}

%end // %hook PreferencesAppController


/*

------------------------------------------------------------------------
This hook is here as a workaround for a bug(?) that occurs with iOS 15+.
The reason this is here is because in dark mode, the main menu's bar is
off-color. Fine in light mode, though. The reason this is not included
in the main tweak is that this method has some issues with the animation
when switching between panes in the Settings app.

Also yes, this method *does* utilize a "layoutSubviews" hook which is not
a great hook. It was the only way I could find how to do it. This hook is
not included in the main .debs but is included in the -experimental .debs.
------------------------------------------------------------------------

%hook UINavigationBar

- (void)layoutSubviews {
	%orig;

	for (UIView *subview in [self subviews]) {
		if ([subview isKindOfClass:%c(_UINavigationBarLargeTitleView)]) {
			[self setScrollEdgeAppearance:nil];
			return;
		}
	}

	[self setScrollEdgeAppearance:[[UINavigationBar appearance] scrollEdgeAppearance]];
}

%end

*/