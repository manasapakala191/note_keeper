
class NoteModel{
  String title;
  String description;
  String imageURL;
  String taskID;
  DateTime createdOn;
  DateTime lastEdited;
  // NoteModel(this.taskID,this.title,this.description,this.imageURL);

  NoteModel({
   this.taskID, this.title,this.description,this.imageURL,this.createdOn,this.lastEdited
  });
  factory NoteModel.fromJSON(Map json, String taskID1){
    return NoteModel(
      taskID: taskID1,
      title: json["name"],
      description: json["description"],
      imageURL: json["imageURL"],
      lastEdited: json["lastEdited"]!=null?json["lastEdited"].toDate() :null,
      createdOn: json["createdOn"]!=null? json["createdOn"].toDate() : null,
    );
  }
}