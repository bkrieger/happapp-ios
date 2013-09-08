
#define HAPP_PURPLE_COLOR [UIColor colorWithRed:130/255.0f green:4/255.0f blue:112/255.0f alpha:1.0f]
#define HAPP_WHITE_COLOR [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0f]
#define HAPP_BLACK_COLOR [UIColor blackColor]
#define HAPP_DIVIDER_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]

typedef enum HappModelMoods {
    HappModelMoodChill,
    HappModelMoodFood,
    HappModelMoodMovie,
    HappModelMoodParty,
    HappModelMoodSports,
    HappModelMoodInvalid,
    HappModelMoodDefault = HappModelMoodChill
} HappModelMood;

typedef enum HappModelDurations {
    HappModelDurationHalfHour,
    HappModelDurationOneHour,
    HappModelDurationTwoHour,
    HappModelDurationThreeHour,
    HappModelDurationFourHour,
    HappModelDurationInvalid,
    HappModelDurationDefault = HappModelDurationTwoHour
} HappModelDuration;