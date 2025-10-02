import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisepaise/models/group_model.dart';
import 'package:wisepaise/providers/api_provider.dart';
import 'package:wisepaise/providers/auth_provider.dart';

import '../models/type_model.dart';
import '../utils/utils.dart';
import 'expense_group_details_page.dart';

class AllGroupPage extends StatefulWidget {
  const AllGroupPage({super.key});

  @override
  State<AllGroupPage> createState() => _AllGroupPageState();
}

class _AllGroupPageState extends State<AllGroupPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<ApiProvider, AuthProvider>(
      builder: (_, api, auth, __) {
        return Scaffold(
          appBar: AppBar(centerTitle: true, title: Text('Groups')),
          body: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: api.groupList.length,
            itemBuilder: (context, index) {
              GroupModel group = GroupModel.fromJson(
                api.groupList.elementAt(index),
              );
              return Hero(
                tag: 'groupCard_${group.exGroupId}',
                flightShuttleBuilder: (
                  flightContext,
                  animation,
                  direction,
                  fromContext,
                  toContext,
                ) {
                  return Material(
                    child:
                        (direction == HeroFlightDirection.push
                            ? fromContext.widget
                            : toContext.widget),
                  );
                },
                child: GestureDetector(
                  onTap:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => ExpenseGroupDetailsPage(
                                groupMap: group.toJson(),
                              ),
                        ),
                      ),
                  child: Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 5.0,
                      vertical: 7.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Group image or fallback
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child:
                                    group.exGroupImageURL.isNotEmpty
                                        ? Image.network(
                                          group.exGroupImageURL,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        )
                                        : Container(
                                          width: 60,
                                          height: 60,
                                          color: Colors.grey.shade300,
                                          child: Icon(
                                            Icons.group,
                                            size: 32,
                                            color: Colors.grey,
                                          ),
                                        ),
                              ),
                              const SizedBox(width: 12),

                              // Group name & type
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      group.exGroupName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    if (group.exGroupDesc.isNotEmpty)
                                      Text(
                                        group.exGroupDesc,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          typeList
                                              .elementAt(
                                                int.parse(group.exGroupType),
                                              )
                                              .icon,
                                          size: 20.0,
                                        ),
                                        SizedBox(width: 5.0),
                                        Text(
                                          typeList
                                              .elementAt(
                                                int.parse(group.exGroupType),
                                              )
                                              .name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.person, size: 20.0),
                                  SizedBox(width: 5.0),
                                  Text(
                                    auth.user!.displayName!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.date_range, size: 20.0),
                                  SizedBox(width: 5.0),
                                  Text(
                                    formatDateString(group.exGroupCreatedOn),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(height: 15.0),
                              Row(
                                mainAxisAlignment:
                                    group.exGroupShared &&
                                            group.exGroupMembers.isNotEmpty
                                        ? MainAxisAlignment.spaceBetween
                                        : MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (group.exGroupShared &&
                                      group.exGroupMembers.isNotEmpty)
                                    initialsRow(group.exGroupMembers, context),
                                  if (group.exGroupShared &&
                                      group.exGroupMembers.isNotEmpty)
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.arrow_upward,
                                              color: Colors.green,
                                            ),
                                            Text(
                                              formatCurrency(
                                                group.exGroupIncome,
                                                context,
                                              ),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 5.0),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.arrow_downward,
                                              color: Colors.red,
                                            ),
                                            Text(
                                              formatCurrency(
                                                group.exGroupExpenses,
                                                context,
                                              ),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  else
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.arrow_upward,
                                              color: Colors.green,
                                            ),
                                            Text(
                                              formatCurrency(
                                                group.exGroupIncome,
                                                context,
                                              ),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 5.0),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.arrow_downward,
                                              color: Colors.red,
                                            ),
                                            Text(
                                              formatCurrency(
                                                group.exGroupExpenses,
                                                context,
                                              ),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
