import "package:flutter/material.dart";

import "package:shared_preferences/shared_preferences.dart";

class SettingsPage extends StatefulWidget {
	const SettingsPage({
        super.key,
        required this.settings
    });

    final SharedPreferences settings;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

    late bool enableTracking;
    late bool hyperAccuracy;
    late bool generateAdvice;
    late int resolutionPreset;

    @override
    void initState() {
        super.initState();

        enableTracking = widget.settings.getBool("enableTracking") ?? true;
        hyperAccuracy = widget.settings.getBool("hyperAccuracy") ?? true;
        generateAdvice = widget.settings.getBool("generateAdvice") ?? true;
        resolutionPreset = widget.settings.getInt("resolutionPreset") ?? 0;
    }

	@override
	Widget build(BuildContext context) {

		return Center(
            child: ListView(
                shrinkWrap: true,
                children: [
                    ListTile(
                        title: const Text( "Enable tracking" ),
                        trailing: Switch(
                            value: enableTracking,
                            onChanged: (value) {
                                setState( () => enableTracking = value );
                                widget.settings.setBool( "enableTracking", enableTracking );
                            }
                        )
                    ),
                    ListTile(
                        title: const Text( "Hyper accuracy *" ),
                        trailing: Switch(
                            value: hyperAccuracy,
                            onChanged: (value) {
                                setState( () => hyperAccuracy = value );
                                widget.settings.setBool( "hyperAccuracy", hyperAccuracy );
                            }
                        )
                    ),
                    const Center( child: Text( "* Recommended only for newer phones" ) ),
                    ListTile(
                        title: const Text( "Generate advice (coming soon!)" ),
                        trailing: Switch(
                            value: generateAdvice,
                            onChanged: (value) {
                                setState( () => generateAdvice = value );
                                widget.settings.setBool( "generateAdvice", generateAdvice );
                            }
                        )
                    ),
                    ListTile(
                        title: const Text( "Camera quality" ),
                        trailing: DropdownMenu(
                            initialSelection: resolutionPreset,
                            onSelected: (value) {
                                setState( () => resolutionPreset = value! );
                                widget.settings.setInt( "resolutionPreset", resolutionPreset );
                            },
                            dropdownMenuEntries: const [
                                DropdownMenuEntry(
                                    value: 0,
                                    label: "Low"
                                ),
                                DropdownMenuEntry(
                                    value: 1,
                                    label: "Medium"
                                ),
                                DropdownMenuEntry(
                                    value: 2,
                                    label: "High"
                                ),
                                DropdownMenuEntry(
                                    value: 3,
                                    label: "Very high"
                                ),
                                DropdownMenuEntry(
                                    value: 4,
                                    label: "Ultra high"
                                ),
                                DropdownMenuEntry(
                                    value: 5,
                                    label: "Max"
                                )
                            ]
                        )
                    )
                ]
            )
        );
	}
}