class GraphQLQueries {
  static String getAnimeDetails(int animeId) {
    return """
      query {
        Media(id: $animeId, type: ANIME) {
          id
          title {
            romaji
            english
          }
          description(asHtml: false)
          coverImage {
            large
          }
          bannerImage
          averageScore
          genres
          status
          episodes
          startDate {
            year
            month
            day
          }
          studios(isMain: true) {
            nodes {
              name
            }
          }
          trailer {
            site
            id
          }
          characters {
            edges {
              node {
                name {
                  full
                }
                image {
                  large
                }
              }
              voiceActors(language: JAPANESE) {
                name {
                  full
                }
                image {
                  large
                }
              }
            }
          }
        }
      }
    """;
  }
}
