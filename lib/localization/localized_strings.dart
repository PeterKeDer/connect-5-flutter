const LOCALIZED_STRINGS = {
  'en': ENGLISH,
  'zh': CHINESE_SIMPLIFIED,
  'zh_Hans': CHINESE_SIMPLIFIED,
  'zh_Hant': CHINESE_TRADITIONAL,
};

const ENGLISH = {
  'connect_5': 'Connect 5',
  'cancel': 'Cancel',
  'confirm': 'Confirm',
  'done': 'Done',
  'ok': 'OK',

  // Start menu
  'continue_game': 'Continue Game',
  'new_game': 'New Game',
  'replays': 'Replays',

  // Settings
  'settings': 'Settings',
  'general': 'General',
  'change_language': 'Change Language',
  'language': 'Language',
  'game': 'Game',
  'double_tap_to_confirm': 'Double Tap to Confirm',
  'highlight_last_step': 'Highlight Last Step',
  'highlight_winning_moves': 'Highlight Winning Moves',
  'board_size': 'Board Size',
  'appearance': 'Appearance',
  'dark_mode': 'Dark Mode',
  'accent': 'Accent',
  'board_theme': 'Board Theme',

  // Game
  'start_new_game': 'Start New Game',
  'two_players': 'Two Players',
  'bot_black': 'Bot (Black)',
  'bot_white': 'Bot (White)',
  'restart_game': 'Restart Game',
  'quit': 'Quit',
  'black_victory': 'Black Victory',
  'white_victory': 'White Victory',
  'tie': 'Tie',

  // Replays
  'steps': 'steps',
  'no_replays_message': 'There are currently no replays saved. Whenever you finish a game, it will be saved here.',

  // Stats
  'stats': 'Stats',
  'total_games_played': 'Total Games Played',
  'total_black_victory': 'Total Black Victory',
  'total_white_victory': 'Total White Victory',
  'games_played': 'Games Played',
  'games_won': 'Games Won',
  'games_lost': 'Games Lost',
  'win_rate': 'Win Rate',
  'player_vs_bot_black': 'Player vs Bot (Black)',
  'player_vs_bot_white': 'Player vs Bot (White)',
  'clear_stats': 'Clear Stats',
  'clear_stats_alert_message': 'Are you sure you want to clear stats? They will be permanently deleted.',

  // Help
  'help': 'Help',
  'help_message': 'Two players put down pieces on the board alternately. The first player who connects 5 pieces in a row wins.',

  // Accents
  'accent_blue': 'Blue',
  'accent_red': 'Red',
  'accent_green': 'Green',
  'accent_orange': 'Orange',
  'accent_grey': 'Grey',

  // Board themes
  'board_theme_classic': 'Classic',
  'board_theme_classic_darker': 'Classic Darker',
  'board_theme_night': 'Night',
  'board_theme_blue': 'Blue',
  'board_theme_red': 'Red',
  'board_theme_green': 'Green',
  'board_theme_grey': 'Grey',

  // Multiplayer
  'multiplayer': 'Multiplayer',
  'player_1': 'Player 1',
  'player_2': 'Player 2',
  'spectator': 'Spectator',
  'spectators': 'Spectators',
  'guest': 'Guest',
  'you': 'You',
  'rooms': 'Rooms',
  'room_info': 'Room Info',
  'room_id': 'Room ID',
  'room_settings': 'Room Settings',
  'allow_spectators': 'Allow Spectators',
  'public_room': 'Public Room',
  'no_rooms_message': 'No rooms at the moment. You can create one!',
  'join_room': 'Join Room',
  'join_room_by_id': 'Join Room by ID',
  'create_room': 'Create Room',

  // Multiplayer errors
  'connection_failed': 'Connection Failed',
  'connection_failed_message': 'Cannot connect to server. Please check your internet connection and try again later.',
  'invalid_room_id': 'Invalid Room ID',
  'invalid_room_id_message': 'The room ID is invalid. Please try another one.',
  'room_id_taken': 'Room ID Taken',
  'room_id_taken_message': 'The room ID is already being used by a room. Please try another one.',
  'cannot_create_room': 'Cannot Create Room',
  'cannot_create_room_message': 'Unable to create a room. Please check your internet connection and try again later.',
};

