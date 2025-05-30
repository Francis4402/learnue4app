

class UploadModel {
  String? sId;
  String? title;
  String? downloadUrl;
  List<String>? imageUrls;
  String? createdAt;
  String? updatedAt;
  int? iV;

  UploadModel(
      {this.sId,
        this.title,
        this.downloadUrl,
        this.imageUrls,
        this.createdAt,
        this.updatedAt,
        this.iV});

  UploadModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    downloadUrl = json['downloadUrl'];
    imageUrls = json['imageUrls'].cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    data['downloadUrl'] = downloadUrl;
    data['imageUrls'] = imageUrls;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
