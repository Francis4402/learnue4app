class UploadModel {
  String? id;
  String? title;
  String? downloadUrl;
  String? imageUrls;
  String? createdAt;
  String? updatedAt;

  UploadModel({
    this.id,
    this.title,
    this.downloadUrl,
    this.imageUrls,
    this.createdAt,
    this.updatedAt,
  });

  UploadModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    title = json['title'];
    downloadUrl = json['downloadUrl'];
    imageUrls = json['imageUrls'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['title'] = title;
    data['downloadUrl'] = downloadUrl;
    data['imageUrls'] = imageUrls;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}