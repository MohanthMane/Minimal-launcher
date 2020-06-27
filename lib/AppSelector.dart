import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSelector extends StatefulWidget {
  final appNames, icons, packageNames, position;

  AppSelector(this.appNames, this.icons, this.packageNames, this.position);

  @override
  _AppSelectorState createState() => _AppSelectorState();
}

class _AppSelectorState extends State<AppSelector> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => Divider(color: Colors.grey,),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: _getImage(widget.icons[index]),
            ),
            title: Text(widget.appNames[index]),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title:
                          Text('Do you want to add this app to home screen?'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text(
                            'YES',
                            style: TextStyle(color: Colors.blue),
                          ),
                          onPressed: () async {
                            await SharedPreferences.getInstance().then((prefs) {
                              prefs.setString(
                                  widget.position, widget.packageNames[index]);
                            });
                            Navigator.of(context).pop();
                            Navigator.of(context).pop(true);
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
            },
          );
        },
        itemCount: widget.appNames.length,
      ),
    );
  }

  _getImage(icon) {
    if (icon == null)
      return Container();
    else
      return Image.memory(icon).image;
  }
}
