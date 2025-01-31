class ChatsV2Model {
  String? message;
  ChatData? data;

  ChatsV2Model({this.message, this.data});

  ChatsV2Model.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new ChatData.fromJson(json['data']) : null;
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

class ChatData {
  int? id;
  String? userId;
  String? issueType;
  String? description;
  String? status;
  String? priority;
  Media? media;
  double? latitude;
  double? longitude;
  String? resolvedAt;
  String? messageClose;
  String? assignedTo;
  String? createdAt;
  String? updatedAt;
  Staff? staff;
  Staff? user;
  List<MessagesData>? messages;

  ChatData(
      {this.id,
      this.userId,
      this.issueType,
      this.description,
      this.status,
      this.priority,
      this.media,
      this.latitude,
      this.longitude,
      this.resolvedAt,
      this.messageClose,
      this.assignedTo,
      this.createdAt,
      this.updatedAt,
      this.staff,
      this.user,
      this.messages});

  ChatData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    issueType = json['issue_type'];
    description = json['description'];
    status = json['status'];
    priority = json['priority'];
    media = json['media'] != null ? new Media.fromJson(json['media']) : null;
    latitude = json['latitude'];
    longitude = json['longitude'];
    resolvedAt = json['resolved_at'];
    messageClose = json['message_close'];
    assignedTo = json['assigned_to'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    staff = json['Staff'] != null ? new Staff.fromJson(json['Staff']) : null;
    user = json['User'] != null ? new Staff.fromJson(json['User']) : null;
    if (json['messages'] != null) {
      messages = <MessagesData>[];
      json['messages'].forEach((v) {
        messages!.add(new MessagesData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['issue_type'] = this.issueType;
    data['description'] = this.description;
    data['status'] = this.status;
    data['priority'] = this.priority;
    if (this.media != null) {
      data['media'] = this.media!.toJson();
    }
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['resolved_at'] = this.resolvedAt;
    data['assigned_to'] = this.assignedTo;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.staff != null) {
      data['Staff'] = this.staff!.toJson();
    }
    if (this.user != null) {
      data['User'] = this.user!.toJson();
    }
    if (this.messages != null) {
      data['messages'] = this.messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Media {
  String? link;
  String? type;

  Media({this.link, this.type});

  Media.fromJson(Map<String, dynamic> json) {
    link = json['link'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['link'] = this.link;
    data['type'] = this.type;
    return data;
  }
}

class Staff {
  String? email;
  String? phone;
  String? role;
  String? id;
  Profile? profile;

  Staff({this.email, this.phone, this.role, this.id, this.profile});

  Staff.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    phone = json['phone'];
    role = json['role'];
    id = json['id'];
    profile =
        json['profile'] != null ? new Profile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['role'] = this.role;
    data['id'] = this.id;
    if (this.profile != null) {
      data['profile'] = this.profile!.toJson();
    }
    return data;
  }
}

class Profile {
  String? fullname;
  String? photoUrl;

  Profile({this.fullname, this.photoUrl});

  Profile.fromJson(Map<String, dynamic> json) {
    fullname = json['fullname'];
    photoUrl = json['photo_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fullname'] = this.fullname;
    data['photo_url'] = this.photoUrl;
    return data;
  }
}

class MessagesData {
  int? id;
  int? ticketId;
  String? senderId;
  String? message;
  String? createdAt;
  String? updatedAt;
  Staff? sender;

  MessagesData(
      {this.id,
      this.ticketId,
      this.senderId,
      this.message,
      this.createdAt,
      this.updatedAt,
      this.sender});

  MessagesData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ticketId = json['ticket_id'];
    senderId = json['sender_id'];
    message = json['message'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    sender = json['sender'] != null ? new Staff.fromJson(json['sender']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['ticket_id'] = this.ticketId;
    data['sender_id'] = this.senderId;
    data['message'] = this.message;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.sender != null) {
      data['sender'] = this.sender!.toJson();
    }
    return data;
  }
}
