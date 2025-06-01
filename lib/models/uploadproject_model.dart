class UploadModel {
  String? id;
  String? title;
  String? downloadUrl;
  List<String>? images;
  String? createdAt;
  String? updatedAt;

  UploadModel({
    this.id,
    this.title,
    this.downloadUrl,
    this.images,
    this.createdAt,
    this.updatedAt,
  });

  UploadModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    title = json['title'];
    downloadUrl = json['downloadUrl'];
    images = json['images'] != null ? List<String>.from(json['images']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['title'] = title;
    data['downloadUrl'] = downloadUrl;
    data['images'] = images;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}