const CHINESE_SIMPLIFIED = {
  'connect_5': '五子棋',
  'cancel': '取消',
  'confirm': '确认',
  'done': '完成',
  'ok': 'OK',

  // Start menu
  'continue_game': '继续游戏',
  'new_game': '新游戏',
  'replays': '游戏回放',

  // Settings
  'settings': '设置',
  'general': '通用',
  'change_language': '切换语言',
  'language': '语言',
  'game': '游戏',
  'double_tap_to_confirm': '双击确认落子',
  'highlight_last_step': '标记上一步',
  'highlight_winning_moves': '标记胜利棋子',
  'board_size': '棋盘大小',
  'appearance': '外貌',
  'dark_mode': '黑夜模式',
  'accent': '色调',
  'board_theme': '棋盘色调',

  // Game
  'start_new_game': '开始新游戏',
  'two_players': '双人',
  'bot_black': '人机（黑棋）',
  'bot_white': '人机（白棋）',
  'restart_game': '重新开始',
  'quit': '退出',
  'black_victory': '黑棋胜利',
  'white_victory': '白棋胜利',
  'tie': '平局',

  // Replays
  'steps': '步',
  'no_replays_message': '目前没有任何游戏回放。当你完成一盘游戏时，它会被存在这里。',

  // Stats
  'stats': '数据',
  'total_games_played': '游戏总数',
  'total_black_victory': '黑棋胜利总数',
  'total_white_victory': '白棋胜利总数',
  'games_played': '游戏次数',
  'games_won': '胜利次数',
  'games_lost': '失败次数',
  'win_rate': '胜率',
  'player_vs_bot_black': '玩家 vs 人机（黑棋）',
  'player_vs_bot_white': '玩家 vs 人机（白棋）',
  'clear_stats': '清空数据',
  'clear_stats_alert_message': '确定要清空数据吗？它们会被永久删除。',

  // Help
  'help': '帮助',
  'help_message': '两个玩家轮流放在棋盘上放下一个棋子。第一个将五个棋子连成一条直线的玩家获胜。',

  // Accents
  'accent_blue': '蓝色',
  'accent_red': '红色',
  'accent_green': '绿色',
  'accent_orange': '橙色',
  'accent_grey': '灰色',

  // Board themes
  'board_theme_classic': '经典',
  'board_theme_classic_darker': '深色经典',
  'board_theme_night': '黑夜',
  'board_theme_blue': '蓝色',
  'board_theme_red': '红色',
  'board_theme_green': '绿色',
  'board_theme_grey': '灰色',
};

const CHINESE_TRADITIONAL = {
  'connect_5': '五子棋',
  'cancel': '取消',
  'confirm': '確認',
  'done': '完成',
  'ok': 'OK',

  // Start menu
  'continue_game': '繼續遊戲',
  'new_game': '新遊戲',
  'replays': '遊戲回放',

  // Settings
  'settings': '設置',
  'general': '通用',
  'change_language': '切換語言',
  'language': '語言',
  'game': '遊戲',
  'double_tap_to_confirm': '雙擊確認落子',
  'highlight_last_step': '標記上一步',
  'highlight_winning_moves': '標記勝利棋子',
  'board_size': '棋盤大小',
  'appearance': '外貌',
  'dark_mode': '黑夜模式',
  'accent': '色調',
  'board_theme': '棋盤色調',

  // Game
  'start_new_game': '開始新遊戲',
  'two_players': '雙人',
  'bot_black': '人機（黑棋）',
  'bot_white': '人機（白棋）',
  'restart_game': '重新開始',
  'quit': '退出',
  'black_victory': '黑棋勝利',
  'white_victory': '白棋勝利',
  'tie': '平局',

  // Replays
  'steps': '步',
  'no_replays_message': '目前沒有任何遊戲回放。當你完成一盤遊戲時，它會被存在這裏。',

  // Stats
  'stats': '數據',
  'total_games_played': '遊戲總數',
  'total_black_victory': '黑棋勝利總數',
  'total_white_victory': '白棋勝利總數',
  'games_played': '遊戲次數',
  'games_won': '勝利次數',
  'games_lost': '失敗次數',
  'win_rate': '勝率',
  'player_vs_bot_black': '玩家 vs 人機（黑棋）',
  'player_vs_bot_white': '玩家 vs 人機（白棋）',
  'clear_stats': '清空數據',
  'clear_stats_alert_message': '確定要清空數據嗎？它們會被永久刪除。',

  // Help
  'help': '幫助',
  'help_message': '兩個玩家輪流放在棋盤上放下一個棋子。第一個將五個棋子連成一條直線的玩家獲勝。',

  // Accents
  'accent_blue': '藍色',
  'accent_red': '紅色',
  'accent_green': '綠色',
  'accent_orange': '橙色',
  'accent_grey': '灰色',

  // Board themes
  'board_theme_classic': '經典',
  'board_theme_classic_darker': '深色經典',
  'board_theme_night': '黑夜',
  'board_theme_blue': '藍色',
  'board_theme_red': '紅色',
  'board_theme_green': '綠色',
  'board_theme_grey': '灰色',
};
