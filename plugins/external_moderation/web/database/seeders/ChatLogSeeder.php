<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class ChatLogSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $chatLogs = [
            // Original entries
            [
                'chat_type' => 'ooc',
                'steam_name' => 'Luttje',
                'steam_id' => '76561198002016569',
                'rank' => 'superadmin',
                'character_name' => 'James Bond',
                'character_id' => 1,
                'ip_address' => '127.0.0.1',
                'message' => 'Hello everyone!',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'Meanie',
                'steam_id' => '90071996842377217',
                'rank' => 'player',
                'character_name' => 'Ernst Stavro Blofeld',
                'character_id' => 2,
                'ip_address' => '192.168.0.1',
                'message' => 'Hello asshole!',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'Luttje',
                'steam_id' => '76561198002016569',
                'rank' => 'superadmin',
                'character_name' => 'James Bond',
                'character_id' => 1,
                'ip_address' => '127.0.0.1',
                'message' => 'Wow, that was rude!',
            ],
            [
                'chat_type' => 'voice',
                'steam_name' => 'Meanie',
                'steam_id' => '90071996842377217',
                'rank' => 'player',
                'character_name' => 'Ernst Stavro Blofeld',
                'character_id' => 2,
                'ip_address' => '192.168.0.1',
                'voice_chat_path' => '/srv/experiment-redux/plugins/external_moderation/voice-server/recordings/transcribed/000000000000000000000.wav',
            ],

            // Safe chat examples
            [
                'chat_type' => 'ooc',
                'steam_name' => 'GamerDude42',
                'steam_id' => '76561198123456789',
                'rank' => 'player',
                'character_name' => 'Officer Johnson',
                'character_id' => 3,
                'ip_address' => '192.168.1.100',
                'message' => 'Anyone know where the gun store is?',
            ],
            [
                'chat_type' => 'ic',
                'steam_name' => 'RPQueen',
                'steam_id' => '76561198987654321',
                'rank' => 'player',
                'character_name' => 'Sarah Martinez',
                'character_id' => 4,
                'ip_address' => '10.0.0.5',
                'message' => 'Good morning, how can I help you today?',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'NewbieMike',
                'steam_id' => '76561198555666777',
                'rank' => 'player',
                'character_name' => 'Mike Thompson',
                'character_id' => 5,
                'ip_address' => '172.16.0.10',
                'message' => 'Thanks for helping me learn the ropes!',
            ],
            [
                'chat_type' => 'ic',
                'steam_name' => 'CarEnthusiast',
                'steam_id' => '76561198444555666',
                'rank' => 'player',
                'character_name' => 'Tony Ricci',
                'character_id' => 6,
                'ip_address' => '192.168.2.50',
                'message' => 'Nice car! What engine does it have?',
            ],

            // Rule-breaking examples - Toxicity
            [
                'chat_type' => 'ooc',
                'steam_name' => 'AngryGamer',
                'steam_id' => '76561198111222333',
                'rank' => 'player',
                'character_name' => 'Chad Williams',
                'character_id' => 7,
                'ip_address' => '203.0.113.15',
                'message' => 'This server is trash, admins are idiots',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'ToxicPlayer',
                'steam_id' => '76561198222333444',
                'rank' => 'player',
                'character_name' => 'Kyle Rogers',
                'character_id' => 8,
                'ip_address' => '198.51.100.20',
                'message' => 'Get good scrub, you suck at this game',
            ],

            // More safe interactions
            [
                'chat_type' => 'ic',
                'steam_name' => 'MedicMain',
                'steam_id' => '76561198333444555',
                'rank' => 'player',
                'character_name' => 'Dr. Emily Chen',
                'character_id' => 9,
                'ip_address' => '192.168.3.75',
                'message' => 'I need backup at the hospital, multiple casualties',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'HelpfulAdmin',
                'steam_id' => '76561198666777888',
                'rank' => 'admin',
                'character_name' => 'Admin Steve',
                'character_id' => 10,
                'ip_address' => '10.0.1.5',
                'message' => 'Remember to read the server rules before playing!',
            ],
            [
                'chat_type' => 'ic',
                'steam_name' => 'CopPlayer',
                'steam_id' => '76561198777888999',
                'rank' => 'player',
                'character_name' => 'Sergeant Davis',
                'character_id' => 11,
                'ip_address' => '172.16.1.25',
                'message' => 'All units, we have a 10-54 on Main Street',
            ],

            // Spam violations
            [
                'chat_type' => 'ooc',
                'steam_name' => 'SpammerKid',
                'steam_id' => '76561198888999000',
                'rank' => 'player',
                'character_name' => 'Jimmy Spam',
                'character_id' => 12,
                'ip_address' => '203.0.113.25',
                'message' => 'HELLO HELLO HELLO HELLO HELLO',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'SpammerKid',
                'steam_id' => '76561198888999000',
                'rank' => 'player',
                'character_name' => 'Jimmy Spam',
                'character_id' => 12,
                'ip_address' => '203.0.113.25',
                'message' => 'AAAAAAAAAAAAAAAAAAAAAA',
            ],

            // More normal gameplay
            [
                'chat_type' => 'ic',
                'steam_name' => 'BusinessOwner',
                'steam_id' => '76561198999000111',
                'rank' => 'player',
                'character_name' => 'Maria Rodriguez',
                'character_id' => 13,
                'ip_address' => '192.168.4.100',
                'message' => 'Welcome to my restaurant! What would you like to order?',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'FriendlyPlayer',
                'steam_id' => '76561198000111222',
                'rank' => 'player',
                'character_name' => 'Alex Park',
                'character_id' => 14,
                'ip_address' => '10.0.2.10',
                'message' => 'Great RP everyone, having a blast!',
            ],

            // Inappropriate content
            [
                'chat_type' => 'ooc',
                'steam_name' => 'EdgeLord',
                'steam_id' => '76561198111333555',
                'rank' => 'player',
                'character_name' => 'Dark Shadow',
                'character_id' => 15,
                'ip_address' => '198.51.100.30',
                'message' => 'This is some messed up n*gger shit right here',
            ],
            [
                'chat_type' => 'ic',
                'steam_name' => 'BadRoleplay',
                'steam_id' => '76561198222444666',
                'rank' => 'player',
                'character_name' => 'Broken Character',
                'character_id' => 16,
                'ip_address' => '172.16.2.50',
                'message' => 'I will suck cock IRL for $0',
            ],

            // More safe content
            [
                'chat_type' => 'ic',
                'steam_id' => '76561198333555777',
                'steam_name' => 'LawEnforcement',
                'rank' => 'player',
                'character_name' => 'Detective Smith',
                'character_id' => 17,
                'ip_address' => '192.168.5.25',
                'message' => 'Could you please step out of the vehicle?',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'RegularPlayer',
                'steam_id' => '76561198444666888',
                'rank' => 'player',
                'character_name' => 'John Doe',
                'character_id' => 18,
                'ip_address' => '10.0.3.15',
                'message' => 'Is the bank open for business?',
            ],

            // Doxing violation
            [
                'chat_type' => 'ooc',
                'steam_name' => 'MetaGamer',
                'steam_id' => '76561198555777999',
                'rank' => 'player',
                'character_name' => 'Meta Mike',
                'character_id' => 19,
                'ip_address' => '203.0.113.35',
                'message' => 'Hey Tony, I know your real name is Tony Ricci, you can\'t hide from me',
            ],

            // More normal interactions
            [
                'chat_type' => 'ic',
                'steam_name' => 'ShopKeeper',
                'steam_id' => '76561198666888000',
                'rank' => 'player',
                'character_name' => 'Bob Wilson',
                'character_id' => 20,
                'ip_address' => '172.16.3.75',
                'message' => 'That will be $50 for the groceries',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'NiceGuy',
                'steam_id' => '76561198777999111',
                'rank' => 'player',
                'character_name' => 'Nice Norman',
                'character_id' => 21,
                'ip_address' => '192.168.6.50',
                'message' => 'Thanks for the great roleplay session!',
            ],

            // More quality RP
            [
                'chat_type' => 'ic',
                'steam_name' => 'GoodRPer',
                'steam_id' => '76561198999111333',
                'rank' => 'player',
                'character_name' => 'Rachel Green',
                'character_id' => 23,
                'ip_address' => '10.0.4.20',
                'message' => 'I need to speak with you about the contract we discussed',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'Moderator1',
                'steam_id' => '76561198000222444',
                'rank' => 'admin',
                'character_name' => 'Mod Sarah',
                'character_id' => 24,
                'ip_address' => '10.0.1.10',
                'message' => 'Please keep OOC chat to a minimum during active RP',
            ],

            // More violations
            [
                'chat_type' => 'ooc',
                'steam_name' => 'RuleBreaker',
                'steam_id' => '76561198111444777',
                'rank' => 'player',
                'character_name' => 'Bad Actor',
                'character_id' => 25,
                'ip_address' => '172.16.4.100',
                'message' => 'F*ck this server and f*ck all of you',
            ],

            // Positive interactions
            [
                'chat_type' => 'ic',
                'steam_name' => 'EMSWorker',
                'steam_id' => '76561198222555888',
                'rank' => 'player',
                'character_name' => 'Paramedic Jones',
                'character_id' => 26,
                'ip_address' => '192.168.7.75',
                'message' => 'Patient is stable, transporting to hospital now',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'VeteranPlayer',
                'steam_id' => '76561198333666999',
                'rank' => 'player',
                'character_name' => 'Old Timer',
                'character_id' => 27,
                'ip_address' => '10.0.5.25',
                'message' => 'Love seeing new players getting into RP!',
            ],
            [
                'chat_type' => 'ic',
                'steam_name' => 'Mechanic',
                'steam_id' => '76561198555888111',
                'rank' => 'player',
                'character_name' => 'Wrench Turner',
                'character_id' => 29,
                'ip_address' => '172.16.5.25',
                'message' => 'Your car should be good as new now',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'Helper',
                'steam_id' => '76561198666999222',
                'rank' => 'player',
                'character_name' => 'Helper Tom',
                'character_id' => 30,
                'ip_address' => '10.0.1.15',
                'message' => 'Type /help for a list of available commands',
            ],

            // Advertising violation
            [
                'chat_type' => 'ooc',
                'steam_name' => 'Advertiser',
                'steam_id' => '76561198777000333',
                'rank' => 'player',
                'character_name' => 'Spam Bot',
                'character_id' => 31,
                'ip_address' => '198.51.100.50',
                'message' => 'Join our better server at 192.168.1.1:7777',
            ],

            // Quality interactions continue
            [
                'chat_type' => 'ic',
                'steam_name' => 'Businessman',
                'steam_id' => '76561198888111444',
                'rank' => 'player',
                'character_name' => 'Corporate Carl',
                'character_id' => 32,
                'ip_address' => '192.168.8.100',
                'message' => 'The quarterly reports look promising',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'NewPlayer2',
                'steam_id' => '76561198999222555',
                'rank' => 'player',
                'character_name' => 'Newbie Nancy',
                'character_id' => 33,
                'ip_address' => '10.0.6.30',
                'message' => 'How do I change my character appearance?',
            ],

            // Personal attack
            [
                'chat_type' => 'ooc',
                'steam_name' => 'PersonalAttacker',
                'steam_id' => '76561198000333666',
                'rank' => 'player',
                'character_name' => 'Mean Person',
                'character_id' => 34,
                'ip_address' => '172.16.6.50',
                'message' => 'You are so stupid, get a life loser',
            ],

            // More normal content
            [
                'chat_type' => 'ic',
                'steam_name' => 'FireFighter',
                'steam_id' => '76561198111555888',
                'rank' => 'player',
                'character_name' => 'Chief Burns',
                'character_id' => 35,
                'ip_address' => '192.168.9.25',
                'message' => 'Fire department responding to downtown blaze',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'GratefulPlayer',
                'steam_id' => '76561198222666999',
                'rank' => 'player',
                'character_name' => 'Grateful Greg',
                'character_id' => 36,
                'ip_address' => '10.0.7.35',
                'message' => 'Thanks admin for fixing that bug!',
            ],

            // Character breaking
            [
                'chat_type' => 'ic',
                'steam_name' => 'Jaaack',
                'steam_id' => '76561198333777000',
                'rank' => 'player',
                'character_name' => 'Confused Character',
                'character_id' => 37,
                'ip_address' => '203.0.113.55',
                'message' => 'BRB guys, getting some food IRL',
            ],

            // More quality RP
            [
                'chat_type' => 'ic',
                'steam_name' => 'Lawyer',
                'steam_id' => '76561198444888111',
                'rank' => 'player',
                'character_name' => 'Attorney Adams',
                'character_id' => 38,
                'ip_address' => '172.16.7.75',
                'message' => 'My client pleads not guilty to all charges',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'EventHost',
                'steam_id' => '76561198555999222',
                'rank' => 'admin',
                'character_name' => 'Event Master',
                'character_id' => 39,
                'ip_address' => '10.0.1.20',
                'message' => 'Car show event starting in 10 minutes at the park!',
            ],

            // Discrimination
            [
                'chat_type' => 'ooc',
                'steam_name' => 'Discriminator',
                'steam_id' => '76561198666000333',
                'rank' => 'player',
                'character_name' => 'Bigot Bob',
                'character_id' => 40,
                'ip_address' => '198.51.100.60',
                'message' => 'People from that shithole country are all terrible at this game',
            ],

            // Positive community building
            [
                'chat_type' => 'ooc',
                'steam_name' => 'CommunityBuilder',
                'steam_id' => '76561198777111444',
                'rank' => 'player',
                'character_name' => 'Community Carl',
                'character_id' => 41,
                'ip_address' => '192.168.10.50',
                'message' => 'Great job on that chase scene everyone!',
            ],
            [
                'chat_type' => 'ic',
                'steam_name' => 'TaxiDriver',
                'steam_id' => '76561198888222555',
                'rank' => 'player',
                'character_name' => 'Taxi Ted',
                'character_id' => 42,
                'ip_address' => '10.0.8.40',
                'message' => 'Taxi service available, call 555-TAXI',
            ],

            // More normal interactions
            [
                'chat_type' => 'ic',
                'steam_name' => 'BankTeller',
                'steam_id' => '76561198000444777',
                'rank' => 'player',
                'character_name' => 'Teller Tracy',
                'character_id' => 44,
                'ip_address' => '192.168.11.75',
                'message' => 'How can I assist you with your banking today?',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'TechSupport',
                'steam_id' => '76561198111666999',
                'rank' => 'player',
                'character_name' => 'Tech Tim',
                'character_id' => 45,
                'ip_address' => '10.0.1.25',
                'message' => 'Try pressing F1 to open the character menu',
            ],

            // Quality content continues
            [
                'chat_type' => 'ic',
                'steam_name' => 'Judge',
                'steam_id' => '76561198333888111',
                'rank' => 'player',
                'character_name' => 'Judge Judy',
                'character_id' => 47,
                'ip_address' => '172.16.9.25',
                'message' => 'Order in the court! The defendant will approach the bench',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'Photographer',
                'steam_id' => '76561198444999222',
                'rank' => 'player',
                'character_name' => 'Photo Phil',
                'character_id' => 48,
                'ip_address' => '192.168.12.100',
                'message' => 'Amazing screenshot opportunities during that scene!',
            ],

            // Cheating accusation/discussion
            [
                'chat_type' => 'ooc',
                'steam_name' => 'SuspiciousPlayer',
                'steam_id' => '76561198555000333',
                'rank' => 'player',
                'character_name' => 'Suspicious Sam',
                'character_id' => 49,
                'ip_address' => '198.51.100.70',
                'message' => 'That guy is definitely cheating, no way he knew that',
            ],

            // More positive interactions
            [
                'chat_type' => 'ic',
                'steam_name' => 'Pharmacist',
                'steam_id' => '76561198666111444',
                'rank' => 'player',
                'character_name' => 'Dr. Pills',
                'character_id' => 50,
                'ip_address' => '10.0.9.45',
                'message' => 'Here is your prescription, take two daily',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'Streamer',
                'steam_id' => '76561198777222555',
                'rank' => 'player',
                'character_name' => 'Stream Steve',
                'character_id' => 51,
                'ip_address' => '172.16.10.50',
                'message' => 'Thanks for being cool about being on stream!',
            ],

            // Quality RP examples
            [
                'chat_type' => 'ic',
                'steam_name' => 'NewsReporter',
                'steam_id' => '76561198999444777',
                'rank' => 'player',
                'character_name' => 'News Nancy',
                'character_id' => 53,
                'ip_address' => '10.0.10.50',
                'message' => 'This is Channel 7 News reporting live from downtown',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'MentorPlayer',
                'steam_id' => '76561198000555888',
                'rank' => 'player',
                'character_name' => 'Mentor Mark',
                'character_id' => 54,
                'ip_address' => '172.16.11.75',
                'message' => 'Feel free to message me if you need help learning!',
            ],

            // Ban evasion discussion
            [
                'chat_type' => 'ooc',
                'steam_name' => 'BanEvader',
                'steam_id' => '76561198111777000',
                'rank' => 'player',
                'character_name' => 'Second Account',
                'character_id' => 55,
                'ip_address' => '203.0.113.75',
                'message' => 'Good thing they banned my other account, not this one',
            ],

            // More quality content
            [
                'chat_type' => 'ic',
                'steam_name' => 'Architect',
                'steam_id' => '76561198222888111',
                'rank' => 'player',
                'character_name' => 'Builder Bill',
                'character_id' => 56,
                'ip_address' => '192.168.14.100',
                'message' => 'The new building should be completed next week',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'PatientPlayer',
                'steam_id' => '76561198333999222',
                'rank' => 'player',
                'character_name' => 'Patient Pat',
                'character_id' => 57,
                'ip_address' => '10.0.11.55',
                'message' => 'I appreciate the admins working hard to keep the server running smoothly',
            ],
            [
                'chat_type' => 'ic',
                'steam_name' => 'Firefighter2',
                'steam_id' => '76561198444000333',
                'rank' => 'player',
                'character_name' => 'Fireman Fred',
                'character_id' => 58,
                'ip_address' => '10.0.12.55',
                'message' => 'I\'m here to help with any fires or emergencies!',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'FriendlyFace',
                'steam_id' => '76561198555111444',
                'rank' => 'player',
                'character_name' => 'Friendly Fiona',
                'character_id' => 59,
                'ip_address' => '10.0.13.55',
                'message' => 'I love helping new players find their way!',
            ],
        ];

        foreach ($chatLogs as $chatLog) {
            throw_if(! in_array($chatLog['chat_type'], ['voice', 'ic', 'ooc']), new \Exception('Invalid chat type: '.$chatLog['chat_type']));
            throw_if(! in_array($chatLog['rank'], ['admin', 'superadmin', 'player']), new \Exception('Invalid rank: '.$chatLog['rank']));

            \App\Models\ChatLog::create($chatLog);
        }
    }
}
