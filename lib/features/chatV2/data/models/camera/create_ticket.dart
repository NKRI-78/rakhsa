class CreateTicketModel {
  String? message;
  TicketData? data;

  CreateTicketModel({this.message, this.data});

  CreateTicketModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? TicketData.fromJson(json['data']) : null;
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

class TicketData {
  String? status;
  int? latitude;
  int? longitude;
  int? id;
  String? issueType;
  String? description;
  String? priority;
  String? userId;
  Media? media;
  String? updatedAt;
  String? createdAt;

  TicketData(
      {this.status,
      this.latitude,
      this.longitude,
      this.id,
      this.issueType,
      this.description,
      this.priority,
      this.userId,
      this.media,
      this.updatedAt,
      this.createdAt});

  TicketData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    id = json['id'];
    issueType = json['issue_type'];
    description = json['description'];
    priority = json['priority'];
    userId = json['user_id'];
    media = json['media'] != null ? Media.fromJson(json['media']) : null;
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['id'] = id;
    data['issue_type'] = issueType;
    data['description'] = description;
    data['priority'] = priority;
    data['user_id'] = userId;
    if (media != null) {
      data['media'] = media!.toJson();
    }
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
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
