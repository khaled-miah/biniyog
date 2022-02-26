
import 'package:flutter/material.dart';
class KPostCard extends StatelessWidget {
  String image,description, date,minBid,name,auctionID;
  Function onTap;
  KPostCard({
    this.image,this.onTap,this.date,this.description,this.minBid,this.name,
  });


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap:onTap,
        child: Card(
          elevation: 10.0,
          margin: EdgeInsets.all(10.0),
          child: new Container(
            padding: new EdgeInsets.all(10.0),
            child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text(
                        name,
                        style: Theme.of(context).textTheme.subtitle1,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  new Image.network(image, fit: BoxFit.cover,height: 140.0,
                    width: 120.0,),
                  SizedBox(
                    height: 10.0,
                  ),
                ]),
          ),
        ));
  }
}