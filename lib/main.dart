import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:camera/camera.dart";
import "package:permission_handler/permission_handler.dart";
import "package:shared_preferences/shared_preferences.dart";

import "eyedance.dart";

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();

    final cameras = await availableCameras();
    final settings = await SharedPreferences.getInstance();
    Map<Permission, PermissionStatus> perms = await [
        Permission.camera,
        Permission.microphone,
        Permission.mediaLibrary
    ].request();

    if( perms.values.every( (value) => value == PermissionStatus.granted ) ) {

    }

	SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

	runApp(
        MaterialApp(
			debugShowCheckedModeBanner: false,
			theme: ThemeData.light().copyWith(
				appBarTheme: const AppBarTheme(
					centerTitle: true,
					backgroundColor: Colors.red,
					foregroundColor: Colors.white
				),
				scaffoldBackgroundColor: Colors.white,
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white
                ),
                progressIndicatorTheme: const ProgressIndicatorThemeData(
                    color: Colors.red
                ),
                switchTheme: SwitchThemeData(
                    thumbColor:  WidgetStateProperty.resolveWith((state) {
						return state.contains( WidgetState.selected ) ? Colors.white : Colors.black;
					}),
                    trackColor: WidgetStateProperty.resolveWith((state) {
						return state.contains( WidgetState.selected ) ? Colors.red : Colors.white;
					}),
                    trackOutlineColor: WidgetStateProperty.resolveWith((state) {
						return state.contains( WidgetState.selected ) ? Colors.red : Colors.black;
					})
                ),
                snackBarTheme: const SnackBarThemeData(
                    backgroundColor: Colors.white,
                    actionTextColor: Colors.black,
                    closeIconColor: Colors.red,
                    contentTextStyle: TextStyle(
                        color: Colors.black
                    ),
                    showCloseIcon: true
                ),
                dropdownMenuTheme: const DropdownMenuThemeData(
                    menuStyle: MenuStyle(
                        backgroundColor: WidgetStatePropertyAll( Colors.white )
                    )
                ),
                bottomAppBarTheme: const BottomAppBarTheme(
                    color: Colors.red
                ),
				navigationBarTheme: NavigationBarThemeData(
					backgroundColor: Colors.red,
					indicatorColor: Colors.white,
					iconTheme: WidgetStateProperty.resolveWith((state) {
						return IconThemeData(
							color: state.contains( WidgetState.selected ) ? Colors.black : Colors.white
						);
					}),
					labelTextStyle: const WidgetStatePropertyAll(
						TextStyle(
							color: Colors.white
						)
					)
				)
			),
			darkTheme: ThemeData.dark().copyWith(
				appBarTheme: const AppBarTheme(
					centerTitle: true,
					backgroundColor: Colors.black,
					foregroundColor: Colors.white
				),
				scaffoldBackgroundColor: Colors.black,
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black
                ),
                progressIndicatorTheme: const ProgressIndicatorThemeData(
                    color: Colors.white
                ),
                switchTheme: SwitchThemeData(
                    thumbColor:  WidgetStateProperty.resolveWith((state) {
						return state.contains( WidgetState.selected ) ? Colors.black : Colors.white;
					}),
                    trackColor: WidgetStateProperty.resolveWith((state) {
						return state.contains( WidgetState.selected ) ? Colors.white : Colors.black;
					}),
                    trackOutlineColor: const WidgetStatePropertyAll(
                        Colors.white,
                    )
                ),
                snackBarTheme: const SnackBarThemeData(
                    backgroundColor: Colors.white,
                    actionTextColor: Colors.black,
                    closeIconColor: Colors.black,
                    contentTextStyle: TextStyle(
                        color: Colors.black
                    ),
                    showCloseIcon: true
                ),
                dropdownMenuTheme: const DropdownMenuThemeData(
                    menuStyle: MenuStyle(
                        backgroundColor: WidgetStatePropertyAll( Colors.black )
                    )
                ),
                bottomAppBarTheme: const BottomAppBarTheme(
                    color: Colors.black
                ),
				navigationBarTheme: NavigationBarThemeData(
					backgroundColor: Colors.black,
					indicatorColor: Colors.white,
					iconTheme: WidgetStateProperty.resolveWith((state) {
						return IconThemeData(
							color: state.contains( WidgetState.selected ) ? Colors.black : Colors.white
						);
					}),
					labelTextStyle: const WidgetStatePropertyAll(
						TextStyle(
							color: Colors.white
						)
					)
				)
			),
            home: EyeDance( cameras: cameras, settings: settings )
        )
    );
}