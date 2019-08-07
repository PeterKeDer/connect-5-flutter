import 'package:flutter/material.dart';

const LOCALE_NAMES = [
  'English',
  '简体中文',
];

const SUPPORTED_LOCALES = [
  Locale('en'),
  Locale('zh'),
];

const LOCALIZED_STRINGS = {
  'en': {
    'connect_5': 'Connect 5',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'done': 'Done',

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
  },
  'zh': {
    'connect_5': '五子棋',
    'cancel': '取消',
    'confirm': '确认',
    'done': '完成',

    // Start menu
    'continue_game': '继续游戏',
    'new_game': '新游戏',
    'replays': '游戏记录',

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
    'board_theme_classic_darker': '经典（深色）',
    'board_theme_night': '黑夜',
    'board_theme_blue': '蓝色',
    'board_theme_red': '红色',
    'board_theme_green': '绿色',
    'board_theme_grey': '灰色',
  }
};
