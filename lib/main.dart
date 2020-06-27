import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:launcher_assist/launcher_assist.dart';
import 'package:minimal_launcher/AppSelector.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.black));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minimal launcher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Launcher(),
    );
  }
}

class Launcher extends StatefulWidget {
  @override
  _LauncherState createState() => _LauncherState();
}

class _LauncherState extends State<Launcher> {
  var packageNames = [], icons = [], appNames = [];
  var defaultApps = ['com.android.settings'];
  var left, middle, right, theme = 'light';
  var quote = 'Focus on your work';
  final iconSize = 75.0;

  @override
  void initState() {
    super.initState();

    refreshUI();
    LauncherAssist.getAllApps().then((apps) {
      apps.forEach((app) {
        packageNames.add(app['package']);
        icons.add(app['icon']);
        appNames.add(app['label']);
      });
      setState(() {});
    });
  }

  refreshUI() {
    SharedPreferences.getInstance().then((prefs) {
      left = prefs.getString('left');
      middle = prefs.getString('middle');
      right = prefs.getString('right');
      theme = prefs.getString('theme');
      quote = prefs.getString('quote');

      if (quote == null) {
        prefs.setString('quote', 'Focus on your work');
        quote = prefs.getString('quote');
      }

      if (theme == null) {
        prefs.setString('theme', 'light');
        theme = 'light';
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: theme == 'dark' ? Colors.white : Colors.black),
          backgroundColor: theme == 'dark' ? Colors.black : Colors.white,
          elevation: 0,
          actions: <Widget>[
            IconButton(
              icon: iconContainer('com.android.settings'),
              iconSize: 40,
              onPressed: () {
                LauncherAssist.launchApp('com.android.settings');
              },
            ),
          ],
        ),
        backgroundColor: theme == 'dark' ? Colors.black : Colors.white,
        drawer: Theme(
          data: theme == 'light'
              ? Theme.of(context)
              : Theme.of(context).copyWith(canvasColor: Colors.grey[850]),
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                ListTile(
                  title: Text('Change text on home screen',style: TextStyle(
                          color:
                              theme == 'light' ? Colors.black : Colors.white)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _changeQuote();
                  },
                ),
                ListTile(
                  title: Text('Dark mode',
                      style: TextStyle(
                          color:
                              theme == 'light' ? Colors.black : Colors.white)),
                  trailing: CupertinoSwitch(
                      value: theme == 'dark',
                      onChanged: (value) async {
                        await updateTheme(value);
                        refreshUI();
                      }),
                )
              ],
            ),
          ),
        ),
        body: WillPopScope(
          onWillPop: () => Future(() => false),
          child: Container(
            padding: EdgeInsets.fromLTRB(15, 25, 10, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(''),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(50,0,50,0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          quote,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                          style: TextStyle(fontSize: 60, color: theme == 'light' ? Colors.black : Colors.white, fontWeight: FontWeight.w500)
                          
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Text(''),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onLongPress: () async {
                        await _removeApp('left');
                      },
                      child: IconButton(
                        iconSize: iconSize,
                        icon: left == null
                            ? Icon(
                                Icons.add,
                                color: theme == 'light'
                                    ? Colors.black
                                    : Colors.white,
                              )
                            : iconContainer(left),
                        onPressed: () async {
                          await _launchApp('left', left);
                        },
                      ),
                    ),
                    GestureDetector(
                      onLongPress: () async {
                        await _removeApp('middle');
                      },
                      child: IconButton(
                        iconSize: iconSize,
                        icon: middle == null
                            ? Icon(
                                Icons.add,
                                color: theme == 'light'
                                    ? Colors.black
                                    : Colors.white,
                              )
                            : iconContainer(middle),
                        onPressed: () async {
                          await _launchApp('middle', middle);
                        },
                      ),
                    ),
                    GestureDetector(
                      onLongPress: () async {
                        await _removeApp('right');
                      },
                      child: IconButton(
                        iconSize: iconSize,
                        icon: right == null
                            ? Icon(
                                Icons.add,
                                color: theme == 'light'
                                    ? Colors.black
                                    : Colors.white,
                              )
                            : iconContainer(right),
                        onPressed: () async {
                          await _launchApp('right', right);
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  _changeQuote() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter your message'),
            content: TextField(onChanged: (value) => quote = value, maxLength: 50,),
            actions: <Widget>[
              FlatButton(
                child: Text('Change'),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    
                  });
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  _removeApp(position) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Do you want to remove this app from home screen?'),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'YES',
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () async {
                  await SharedPreferences.getInstance().then((prefs) {
                    prefs.setString(position, null);
                    setState(() {
                      if (position == 'left')
                        left = null;
                      else if (position == 'middle')
                        middle = null;
                      else
                        right = null;
                    });
                  });
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(
                  'NO',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  _launchApp(position, packageName) async {
    if (packageName == null) {
      dynamic didChange = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              AppSelector(appNames, icons, packageNames, position)));

      if (didChange != null) {
        refreshUI();
      }
    } else {
      LauncherAssist.launchApp(packageName);
    }
  }

  updateTheme(value) async {
    if (value) {
      setState(() {
        theme = 'dark';
      });
    } else {
      setState(() {
        theme = 'light';
      });
    }
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setString('theme', theme);
    });
  }

  iconContainer(packageName) {
    var icon;
    var iconIdx = packageNames.indexOf(packageName);

    if (iconIdx == -1) {
      return Container();
    } else {
      icon = icons[iconIdx];
      try {
        return Image.memory(icon, height: 75, width: 75);
      } catch (e) {
        print(e);
        return Container();
      }
    }
  }
}
