import 'package:biniyog/views/styles/k_colors.dart';
import 'package:biniyog/views/styles/k_text_style.dart';
import 'package:flutter/material.dart';

class KButton extends StatefulWidget {
  String text;
  Function onCall;
  KButton({this.text, this.onCall});

  @override
  _KButtonState createState() => _KButtonState();
}

class _KButtonState extends State<KButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
     onTap: widget.onCall,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: KColor.primary
        ),
        child: Center(child: Text(widget.text,style: KTextStyle.headline2,)),
        
      ),
    );
  }
}
