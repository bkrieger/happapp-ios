
typedef enum HappModelMoods {
    HappModelMoodChill = 1,
    HappModelMoodFood = 2,
    HappModelMoodMovie = 4,
    HappModelMoodParty = 8,
    HappModelMoodDefault = HappModelMoodChill
} HappModelMood;

typedef enum HappModelDurations {
    HappModelDurationHalfHour = 1800,
    HappModelDurationOneHour = 3600,
    HappModelDurationTwoHour = 7200,
    HappModelDurationThreeHour = 10800,
    HappModelDurationFourHour = 14400,
    HappModelDurationDefault = HappModelDurationTwoHour
} HappModelDuration;