<?php

if (! defined('BAN_DURATION_LONG_TERM')) {
    define('BAN_DURATION_LONG_TERM', 60 * 24 * 365); // 1 year in minutes
}

return [
    1 => [
        'title' => 'No Hate Speech (racism, sexism, homophobia, etc.)',
        'description' => 'Zero tolerance for discriminatory language or slurs.',
        'escalations' => [
            [
                'type' => 'mute',
                'duration_in_minutes' => 5,
                'reason' => 'Warning: Hate speech is not tolerated. This includes racism, sexism, homophobia, or discriminatory language. [1st Offense]',
                'reason_ai' => 'Automated Warning: Hate speech is not tolerated. This includes racism, sexism, homophobia, or discriminatory language. [AI Detected Offense]',
                'is_ai_enforcable' => true,
            ],
            [
                'type' => 'mute',
                'duration_in_minutes' => 60,
                'reason' => 'Warning: Hate speech is not tolerated. This includes racism, sexism, homophobia, or discriminatory language. [2nd Offense]',
                'reason_ai' => 'Automated Warning: Second violation of hate speech policy. Discriminatory language and slurs are strictly prohibited. [AI Detected Offense]',
                'is_ai_enforcable' => true,
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60,
                'reason' => 'Third violation for hate speech. Continued discriminatory language will result in extended removal. [3rd Offense]',
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 30,
                'reason' => 'Fourth violation for hate speech. Continued discriminatory language will result in extended removal. [4th Offense]',
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60 * 24,
                'reason' => 'Fifth violation for hate speech. Repeated discriminatory language will result in extended removal. [5th Offense]',
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => BAN_DURATION_LONG_TERM,
                'reason' => 'Repeated violation of hate speech policy. Continued use of discriminatory language will result in extended removal. [Repeated Offense]',
            ],
        ],
    ],
    2 => [
        'title' => 'No Harassment or Personal Attacks',
        'description' => 'Don\'t target, bully, or repeatedly provoke other players. This includes doxxing or sharing personal information.',
        'escalations' => [
            [
                'type' => 'mute',
                'duration_in_minutes' => 5,
                'reason' => 'Warning: Harassment and personal attacks are prohibited. This includes targeting, bullying, or provoking other players. [1st Offense]',
                'reason_ai' => 'Automated Warning: Harassment and personal attacks are prohibited. This includes targeting, bullying, or provoking other players. [AI Detected Offense]',
                'is_ai_enforcable' => true,
            ],
            [
                'type' => 'mute',
                'duration_in_minutes' => 10,
                'reason' => 'Warning: Harassment and personal attacks are prohibited. This includes targeting, bullying, or provoking other players. [2nd Offense]',
                'reason_ai' => 'Automated Warning: Second violation of harassment policy. Continued targeting or bullying behavior is unacceptable. [AI Detected Offense]',
                'is_ai_enforcable' => true,
            ],
            [
                'type' => 'mute',
                'duration_in_minutes' => 30,
                'reason' => 'Third violation for harassment. Continued targeting or bullying behavior is unacceptable. [3rd Offense]',
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60,
                'reason' => 'Fourth violation for harassment. Repeated bullying behavior will result in extended removal. [4th Offense]',
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60 * 24,
                'reason' => 'Fifth violation for harassment. Continued bullying behavior will result in extended removal. [5th Offense]',
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => BAN_DURATION_LONG_TERM,
                'reason' => 'Repeated violation of harassment policy. Continued targeting or bullying behavior will result in extended removal. [Repeated Offense]',
            ],
        ],
    ],
    3 => [
        'title' => 'No Spamming, Flooding Chat, nor Advertising',
        'description' => 'Avoid sending repeated messages, voice spam, or disruptive sounds. Do not advertise other servers, services or products.',
        'escalations' => [
            [
                'type' => 'mute',
                'duration_in_minutes' => 5,
                'reason' => 'Warning: Please avoid spamming, flooding chat with repeated messages or disruptive sounds or advertising other servers, services or products. [1st Offense]',
                'reason_ai' => 'Automated Warning: Please avoid spamming, flooding chat with repeated messages or disruptive sounds or advertising other servers, services or products. [AI Detected Offense]',
                'is_ai_enforcable' => true,
            ],
            [
                'type' => 'mute',
                'duration_in_minutes' => 15,
                'reason' => 'Warning: Second violation for spamming or flooding chat. Please keep chat clear and avoid repeated or disruptive messages. [2nd Offense]',
                'reason_ai' => 'Automated Warning: Second violation for spamming or flooding chat. Please keep chat clear and avoid repeated or disruptive messages. [AI Detected Offense]',
                'is_ai_enforcable' => true,
            ],
            [
                'type' => 'mute',
                'duration_in_minutes' => 60,
                'reason' => 'Third violation for spamming or flooding chat. Continued disruptive behavior will result in extended removal. [3rd Offense]',
                'reason_ai' => 'Automated Warning: Third violation for spamming or flooding chat behavior. Continued disruptive behavior will result in extended removal. [AI Detected Offense]',
                'is_ai_enforcable' => true,
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60,
                'reason' => 'Fourth violation for spamming or flooding chat. Continued disruptive behavior will result in extended removal. [4th Offense]',
                'reason_ai' => 'Automated Warning: Fourth violation for spamming or flooding chat. Continued disruptive behavior will result in extended removal. [AI Detected Offense]',
                'is_ai_enforcable' => true,
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60 * 24,
                'reason' => 'Fifth violation for spamming or flooding chat. Continued disruptive behavior will result in extended removal. [5th Offense]',
                'reason_ai' => 'Automated Warning: Fifth violation for spamming or flooding chat. Continued disruptive behavior will result in extended removal. [AI Detected Offense]',
                'is_ai_enforcable' => true,
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60 * 24 * 7,
                'reason' => 'Sixth violation for spamming or flooding chat. Continued disruptive behavior will result in extended removal. [6th Offense]',
                'reason_ai' => 'Automated Warning: Sixth violation for spamming or flooding chat. Continued disruptive behavior will result in extended removal. [AI Detected Offense]',
                'is_ai_enforcable' => true,
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60 * 24 * 30,
                'reason' => 'Repeated violation of spamming or flooding chat. Continued disruptive behavior will result in extended removal. [Repeated Offense]',
            ],
        ],
    ],
    4 => [
        'title' => 'No Impersonation or Misleading Claims',
        'description' => 'Do not pretend to be staff or mislead others with false info.',
        'escalations' => [
            [
                'type' => 'mute',
                'duration_in_minutes' => 10,
                'reason' => 'Warning: Impersonation of staff or spreading misleading information is prohibited. [1st Offense]',
                'reason_ai' => 'Automated Warning: Impersonation of staff or spreading misleading information is prohibited. [AI Detected Offense]',
                'is_ai_enforcable' => true,
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60,
                'reason' => 'Second violation for impersonation or misleading claims. Do not pretend to be staff or spread false information. [2nd Offense]',
                'reason_ai' => 'Automated Warning: Second violation for impersonation or misleading claims. Continued deceptive behavior is unacceptable. [AI Detected Offense]',
                'is_ai_enforcable' => true,
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60 * 24,
                'reason' => 'Third violation for impersonation. Continued deceptive behavior will result in extended removal. [3rd Offense]',
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60 * 24 * 7,
                'reason' => 'Fourth violation for impersonation. Continued deceptive behavior will result in extended removal. [4th Offense]',
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60 * 24 * 30,
                'reason' => 'Fifth violation for impersonation. Continued deceptive behavior will result in extended removal. [5th Offense]',
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => BAN_DURATION_LONG_TERM,
                'reason' => 'Repeated violation of impersonation policy. Continued deceptive behavior will result in extended removal. [Repeated Offense]',
            ],
        ],
    ],
    5 => [
        'title' => 'No Threats of Violence or Self-Harm',
        'description' => 'Do not make threats or promote harm in any form.',
        'escalations' => [
            [
                'type' => 'ban',
                'duration_in_minutes' => 60,
                'reason' => 'Serious warning: Threats of violence or self-harm are strictly prohibited and may require intervention. [1st Offense]',
                'reason_ai' => 'Automated Warning: Threats of violence or self-harm are strictly prohibited and may require intervention. [AI Detected Offense]',
                'is_ai_enforcable' => true,
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60 * 24,
                'reason' => 'Second violation for threats of violence or self-harm. This behavior is dangerous and unacceptable. [2nd Offense]',
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60 * 24 * 7,
                'reason' => 'Third violation for threats of violence or self-harm. Continued dangerous behavior will result in extended removal. [3rd Offense]',
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60 * 24 * 30,
                'reason' => 'Fourth violation for threats of violence or self-harm. Continued dangerous behavior will result in extended removal. [4th Offense]',
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => BAN_DURATION_LONG_TERM,
                'reason' => 'Repeated violation of threats of violence or self-harm. Continued dangerous behavior will result in extended removal. [Repeated Offense]',
            ],
        ],
    ],
    6 => [
        'title' => 'Keep Content Age-Appropriate',
        'description' => 'Avoid sexually explicit or overly graphic content in voice/text.',
        'escalations' => [
            [
                'type' => 'mute',
                'duration_in_minutes' => 10,
                'reason' => 'Warning: Please keep content age-appropriate. Sexually explicit or overly graphic content is not allowed. [1st Offense]',
                'reason_ai' => 'Automated Warning: Please keep content age-appropriate. Sexually explicit or overly graphic content is not allowed. [AI Detected Offense]',
                'is_ai_enforcable' => true,
            ],
            [
                'type' => 'kick',
                'duration_in_minutes' => 0,
                'reason' => 'Second violation for inappropriate content. Please maintain family-friendly communication. [2nd Offense]',
                'reason_ai' => 'Automated Warning: Second violation for inappropriate content. Please maintain family-friendly communication. [AI Detected Offense]',
                'is_ai_enforcable' => true,
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60,
                'reason' => 'Third violation for inappropriate content. Age-appropriate communication is required for all players. [3rd Offense]',
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60 * 24,
                'reason' => 'Fourth violation for inappropriate content. Continued explicit or graphic content will result in permanent removal. [4th Offense]',
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60 * 24 * 7,
                'reason' => 'Fifth violation for inappropriate content. Continued explicit or graphic content will result in permanent removal. [5th Offense]',
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60 * 24 * 30,
                'reason' => 'Sixth violation for inappropriate content. Continued explicit or graphic content will result in permanent removal. [6th Offense]',
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => BAN_DURATION_LONG_TERM,
                'reason' => 'Repeated violation of inappropriate content policy. Continued explicit or graphic content will result in permanent removal. [Repeated Offense]',
            ],
        ],
    ],
    7 => [
        'title' => 'Follow Staff Instructions',
        'description' => 'Do not ignore or argue with moderation decisions in-game.',
        'escalations' => [
            [
                'type' => 'mute',
                'duration_in_minutes' => 10,
                'reason' => 'Warning: Please follow staff instructions. Arguing with or ignoring moderation decisions disrupts the game. [1st Offense]',
            ],
            [
                'type' => 'kick',
                'duration_in_minutes' => 0,
                'reason' => 'Second violation for disobeying staff. Moderation decisions must be respected for fair gameplay. [2nd Offense]',
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60 * 2,
                'reason' => 'Third violation for disobeying staff instructions. Continued defiance disrupts server management. [3rd Offense]',
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60 * 24,
                'reason' => 'Fourth violation for disobeying staff instructions. Continued defiance disrupts server management. [4th Offense]',
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60 * 24 * 7,
                'reason' => 'Fifth violation for disobeying staff instructions. Continued defiance disrupts server management. [5th Offense]',
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => 60 * 24 * 30,
                'reason' => 'Sixth violation for disobeying staff instructions. Continued defiance disrupts server management. [6th Offense]',
            ],
            [
                'type' => 'ban',
                'duration_in_minutes' => BAN_DURATION_LONG_TERM,
                'reason' => 'Repeated violation of staff instructions. Continued defiance disrupts server management. [Repeated Offense]',
            ],
        ],
    ],
];
