class MessageUnreadModel {
  String? message;
  MessageUnreadData? data;

  MessageUnreadModel({this.message, this.data});

  MessageUnreadModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new MessageUnreadData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class MessageUnreadData {
  int? unreadMessageCount;

  MessageUnreadData({this.unreadMessageCount});

  MessageUnreadData.fromJson(Map<String, dynamic> json) {
    unreadMessageCount = json['unreadMessageCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['unreadMessageCount'] = this.unreadMessageCount;
    return data;
  }
}
