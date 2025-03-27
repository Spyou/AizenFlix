class CastModel {
  final int? characterId;
  final String? characterName;
  final String? characterImage;
  final int? voiceActorId;
  final String? voiceActorName;
  final String? voiceActorImage;

  CastModel({
    this.characterId,
    this.characterName,
    this.characterImage,
    this.voiceActorId,
    this.voiceActorName,
    this.voiceActorImage,
  });

  // ✅ Convert JSON to CastModel Object
  factory CastModel.fromJson(Map<String, dynamic> json) {
    final character = json['node'];
    final voiceActors = json['voiceActors'] ?? [];
    final voiceActor = voiceActors.isNotEmpty ? voiceActors[0] : null;

    return CastModel(
      characterId: character?['id'],
      characterName: character?['name']?['full'],
      characterImage: character?['image']?['large'],
      voiceActorId: voiceActor?['id'],
      voiceActorName: voiceActor?['name']?['full'],
      voiceActorImage: voiceActor?['image']?['large'],
    );
  }

  // ✅ Convert CastModel Object to JSON
  Map<String, dynamic> toJson() {
    return {
      "characterId": characterId,
      "characterName": characterName,
      "characterImage": characterImage,
      "voiceActorId": voiceActorId,
      "voiceActorName": voiceActorName,
      "voiceActorImage": voiceActorImage,
    };
  }
}
