
#define HAPP_PURPLE_COLOR [UIColor colorWithRed:0.667 green:0.016 blue:0.439 alpha:1] /*#aa0470*/
#define HAPP_PURPLE_ALPHA_COLOR [UIColor colorWithRed:130/255.0f green:4/255.0f blue:112/255.0f alpha:0.21f]
#define HAPP_WHITE_COLOR [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0f]
#define HAPP_BLACK_COLOR [UIColor colorWithRed:0.188 green:0.188 blue:0.188 alpha:1]
#define HAPP_DIVIDER_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]

typedef enum HappModelMoods {
    HappModelMoodChill = 1,
    HappModelMoodFood = 2,
    HappModelMoodMovie = 3,
    HappModelMoodParty = 4,
    HappModelMoodSports = 5,
    HappModelMoodInvalid = 6,
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