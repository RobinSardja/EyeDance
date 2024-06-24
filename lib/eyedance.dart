import "package:flutter/material.dart";

import "package:camera/camera.dart";
import "package:shared_preferences/shared_preferences.dart";

import "camera.dart";
import "home.dart";
import "settings.dart";

class EyeDance extends StatefulWidget {
	const EyeDance({
        super.key,
        required this.cameras,
        required this.settings
    });

    final List<CameraDescription> cameras;
    final SharedPreferences settings;

	@override
	State<EyeDance> createState() => _EyeDanceState();
}

class _EyeDanceState extends State<EyeDance> {

	// selected index for navigation bar
	int selectedIndex = 1;

	@override
	Widget build(BuildContext context) {

		// page controller for page view
		final pageController = PageController(
			initialPage: selectedIndex,
		);

		return Scaffold(
            appBar: AppBar(
                title: const Text( "EyeDance" )
            ),
            body: PageView(
                controller: pageController,
                onPageChanged: (selectedPage) {
                    setState( () => selectedIndex = selectedPage );
                },
                children: [
                    const HomePage(),
                    CameraPage( cameras: widget.cameras, settings: widget.settings ),
                    SettingsPage( settings: widget.settings )
                ]
            ),
            bottomNavigationBar: NavigationBar(
                onDestinationSelected: ( selectedDestination ) {
                    setState(() {
                        selectedIndex = selectedDestination;
                        pageController.jumpToPage(selectedDestination);
                    });
                },
                selectedIndex: selectedIndex,
                destinations: const [
                    NavigationDestination(
                        icon: Icon( Icons.home ),
                        label: "Home"
                    ),
                    NavigationDestination(
                        icon: Icon( Icons.camera_alt ),
                        label: "Camera"
                    ),
                    NavigationDestination(
                        icon: Icon( Icons.settings ),
                        label: "Settings"
                    )
                ]
            )
		);
	}
}