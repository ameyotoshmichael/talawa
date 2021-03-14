import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:talawa/services/Queries.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/GQLClient.dart';
import 'package:talawa/utils/apiFuctions.dart';
import 'package:talawa/utils/globals.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:talawa/views/pages/members/memberDetails.dart';
import 'package:talawa/views/pages/members/RegEventstab.dart';
import 'package:talawa/views/pages/members/userTaskstab.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class Organizations extends StatefulWidget {
  Organizations({Key key}) : super(key: key);

  @override
  _OrganizationsState createState() => _OrganizationsState();
}

class _OrganizationsState extends State<Organizations> {
  List alphaMembersList = [];
  int isSelected = 0;
  Preferences preferences = Preferences();

  initState() {
    super.initState();
    getMembers();
  }

  List alphaSplitList(List list) {
    //split list alphabeticaly
    List alphabet = [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z'
    ];
    List alphalist = [];
    for (String letter in alphabet) {
      alphalist.add(list
          .where((element) =>
              element['firstName'][0] == letter ||
              element['firstName'][0] == letter.toLowerCase())
          .toList());
    }
    alphalist.removeWhere((element) => element.isEmpty);
    return alphalist;
  }

  Future<List> getMembers() async {
    final String currentOrgID = await preferences.getCurrentOrgId();
    ApiFunctions apiFunctions = ApiFunctions();
    var result =
        await apiFunctions.gqlquery(Queries().fetchOrgById(currentOrgID));
    // print(result);
    List membersList = result == null ? [] : result['organizations'];
    alphaMembersList = membersList[0]['members'];
    setState(() {
      alphaMembersList = alphaSplitList(alphaMembersList);
    });
  }

  //returns a random color based on the user id (1 of 18)
  Color idToColor(String id) {
    int colorint = int.parse(id.replaceAll(RegExp('[a-z]'), ''));
    colorint = (colorint % 18);
    return Color.alphaBlend(
      Colors.black45,
      Colors.primaries[colorint],
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Members',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: alphaMembersList.isEmpty
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  getMembers();
                },
                child: CustomScrollView(
                  slivers: List.generate(
                    alphaMembersList.length,
                    (index) {
                      return alphabetDividerList(
                          context, alphaMembersList[index]);
                    },
                  ),
                )));
  }

  Widget alphabetDividerList(BuildContext context, List membersList) {
    return SliverStickyHeader(
      header: Container(
        height: 60.0,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: CircleAvatar(
            backgroundColor: UIData.secondaryColor,
            child: Text(
              '${membersList[0]['firstName'][0].toUpperCase()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            )),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return memberCard(index, membersList);
          },
          childCount: membersList.length,
        ),
      ),
    );
  }

  Widget memberCard(index, List membersList) {
    Color color = idToColor(membersList[index]['_id']);
    return GestureDetector(
        onTap: () {
          pushNewScreen(context,
              screen: MemberDetail(member: membersList[index], color: color));
        },
        child: Card(
          clipBehavior: Clip.hardEdge,
          child: Row(
            children: [
              membersList[index]['image'] == null
                  ? defaultUserImage(membersList[index])
                  : userImage(membersList[index]),
              Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(20),
                  height: 80,
                  color: Colors.white,
                  child: Text(
                    membersList[index]['firstName'].toString() +
                        ' ' +
                        membersList[index]['lastName'].toString(),
                    textAlign: TextAlign.left,
                  ))
            ],
          ),
        ));
  }

  Widget userImage(Map member) {
    return Container(
      height: 80,
      width: 100,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              Provider.of<GraphQLConfiguration>(context).displayImgRoute +
                  member['image']),
          fit: BoxFit.cover,
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            alignment: Alignment.center,
            color: Colors.grey.withOpacity(0.1),
            child: Image.network(
              Provider.of<GraphQLConfiguration>(context).displayImgRoute +
                  member['image'],
            ),
          ),
        ),
      ),
    );
  }

  Widget defaultUserImage(Map member) {
    return Container(
        padding: EdgeInsets.all(0),
        width: 100,
        height: 80,
        color: idToColor(member['_id']),
        child: Padding(
            padding: EdgeInsets.all(10),
            child: CircleAvatar(
                backgroundColor: Colors.black12,
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.white70,
                ))));
  }

  Widget popUpMenue(Map member) {
    return PopupMenuButton<int>(
      // onSelected: (val) async {
      //   if (val == 1) {
      //     pushNewScreen(
      //       context,
      //       withNavBar: true,
      //       screen: UserTasks(),
      //     );
      //   } else if (val == 2) {
      //     pushNewScreen(
      //       context,
      //       withNavBar: true,
      //       screen: RegisterdEvents(),
      //     );
      //   }
      // },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        const PopupMenuItem<int>(
            value: 1,
            child: ListTile(
              leading: Icon(Icons.playlist_add_check),
              title: Text('View Assigned Tasks'),
            )),
        const PopupMenuItem<int>(
            value: 2,
            child: ListTile(
              leading: Icon(Icons.playlist_add_check),
              title: Text('View Registered Events'),
            )),
      ],
    );
  }
}
