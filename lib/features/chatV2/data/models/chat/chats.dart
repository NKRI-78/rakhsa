class ChatsModel {
  String? message;
  ChatsData? data;

  ChatsModel({this.message, this.data});

  ChatsModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? ChatsData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ChatsData {
  int? id;
  String? userId;
  String? issueType;
  String? description;
  String? status;
  String? priority;
  String? readAt;
  Media? media;
  double? latitude;
  double? longitude;
  String? resolvedAt;
  String? messageClose;
  int? rating;
  String? note;
  String? assignedTo;
  String? createdAt;
  String? updatedAt;
  Staff? staff;
  Staff? user;
  List<Messages>? messages;

  ChatsData(
      {this.id,
      this.userId,
      this.issueType,
      this.description,
      this.status,
      this.priority,
      this.readAt,
      this.media,
      this.latitude,
      this.longitude,
      this.resolvedAt,
      this.messageClose,
      this.rating,
      this.note,
      this.assignedTo,
      this.createdAt,
      this.updatedAt,
      this.staff,
      this.user,
      this.messages});

  ChatsData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    issueType = json['issue_type'];
    description = json['description'];
    status = json['status'];
    priority = json['priority'];
    readAt = json['read_at'];
    media = json['media'] != null ? Media.fromJson(json['media']) : null;
    latitude = json['latitude'];
    longitude = json['longitude'];
    resolvedAt = json['resolved_at'];
    messageClose = json['message_close'];
    rating = json['rating'];
    note = json['note'];
    assignedTo = json['assigned_to'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    staff = json['Staff'] != null ? Staff.fromJson(json['Staff']) : null;
    user = json['User'] != null ? Staff.fromJson(json['User']) : null;
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(Messages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['issue_type'] = issueType;
    data['description'] = description;
    data['status'] = status;
    data['priority'] = priority;
    data['read_at'] = readAt;
    if (media != null) {
      data['media'] = media!.toJson();
    }
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['resolved_at'] = resolvedAt;
    data['message_close'] = messageClose;
    data['rating'] = rating;
    data['note'] = note;
    data['assigned_to'] = assignedTo;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (staff != null) {
      data['Staff'] = staff!.toJson();
    }
    if (user != null) {
      data['User'] = user!.toJson();
    }
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['link'] = link;
    data['type'] = type;
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
        json['profile'] != null ? Profile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['phone'] = phone;
    data['role'] = role;
    data['id'] = id;
    if (profile != null) {
      data['profile'] = profile!.toJson();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fullname'] = fullname;
    data['photo_url'] = photoUrl;
    return data;
  }
}

class Messages {
  String? message;
  String? createdAt;
  Sender? sender;

  Messages({this.message, this.createdAt, this.sender});

  Messages.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    createdAt = json['created_at'];
    sender =
        json['sender'] != null ? Sender.fromJson(json['sender']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['created_at'] = createdAt;
    if (sender != null) {
      data['sender'] = sender!.toJson();
    }
    return data;
  }
}

class Sender {
  String? email;
  String? phone;
  Profile? profile;

  Sender({this.email, this.phone, this.profile});

  Sender.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    phone = json['phone'];
    profile =
        json['profile'] != null ? Profile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['phone'] = phone;
    if (profile != null) {
      data['profile'] = profile!.toJson();
    }
    return data;
  }
}
