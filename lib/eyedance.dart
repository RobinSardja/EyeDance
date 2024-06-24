import "package:flutter/material.dart";

class EyeDance extends StatefulWidget {
    const EyeDance({super.key});

    @override
    State<EyeDance> createState() => _EyeDanceState();
}

class _EyeDanceState extends State<EyeDance> {
    @override
    Widget build(BuildContext context) {
        return const Scaffold(
        body: Center(
            child: Text( "EyeDance" )
            )
        );
    }
}