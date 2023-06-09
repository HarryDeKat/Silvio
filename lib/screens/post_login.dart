import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:silvio/hive/adapters.dart' hide PersonConfig;
import 'package:silvio/main.dart';
import 'package:silvio/screens/settings.dart';

class SettingsReminder extends StatefulWidget {
  const SettingsReminder({super.key, required this.account});

  final Account account;

  @override
  State<StatefulWidget> createState() => _SettingsReminder();
}

class _SettingsReminder extends State<SettingsReminder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: Center(
        child: SafeArea(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(children: [
                  SwitchListTile(
                    title: Text(AppLocalizations.of(context)!.notifications),
                    secondary: const Icon(Icons.notifications_active),
                    subtitle:
                        Text(AppLocalizations.of(context)!.notificationsExpl),
                    value: config.enableNotifications,
                    onChanged: (bool value) async {
                      config.enableNotifications = value;
                      config.save();
                      FlutterLocalNotificationsPlugin
                          flutterLocalNotificationsPlugin =
                          FlutterLocalNotificationsPlugin();
                      final bool? androidResult =
                          await flutterLocalNotificationsPlugin
                              .resolvePlatformSpecificImplementation<
                                  AndroidFlutterLocalNotificationsPlugin>()
                              ?.requestPermission();
                      final bool? iOSResult =
                          await flutterLocalNotificationsPlugin
                              .resolvePlatformSpecificImplementation<
                                  IOSFlutterLocalNotificationsPlugin>()
                              ?.requestPermissions(
                                alert: true,
                                badge: true,
                                sound: true,
                              );
                      if (androidResult == true || iOSResult == true) {
                        if (!(await Permission
                            .ignoreBatteryOptimizations.isGranted)) {
                          Permission.ignoreBatteryOptimizations.request();
                        }
                        setState(() {});
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Silvio.of(context).update();
                        });
                      }
                    },
                  ),
                  PersonConfigCarousel(
                    profiles: widget.account.profiles,
                    simpleView: true,
                    widgetsNextToIndicator: [
                      FilledButton.icon(
                          icon: const Icon(Icons.navigate_next),
                          onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Start(),
                              )),
                          label: Text(AppLocalizations.of(context)!.gContinue)),
                    ],
                  ),
                ])),
          ),
        ),
      ),
    );
  }
}
