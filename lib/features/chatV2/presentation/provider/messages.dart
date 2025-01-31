import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/helpers/storage.dart';
import 'package:rakhsa/features/chatV2/data/models/chat/chats.dart';
import 'package:rakhsa/features/chatV2/data/models/chat/chats_v2.dart';
import 'package:rakhsa/features/chatV2/data/models/chat/message_unread.dart';

enum MessageStatus { idle, loading, loaded, empty, error, Closed }
enum MessageHistoryStatus { idle, loading, loaded, empty, error }
enum MessageCountStatus { idle, loading, loaded, empty, error }

class MessageProvider with ChangeNotifier {
  Dio dio = Dio();

  MessageStatus _messageStatus = MessageStatus.idle;
  MessageStatus get messageStatus => _messageStatus;
  
  MessageHistoryStatus _messageHistoryStatus = MessageHistoryStatus.idle;
  MessageHistoryStatus get messageHistoryStatus => _messageHistoryStatus;

  MessageCountStatus _messageCountStatus = MessageCountStatus.idle;
  MessageCountStatus get messageCountStatus => _messageCountStatus;

  String status = "";
  String message = "";

  double _rating = 0.0;
  double get rating => _rating;

  void onChangeRating({required double selectedRating}) {
    _rating = selectedRating;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  ChatData _chatData = ChatData();
  ChatData get chatData => _chatData;

  ChatsData _chatsData = ChatsData();
  ChatsData get chatsData => _chatsData;

  MessageUnreadData _messageUnreadData = MessageUnreadData();
  MessageUnreadData get messageUnreadData => _messageUnreadData;

  void setMessageStatus(MessageStatus messageStatus) {
    print("Status m : ${messageStatus}");
    _messageStatus = messageStatus;
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void setMessageHistoryStatus(MessageHistoryStatus messageHistoryStatus) {
    print("Status h : ${messageHistoryStatus}");
    _messageHistoryStatus = messageHistoryStatus;
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void setMessageCountStatus(MessageCountStatus messageCountStatus) {
    print("Status c : ${messageCountStatus}");
    _messageCountStatus = messageCountStatus;
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void setStatus(String messageStatus) {
    print("Status : ${messageStatus}");
    status = messageStatus;
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void setMessage(String setMessage) {
    print("Message : ${setMessage}");
    message = setMessage;
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> getMessage(String ticketId) async {
    setMessageStatus(MessageStatus.loading);
    String? token = await StorageHelper.getToken();
    print("Ticket ID : $token");
    try {  
      var response = await http.get(
      Uri.parse(
          '${RemoteDataSourceConsts.baseUrlApiMarlinda}/api/v1/ticket/messages/$ticketId'),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token"
      });
      if (response.statusCode == 200) {
        _chatData = ChatData.fromJson(jsonDecode(response.body)['data']);
      }
      setMessageStatus(MessageStatus.loaded);
    } catch (e) {
      print("Error Messages $e");
      setMessageStatus(MessageStatus.error);
    }
  }

  Future<void> resolveTicket(String ticketId, String ratingValue) async {
    String? token = await StorageHelper.getToken();
    print("Ticket ID : $token");
    try {  
      // var response = await http.post(
      // Uri.parse('${AppConstants.baseUrlAmuletNew}/api/v1/ticket/resolved/${ticketId}'),
      // body: json.encode({
      //   "rating": ratingValue
      // }),
      // headers: {
      //   HttpHeaders.authorizationHeader: "Bearer $token"
      // });

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      };
      var request = http.Request('POST', Uri.parse('${RemoteDataSourceConsts.baseUrlApiMarlinda}/api/v1/ticket/resolved/$ticketId'));
      request.body = json.encode({
        "rating": ratingValue
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print("Response : ${await response.stream.bytesToString()}");
      }
      else {
        print(response.reasonPhrase);
      }
      print("Rating Now : $ratingValue");
    } catch (e) {
      debugPrint("Error Messages $e");
    }
  }

  Future<void> getChatsHistory() async {
    setMessageHistoryStatus(MessageHistoryStatus.loading);
    try {  
      String? token = await StorageHelper.getToken();
      print("Ticket ID : $token");
      var response = await http.get(
      Uri.parse(
          '${RemoteDataSourceConsts.baseUrlApiMarlinda}/api/v1/ticket/last'),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token"
      });
      if (response.statusCode == 200) {
        _chatsData = ChatsData.fromJson(jsonDecode(response.body)['data']);
      }
      debugPrint("Data Chats ${_chatsData.id}");
      setMessageHistoryStatus(MessageHistoryStatus.loaded);
    } catch (e) {
      debugPrint("Error Messages $e");
      setMessageHistoryStatus(MessageHistoryStatus.error);
    }
  }

  Future<void> getUnread(String idTicket) async {
    try {  
      String? token = await StorageHelper.getToken();
      Dio dio = Dio();
      await dio.post("${RemoteDataSourceConsts.baseUrlApiMarlinda}/api/v1/ticket/read/$idTicket/messages", 
        options: Options(
          headers: {
            "Authorization": "Bearer ${token}"
          }
        )
      );
      print("Berhasil");
    } catch (e) {
      debugPrint("Error Messages $e");
    }
  }

  Future<void> getCountMessageUnread() async {
    setMessageCountStatus(MessageCountStatus.loading);
    try {  
      String? token = await StorageHelper.getToken();
      print("Ticket ID : $token");
      var response = await http.get(
      Uri.parse(
          '${RemoteDataSourceConsts.baseUrlApiMarlinda}/api/v1/ticket/unread/count'),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token"
      });
      if (response.statusCode == 200) {
        _messageUnreadData = MessageUnreadData.fromJson(jsonDecode(response.body)['data']);
      }
      debugPrint("Data Chats ${_chatsData.id}");
      setMessageCountStatus(MessageCountStatus.loaded);
    } catch (e) {
      debugPrint("Error Messages $e");
      setMessageCountStatus(MessageCountStatus.error);
    }
  }


}