import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wisepaise/models/group_model.dart';
import 'package:wisepaise/providers/api_provider.dart';
import 'package:wisepaise/providers/auth_provider.dart';

import '../models/type_model.dart';
import '../utils/dialog_utils.dart';
import '../utils/toast.dart';
import '../utils/utils.dart';
import 'package:intl/intl.dart';

import 'expense_group_details_page.dart';

class CreateExpenseGroupPage extends StatefulWidget {
  const CreateExpenseGroupPage({super.key});

  @override
  State<CreateExpenseGroupPage> createState() => _CreateExpenseGroupPageState();
}

class _CreateExpenseGroupPageState extends State<CreateExpenseGroupPage> {
  bool isGroup = false, isError = false;
  Uint8List? imageBytes;
  int? selectedGroupTypeIndex;
  double verticalGap = 15.0;
  List<String> groupMembers = [];
  TextEditingController memberController = TextEditingController(),
      groupNameController = TextEditingController(),
      groupDescController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(centerTitle: true, title: Text('Create a group')),
      body: Consumer<ApiProvider>(
        builder: (_, api, __) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 15.0,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Row(
                              children: [
                                imageBytes != null
                                    ? GestureDetector(
                                      onLongPress: () {
                                        setState(() {
                                          imageBytes = null;
                                        });
                                        Toasts.show(
                                          context,
                                          'Image removed',
                                          type: ToastType.info,
                                        );
                                      },
                                      child: Container(
                                        height: 60.0,
                                        width: 60.0,
                                        padding: EdgeInsets.all(0.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12.0,
                                          ),
                                          border: Border.all(
                                            width: 0.0,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Colors.black54
                                                    : Colors.white54,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12.0,
                                          ),
                                          child: Image.memory(
                                            imageBytes as Uint8List,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    )
                                    : Card(
                                      elevation: 1.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                        onTap:
                                            () =>
                                                _showAttachmentOptions(context),
                                        splashColor: Colors.grey.shade500,
                                        child: Container(
                                          padding: EdgeInsets.all(15.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12.0,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.add_a_photo_outlined,
                                          ),
                                        ),
                                      ),
                                    ),
                                SizedBox(width: 5.0),
                                Expanded(
                                  child: TextField(
                                    controller: groupNameController,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    decoration: InputDecoration(
                                      labelText: 'Group name',
                                      border: buildOutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: verticalGap),
                            TextField(
                              maxLines: 3,
                              maxLength: 1000,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              controller: groupDescController,
                              textInputAction: TextInputAction.newline,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: 'Group Desc (Optional)',
                                border: buildOutlineInputBorder(),
                              ),
                            ),
                            Text(
                              'Group Type',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17.5,
                                letterSpacing: 1.5,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 10.0),
                            Center(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.start,
                                alignment: WrapAlignment.start,
                                direction: Axis.horizontal,
                                spacing: 10.0,
                                runSpacing: 10.0,
                                children: List.generate(typeList.length, (
                                  int index,
                                ) {
                                  GroupType thisType = typeList.elementAt(
                                    index,
                                  );
                                  return Card(
                                    //elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12.0),
                                      onTap: () {
                                        setState(() {
                                          selectedGroupTypeIndex = index;
                                        });
                                      },
                                      child: Container(
                                        width: 80.0,
                                        padding: EdgeInsets.all(15.0),
                                        decoration: BoxDecoration(
                                          color:
                                              selectedGroupTypeIndex == index
                                                  ? (Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.light
                                                      ? Colors.white70
                                                      : Colors.grey.shade800)
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            12.0,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(thisType.icon),
                                            Text(thisType.name),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            SizedBox(height: verticalGap),
                            SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              title: Text(
                                'Shared Group',
                                style: TextStyle(
                                  fontSize: 17.5,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text('Group involves other people?'),
                              activeColor: Colors.blue,
                              value: isGroup,
                              onChanged: (bool value) {
                                setState(() {
                                  isGroup = value;
                                });
                                if (!isGroup && groupMembers.isNotEmpty) {
                                  DialogUtils.showGenericDialog(
                                    context: context,
                                    title: DialogUtils.titleText(
                                      'Remove Members?',
                                    ),
                                    message: Text(
                                      'Remove all ${groupMembers.length} added Members?',
                                      style: TextStyle(
                                        letterSpacing: 1.5,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    confirmColor: Colors.green,
                                    showCancel: true,
                                    cancelText: 'Remove',
                                    confirmText: 'Keep',
                                    onCancel: () {
                                      Navigator.of(context).pop();
                                      setState(() => groupMembers.clear());
                                      Toasts.show(
                                        context,
                                        'All members removed',
                                        type: ToastType.info,
                                      );
                                    },
                                    onConfirm:
                                        () => Navigator.of(context).pop(),
                                  );
                                }
                              },
                            ),
                            SizedBox(height: verticalGap),
                            Visibility(
                              visible: isGroup,
                              child:
                                  groupMembers.isEmpty
                                      ? buildCreateDataBox(
                                        context,
                                        "Share Expenses with friends?\n\n➕ Add members to this group",
                                        () {
                                          showAddMembersDialog(context);
                                        },
                                        LinearGradient(
                                          colors: [
                                            Color(0xFFEFEFBB),
                                            Color(0xFFD4D3DD),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      )
                                      : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Group Members',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17.5,
                                              letterSpacing: 1.5,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                          SizedBox(height: verticalGap),
                                          Wrap(
                                            runSpacing: 10.0,
                                            spacing: 10.0,
                                            children:
                                                groupMembers.map<Widget>((e) {
                                                    return GestureDetector(
                                                      onLongPress: () {
                                                        setState(() {
                                                          groupMembers.remove(
                                                            e,
                                                          );
                                                          Toasts.show(
                                                            context,
                                                            'Member $e removed',
                                                            type:
                                                                ToastType.info,
                                                          );
                                                        });
                                                      },
                                                      child: SizedBox(
                                                        width: 85.0,
                                                        child: Column(
                                                          children: [
                                                            CircleAvatar(
                                                              maxRadius: 30.0,
                                                              child: Icon(
                                                                Icons.person,
                                                                size: 30.0,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 5.0,
                                                            ),
                                                            Text(
                                                              e,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              softWrap: true,
                                                              maxLines: 2,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }).toList()
                                                  ..add(
                                                    GestureDetector(
                                                      onTap: () {
                                                        showAddMembersDialog(
                                                          context,
                                                        );
                                                      },
                                                      child: Column(
                                                        children: [
                                                          CircleAvatar(
                                                            maxRadius: 30.0,
                                                            child: Icon(
                                                              Icons.person_add,
                                                            ),
                                                          ),
                                                          SizedBox(height: 5.0),
                                                          Text('Add Members'),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: verticalGap),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            AuthProvider authProv = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            if (checkForm()) {
                              GroupModel group = GroupModel(
                                exGroupId: '',
                                exGroupName: groupNameController.text.trim(),
                                exGroupDesc: groupDescController.text.trim(),
                                exGroupImageURL: '',
                                exGroupType: selectedGroupTypeIndex.toString(),
                                exGroupShared: isGroup,
                                exGroupMembers: groupMembers,
                                exGroupOwnerId: authProv.user!.id,
                                exGroupCreatedOn: DateFormat(
                                  'yyyy-MM-dd HH:mm:ss',
                                ).format(DateTime.now()),
                                expenses: [],
                                exGroupExpenses: 0,
                                exGroupIncome: 0,
                              );
                              Map<String, dynamic> groupMap = group.toJson();
                              api.createGroup(context, groupMap).then((
                                Response resp,
                              ) {
                                Toasts.show(
                                  context,
                                  'Group ${group.exGroupName} created',
                                  type: ToastType.success,
                                );
                                clearForm();
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ExpenseGroupDetailsPage(
                                          groupMap: groupMap,
                                        ),
                                  ),
                                );
                              });
                            }
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Create Group'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            textStyle: TextStyle(
                              fontSize: 15.0,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: verticalGap),
                  ],
                ),
              ),
              if (api.isAPILoading) buildLoadingContainer(context: context),
            ],
          );
        },
      ),
    );
  }

  OutlineInputBorder buildOutlineInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(width: 0.25),
    );
  }

  void showAddMembersDialog(BuildContext context) {
    DialogUtils.showGenericDialog(
      context: context,
      title: Text(
        'Add Members',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17.5,
          letterSpacing: 1.5,
        ),
        textAlign: TextAlign.left,
      ),
      message: Form(
        key: _formKey,
        child: TextFormField(
          validator: (String? str) {
            if (str!.trim().isEmpty) {
              return 'Enter a name';
            }
            return null;
          },
          controller: memberController,
          autofocus: true,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(),
        ),
      ),
      cancelText: 'Cancel',
      confirmText: 'Add',
      onCancel: () {
        memberController.clear();
        unfocusKeyboard();
        Navigator.of(context).pop();
      },
      onConfirm: () {
        if (_formKey.currentState!.validate()) {
          setState(() {
            groupMembers.add(memberController.text.trim());
          });
          memberController.clear();
          unfocusKeyboard();
          Navigator.of(context).pop();

          debugPrint('groupMembers:::${groupMembers.length}');
        }
      },
      showCancel: true,
      confirmColor: Colors.lightBlue,
    );
  }

  bool checkForm() {
    if (groupNameController.text.isEmpty) {
      Toasts.show(context, 'Enter Group name', type: ToastType.error);
      return false;
    }
    if (selectedGroupTypeIndex == null) {
      Toasts.show(context, 'Select a Type', type: ToastType.error);
      return false;
    }
    if (isGroup && groupMembers.isEmpty) {
      Toasts.show(context, 'Add members to group', type: ToastType.error);
      return false;
    }
    return true;
  }

  clearForm() {
    setState(() {
      groupDescController.clear();
      groupNameController.clear();
      isGroup = false;
      groupMembers = [];
      selectedGroupTypeIndex = null;
    });
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Wrap(
              children: [
                Center(
                  child: Container(
                    height: 5.0,
                    width: 50.0,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  leading: const Icon(Icons.camera_alt, color: Colors.purple),
                  title: const Text("Take a photo"),
                  onTap: () async {
                    Navigator.pop(context);
                    await pickFile(pickType: ImageSource.camera).then((bytes) {
                      setState(() {
                        imageBytes = bytes!;
                      });
                    });
                  },
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  leading: const Icon(Icons.image, color: Colors.green),
                  title: const Text("Choose from gallery"),
                  onTap: () async {
                    Navigator.pop(context);
                    await pickFile(pickType: ImageSource.gallery).then((bytes) {
                      setState(() {
                        imageBytes = bytes!;
                      });
                    });
                    // open gallery picker
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
