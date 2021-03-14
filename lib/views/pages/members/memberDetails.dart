import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:provider/provider.dart';
import 'package:talawa/utils/GQLClient.dart';

import '../../../utils/uidata.dart';
import 'RegEventstab.dart';
import 'userTaskstab.dart';

class MemberDetail extends StatefulWidget {
  Map member;
  Color color;
  MemberDetail({Key key, @required this.member, @required this.color})
      : super(key: key);

  @override
  _MemberDetailState createState() => _MemberDetailState();
}

class _MemberDetailState extends State<MemberDetail>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'User Info',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: CustomScrollView(slivers: [
          SliverAppBar(
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              expandedHeight: 250,
              flexibleSpace: FlexibleSpaceBar(
                background: Column(children: [
                  widget.member['image'] == null
                      ? defaultUserImg()
                      : userImg(widget.member['image']),
                  Card(
                      child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    height: 30,
                    child: Text(
                        'User email: ' + widget.member['email'].toString()),
                  )),
                  Card(
                      child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    height: 30,
                    child: Text('User Privilages:'),
                  )),
                ]),
              )),
          SliverStickyHeader(
            header: Container(
                height: 60.0,
                decoration:
                    BoxDecoration(color: Theme.of(context).primaryColor),
                child: Material(
                  color: UIData.secondaryColor,
                  child: TabBar(
                    labelPadding: EdgeInsets.all(0),
                    indicatorColor: Colors.white,
                    controller: _tabController,
                    tabs: [
                      Tab(
                        icon: Text(
                          'Tasks',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Tab(
                        icon: Text(
                          'Registered Events',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )),
            sliver: SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  UserTasks(
                    member: widget.member,
                  ),
                  RegisterdEvents(
                    member: widget.member,
                  ),
                ],
              ),
            ),
          ),
        ]));
  }

  Widget userImg(String link) {
    return Container(
      height: 170,
      width: double.maxFinite,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              Provider.of<GraphQLConfiguration>(context).displayImgRoute +
                  link),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(alignment: AlignmentDirectional.bottomStart, children: [
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              alignment: Alignment.center,
              color: Colors.grey.withOpacity(0.1),
              child: Image.network(
                Provider.of<GraphQLConfiguration>(context).displayImgRoute +
                    link,
              ),
            ),
          ),
        ),
        Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black45, Colors.transparent]),
            ),
            padding: EdgeInsets.only(left: 20),
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.member['firstName'].toString() +
                    ' ' +
                    widget.member['lastName'].toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ))
      ]),
    );
  }

  Widget defaultUserImg() {
    return Container(
      height: 170,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Container(
              height: 130,
              child: Icon(
                Icons.person,
                size: 100,
                color: Colors.white54,
              )),
          Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black45, Colors.transparent]),
              ),
              padding: EdgeInsets.only(left: 20),
              height: 40,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.member['firstName'].toString() +
                      ' ' +
                      widget.member['lastName'].toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ))
        ],
      ),
      color: widget.color,
    );
  }
}
