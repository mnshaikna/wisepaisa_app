import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../utils/constants.dart';
import '../utils/toast.dart';

class ApiProvider extends ChangeNotifier {
  final dio = Dio();
  bool isAPILoading = false, isTimedOut = false;
  List<Map<String, dynamic>> groupList = [],
      expenseReminderList = [],
      userExpenseList = [];

  setLoading() {
    isAPILoading = true;
    notifyListeners();
  }

  removeLoading() {
    isAPILoading = false;
    notifyListeners();
  }

  setExpenseList(List<Map<String, dynamic>> list) {
    userExpenseList = list;
    notifyListeners();
  }

  Future<Response> getHttp(
    BuildContext context,
    String baseUrl,
    String method, {
    Map<String, dynamic>? requestBody,
  }) async {
    debugPrint(baseUrl);
    debugPrint(requestBody.toString());
    debugPrint(method);
    setLoading();
    Response? response;

    final credentials = base64Encode(utf8.encode('$username:$password'));
    final basicAuth = 'Basic $credentials';

    try {
      response = await dio.request(
        baseUrl,
        data: requestBody ?? {},
        options: Options(
          method: method,
          headers: {'Authorization': basicAuth},
          responseType: ResponseType.json,
        ),
      );
      setTimedOut(false);
      debugPrint('Response from API:::${response.data.toString()}');
    } on DioException catch (e) {
      debugPrint(e.type.toString());
      if (e.type == DioExceptionType.connectionError) {
        setTimedOut(true);
        Toasts.show(context, 'Request timedout!', type: ToastType.info);
      } else {
        debugPrint(e.response!.data.toString());
        response = e.response;
        Toasts.show(context, response!.data['message'], type: ToastType.info);
        debugPrint('Error occurred during API invocation');
        debugPrint('Error is :::${e.response?.toString() ?? e.toString()}');
      }
    } finally {
      removeLoading();
    }
    return Future.value(response);
  }

  Future<Response> createGroup(
    BuildContext context,
    Map<String, dynamic> body,
  ) async {
    var finalUrl = '$baseUrl/expenseGroup/create';
    Response resp = await getHttp(context, finalUrl, 'POST', requestBody: body);
    groupList.add(body);
    notifyListeners();
    return resp;
  }

  Future<Response> updateGroup(
    BuildContext context,
    Map<String, dynamic> body,
  ) async {
    var finalUrl = '$baseUrl/expenseGroup/update';
    Response resp = await getHttp(context, finalUrl, 'PUT', requestBody: body);
    notifyListeners();
    return resp;
  }

  Future getGroups(String userId, BuildContext context) async {
    var finalUrl = '$baseUrl/expenseGroup/user/$userId';
    try {
      await getHttp(context, finalUrl, 'GET').then((Response resp) {
        debugPrint('resp:::${resp.data}');
        groupList = (resp.data as List).cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint('Error Occurred:::$e');
    }
    debugPrint('groupList Length:::${groupList.length}');
    notifyListeners();
  }

  Future<Response> deleteGroups(String groupId, BuildContext context) async {
    var finalUrl = '$baseUrl/expenseGroup/delete/$groupId';
    Response resp = await getHttp(context, finalUrl, 'DELETE');
    notifyListeners();
    return resp;
  }

  Future getReminders(String userId, BuildContext context) async {
    var finalUrl = '$baseUrl/expenseReminder/user/$userId';
    try {
      await getHttp(context, finalUrl, 'GET').then((Response resp) {
        debugPrint('resp:::${resp.data}');
        expenseReminderList = (resp.data as List).cast<Map<String, dynamic>>();
        expenseReminderList.sort((a, b) {
          final dateA = DateTime.parse(a['reminderDate']);
          final dateB = DateTime.parse(b['reminderDate']);
          return dateA.compareTo(dateB);
        });
      });
    } catch (e) {
      debugPrint('Error Occurred:::$e');
    }
    debugPrint('expenseReminderList Length:::${expenseReminderList.length}');
    notifyListeners();
  }

  Future<Response> createReminder(
    BuildContext context,
    Map<String, dynamic> body,
  ) async {
    var finalUrl = '$baseUrl/expenseReminder/create';
    Response resp = await getHttp(context, finalUrl, 'POST', requestBody: body);
    expenseReminderList.add(body);
    notifyListeners();
    return resp;
  }

  Future<Response> deleteReminder(BuildContext context, String remId) async {
    var finalUrl = '$baseUrl/expenseReminder/delete/$remId';
    Response resp = await getHttp(context, finalUrl, 'DELETE');
    notifyListeners();
    return resp;
  }

  Future<Response> updateReminder(
    BuildContext context,
    Map<String, dynamic> body,
  ) async {
    var finalUrl = '$baseUrl/expenseReminder/update';
    Response resp = await getHttp(context, finalUrl, 'PUT', requestBody: body);
    notifyListeners();
    return resp;
  }

  updateRemindersList(List<Map<String, dynamic>> newList) {
    expenseReminderList = newList;
    notifyListeners();
  }

  Future getUserExpenses(String userId, BuildContext context) async {
    var finalUrl = '$baseUrl/expense/user/$userId';
    try {
      await getHttp(context, finalUrl, 'GET').then((Response resp) {
        debugPrint('resp:::${resp.data}');
        userExpenseList = (resp.data as List).cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint('Error Occurred:::$e');
    }
    debugPrint('userExpenseList Length:::${userExpenseList.length}');
    notifyListeners();
  }

  Future<Response> createExpense(
    BuildContext context,
    Map<String, dynamic> body,
  ) async {
    var finalUrl = '$baseUrl/expense/create';
    Response resp = await getHttp(context, finalUrl, 'POST', requestBody: body);
    userExpenseList.add(body);
    notifyListeners();
    return resp;
  }

  Future<Response> deleteExpense(BuildContext context, String expId) async {
    var finalUrl = '$baseUrl/expense/delete/$expId';
    Response resp = await getHttp(context, finalUrl, 'DELETE');
    notifyListeners();
    return resp;
  }

  void setTimedOut(bool timedOut) {
    isTimedOut = timedOut;
    notifyListeners();
  }
}
